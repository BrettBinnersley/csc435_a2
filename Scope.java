// Scope.java
//
// Methods for one scope level in a tree-structured symbol table
//
public interface Scope {
    public String getScopeName();
    public void setScopeName(String name);

    /** Where to look next for symbols */
    public Scope getEnclosingScope();

    /** Define a symbol in the current scope */
    public void define(Symbol sym);

    /** Look up name in this scope or in enclosing scope if not here */
    public Symbol resolve(String name);
    
    /** Display the variables and types of all names in the scope */
    public void dumpScope();
}
