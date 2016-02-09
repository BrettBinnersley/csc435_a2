// Type.java
//
// Instances are used to describe the types of symbols and expressions
// in the Goo subset of Go.
//
// One instance of this class is used for the unknown type -- used when
// we have not yet determined what the type should be.
// There are other instances for the string and bool types.
//
// Some special types are anyType, variadicAnyType, apsType.
// They are needed for checking calls to some library functions. For example,
// fmt.Print has the following signature:
//      func Print(a ...interface{}) (n int, err error)
// meaning that it can accept any number of arguments of any type. In this
// compiler, the type of that a parameter is described by variadicAnyType.
// Note: unknownType is not the same as anyType. The latter is used for
// checking library function calls where any type is accepted. The former
// is used for a variable or typename where we haven't yet determined what
// the type is, but will do so later.
//
// All other types are described by instances of nested subclasses of Type.
//

import java.util.*;

public class Type {
    public static final Type unknownType = new Type("???");
    public static final Type stringType = new Type("string");
    public static final Type boolType = new Type("bool");

    public static final Type anyType = new Type("(any)");
    public static final Type variadicAnyType = new Type("...(any)");
    public static final Type apsType = new Type("array/*array/slice/string");
    String name;

	// Constructors -- they are PRIVATE
    private Type() { name = "???"; }
    private Type(String name) { this.name = name; }

    public String getName() { return name; }
    public void setName(String n) { name = n; }

    public String toString() { return name; }

	// convenience method for creating int, uint and float types
	public static Type newNumericType(char w, int size) {
		if (w == 'i')
			return unknownType.new Int(size);
		if (w == 'u')
			return unknownType.new Uint(size);
		if (w == 'f')
			return unknownType.new Flt(size);
		System.out.println("Internal error: bad w value for newNumericType");
		System.exit(1);
		return null; // never executed!
	}

	public static Type newArrayType(Type elemType) {
		return unknownType.new Array(elemType);
	}
 
 	public static Type newSliceType(Type elemType) {
		return unknownType.new Slice(elemType);
	}

 	public static Type newPointerType(Type baseType) {
		return unknownType.new Pointer(baseType);
	}

 	public static Type newStructType(Scope s) {
		return unknownType.new Struct(s);
	}

	public static Type newFunctionSignature(
				LinkedList<Type> params, LinkedList<Type> results) {
		return unknownType.new Function(params,results);
	}

    // This method handles the case when a function has any number of results
    // but Goo limits functions to have 0 or 1 result.
	public static Type newFunctionSignature(Type[] params, Type[] results) {
		return unknownType.new Function(params,results);
	}

    // For use when function has 0 results (i.e. a void function)
	public static Type newFunctionSignature(Type[] params) {
	    Type[] results = new Type[0];
		return unknownType.new Function(params,results);
	}

    // For use when function has 1 result
	public static Type newFunctionSignature(Type[] params, Type result) {
	    Type[] results = new Type[1];
	    results[0] = result;
		return unknownType.new Function(params,results);
	}

    public class Int extends Type {
        private int size;
        
        public Int( int size ) {
            this.size = size;
            name = "int"+size;
        }
        
        public int getSize() { return size; }
    }

    public class Uint extends Type {
        private int size;
        
        public Uint( int size ) {
            this.size = size;
            name = "uint"+size;
        }
        
        public int getSize() { return size; }
    }

    public class Flt extends Type {
        private int size;
        
        public Flt( int size ) {
            this.size = size;
            name = "float"+size;
        }
        
        public int getSize() { return size; }
    }

    public class Array extends Type {
        private Type elementType;
        
        public Array( Type elementType ) {
            this.elementType = elementType;
            name = "[..]";
        }
        
        public Type getElementType() { return elementType; }
        
        @Override
        public String toString() {
            return elementType.toString()+"[..]";
        }
    }

    public class Slice extends Type {
        private Type elementType;
        
        public Slice( Type elementType ) {
            this.elementType = elementType;
            name = "[]";
        }
        
        public Type getElementType() { return elementType; }
        
        @Override
        public String toString() {
            return elementType.toString()+"[]";
        }
    }

    public class Pointer extends Type {
        private Type baseType;
        
        public Pointer( Type baseType ) {
            this.baseType = baseType;
            name = "*";
        }
        
        public Type getBaseType() { return baseType; }
        
        @Override
        public String toString() {
            return "*"+baseType.toString();
        }
    }

	// An instance of this class represents a function signature
	public class Function extends Type {
		private Type[] parameters;
		private Type[] results;

		public Function( LinkedList<Type> parameters, LinkedList<Type> results ) {
			this.parameters = parameters.toArray(new Type[0]);   // These stupid API calls are a consequence of
			this.results = results.toArray(new Type[0]);  // a brain-damaged implementation of generics in Java
		}

		public Function( Type[] parameters, Type[] results ) {
			this.parameters = (Type[])parameters.clone();
			this.results = (Type[])results.clone();
		}

		public Type[] getParameters() { return parameters; }
		
		public Type[] getResults() { return results; }

		@Override
		public String toString() {
		    StringBuilder sb = new StringBuilder();
		    if (parameters.length > 0) {
    		    char c = '(';
    		    for(Type t : parameters) {
    		        sb.append(c);
    		        c = ',';
    		        sb.append(t.toString());
    		    }
    		    sb.append(')');
		    } else
		        sb.append("()");
		    // Assuming functions return 0 or 1 result only
		    if (results.length>0) {
		        sb.append(':');
		        sb.append(results[0].toString());
		    }
			return sb.toString();
		}
	}

	public class Struct extends Type implements Scope {
		Map<String, Symbol> fields = new LinkedHashMap<String, Symbol>();
		Scope containingScope;

		public Struct(Scope s) {
			name = "struct";
			containingScope = s;
		}

		@Override
		public String toString() {
			return "struct{ "+fields.values()+" }";
		}

	    public String getScopeName() {  return getName(); }
	    public void setScopeName(String name) { /* ignored */ }

		// enclosing scope == scope in which the struct is declared
	    public Scope getEnclosingScope() { return containingScope;  }

	    public void define(Symbol sym) {
			fields.put(sym.name, sym);
			sym.setScope(this); // track the scope in each symbol
			// if (tracing) System.out.println("SY: Defined field: "+sym.name);
	    }

		// USE WITH CAUTION: lookups continue into the enclosing scope
		// If looking up a field, always check that the symbol found has
		// its kind equal to Field!
	    public Symbol resolve(String name) {
			Symbol s = fields.get(name);
	        if (s!=null) return s;
			if (getEnclosingScope() != null) {
				return getEnclosingScope().resolve(name);
			}
			return null; // not found
	    }

	    public void dumpScope() {
			System.out.println(getScopeName() + " {");
			for( Symbol sy : fields.values() ) {
				System.out.println("   "+sy.toString());
			}
			System.out.println("}\n");
	    }
	}

}