// Goo (a subset of Go) language grammar
//
// The goal symbol for this grammar is sourceFile
//
// This ANTLR4 grammar is based on the Go grammar provided here:
//     https://golang.org/ref
//
// Author: Nigel Horspool, January 2016

grammar Goo;
import GooLexerRules;

// These grammar rules have been copied from https://golang.org/ref and
// converted to follow ANTLR4 conventions.
// The grammar rules appear in the same order.
// The lexical rules are in the separate file GooLexerRules.g4.
// A few grammar transformations have been made to simplify AST construction;
// namely embedded choices and some Kleene stars have been expanded out
// creating more rules and a few more nonterminals.

type
        :   typeName
        |   typeLit
        |   '(' type ')'
        ;

typeName
        :   Identifier
//        |   qualifiedIdent        // CHANGED
        ;

typeLit
        :   arrayType
        |   structType
        |   pointerType
        |   sliceType
        ;

arrayType
        :   '[' arrayLength ']' elementType
        ;

arrayLength
        :   expression
        ;

elementType
        :   type
        ;

sliceType
        :   '[' ']' elementType
        ;

structType
        :   STRUCT '{' fieldDeclList '}'
        ;

fieldDeclList        // CHANGED
        :   /* empty */
	|   (fieldDecl ';')* fieldDecl optSemi
        ;

fieldDecl
        :   identifierList type
        ;

pointerType
        :   '*' baseType
        ;

baseType
        :   type
        ;

signature
        :   parameters result?
        ;

result
        :   type
//        |   parameters        // A BIG CHANGE!
        ;

parameters
        :   '(' ( parameterList ','? )? ')'
        ;

parameterList
        :   parameterDecl (',' parameterDecl)*      // CHANGED
        ;

parameterDecl
        :   identifierList? type
        ;

methodName
        :   Identifier
        ;

block
        :   '{' statementList '}'
        ;

statementList        // CHANGED
	:	/* empty */
        |   (statement ';')* statement optSemi
        ;

declaration
        :   constDecl
        |   typeDecl
        |   varDecl
        ;

topLevelDeclList    // CHANGED
        :    /* empty */
	|    (topLevelDecl ';')* topLevelDecl optSemi
        ;

topLevelDecl
        :   declaration
        |   functionDecl
        ;

constDecl
        :   CONST constSpec
        |   CONST '(' constSpecList ')'
        ;

constSpecList   // CHANGED
        :   /* empty */
	|   (constSpec ';')* constSpec optSemi
        ;

constSpec
        :   identifierList constSpecRem?     // CHANGED
        ;

constSpecRem
        :   type? '=' expressionList
        ;

identifierList
        :   idl+=Identifier (',' idl+=Identifier)*    // CHANGED
        ;

expressionList
        :   exl+=expression (',' exl+=expression)*    // CHANGED
        ;

typeDecl
        :   TYPE typeSpec
        |   TYPE '(' typeSpecList ')'
        ;

typeSpecList         // CHANGED
        :   /* empty */
	|   (typeSpec ';')* typeSpec optSemi
        ;

typeSpec
        :   Identifier type
        ;

varDecl
        :   VAR varSpec
        |   VAR '(' varSpecList ')'
        ;

varSpecList      // CHANGED
        :   /* empty */
	|   (varSpec ';')* varSpec optSemi
        ;

varSpec
        :   identifierList varSpecRem
        ;

varSpecRem
        :   type
        |   type '=' expressionList
        |   '=' expressionList
        ;

shortVarDecl
        :   identifierList ':=' expressionList
        ;

functionDecl
        :   FUNC functionName function
        |   FUNC functionName signature
        ;

functionName
        :   Identifier
        ;

function
        :   signature functionBody
        ;

functionBody
        :   block
        ;

operand
        :   literal
        |   operandName
        |   '(' expression ')'
        ;

literal
        :   basicLit
        |   compositeLit
        ;

basicLit
        :   IntLit
        |   FloatLit
        |   RuneLit
        |   StringLit
        ;

operandName
        :   Identifier
        |   qualifiedIdent
        ;

qualifiedIdent
        :   packageName '.' Identifier
        ;

compositeLit
        :   literalType literalValue
        ;

literalType
        :   structType
        |   arrayType
        |   '[' '...' ']' elementType
        |   sliceType
        |   typeName
        ;

literalValue
        :   '{' '}'
        |   '{' elementList ','? '}'
        ;

elementList
        :   element (',' element)*      // CHANGED
        ;

element
        :   value
        |   key ':' value
        ;
key
        :   fieldName
        |   expression
        |   literalValue
        ;

fieldName
        :   Identifier
        ;

value
        :   expression
        |   literalValue
        ;

primaryExpr
        :   operand
        |	conversion
        |   primaryExpr selector
        |   primaryExpr index
        |	primaryExpr slice
        |	primaryExpr typeAssertion
        |	primaryExpr arguments
        ;

selector
        :   '.' Identifier
        ;

index
        :   '[' expression ']'
        ;

slice
        :   '[' expression? ':' expression? ']'
        |   '[' expression? ':' expression ':' expression ']'
        ;

typeAssertion
        :   '.' '(' type ')'
        ;

arguments
        :   '(' ')'
        |   '(' expressionList ','? ')'
        |   '(' type ','? ')'
        |   '(' type ',' expressionList ','? ')'
        ;

expression
        :   unaryExpr
        |   expression mulOp expression
        |   expression addOp expression
        |   expression relOp expression
        |   expression '&&' expression
        |   expression '||' expression
        ;

unaryExpr
        :   primaryExpr
        |   unaryOp unaryExpr
        ;

relOp
        :   '==' | '!=' | '<' | '<=' | '>' | '>='
        ;
        
addOp
        :   '+' | '-' | '|' | '^'
        ;

mulOp
        :   '*' | '/' | '%' | '<<' | '>>' | '&' | '&^'
        ;

unaryOp
        :   '+' | '-' | '!' | '^' | '*' | '&'
        ;

conversion
        :   type '(' expression ','? ')'
        ;

statement
        :   declaration
        |   labeledStmt
        |   simpleStmt
        |   goStmt
        |   returnStmt
        |   breakStmt
        |   continueStmt
        |   gotoStmt
        |   block
        |   ifStmt
        |   forStmt
        ;

simpleStmt
        :   emptyStmt
        |   expressionStmt
        |   incDecStmt
        |   assignment
        |   shortVarDecl
        ;

emptyStmt
        :
        ;

labeledStmt
        :   label ':' statement
        ;

label
        :   Identifier
        ;

expressionStmt
        :   expression
        ;

incDecStmt
        :   expression '++'
        |   expression '--'
        ;

assignment
        :   expressionList assignOp expressionList
        ;

assignOp
        :   '='
        |   addOp '='
        |   mulOp '='
        ;

ifStmt
        :   IF expression block elsePart
        |   IF simpleStmt ';' expression block elsePart
        ;

elsePart
        :       // empty
        |   ELSE ifStmt
        |   ELSE block
        ;

forStmt
        :   FOR condition block
        |   FOR forClause block
        |   FOR rangeClause block
        ;

condition
        :   expression
        ;

forClause
        :   initStmt ';' condition? ';' postStmt
        ;

initStmt        // simpleStmt includes the empty statement possibility
        :   simpleStmt
        ;

postStmt        // simpleStmt includes the empty statement possibility
        :   simpleStmt
        ;

rangeClause
        :   expressionList '=' RANGE expression
        |   identifierList ':=' RANGE expression
        ;

goStmt
        :   GO expression
        ;

returnStmt
        :   RETURN
        |   RETURN expressionList
        ;

breakStmt
        :   BREAK
        |   BREAK label
        ;

continueStmt
        :   CONTINUE
        |   CONTINUE label
        ;

gotoStmt
        :   GOTO label
        ;

// the goal symbol of this grammar
sourceFile
        :   packageClause ';' importDeclList topLevelDeclList
        ;

packageClause
        :   PACKAGE packageName
        ;

packageName
        :   Identifier
        ;

importDeclList
        :   (importDecl ';')*       // CHANGED
        ;

importDecl
        :   IMPORT importSpec
        |   IMPORT '(' importSpecList ')'
        ;

importSpecList       // CHANGED
	:   /* empty */
        |   (importSpec ';')* importSpec optSemi
        ;

importSpec
        :   '.' importPath
        |   packageName importPath
        |   importPath
        ;

importPath
        :   StringLit
        ;

// An optSemi allows a semicolon to be optional if it precedes a ')' or '}' symbol
// as allowed by the Go language specification
optSemi
	:   {_input.LT(1).getText().equals("}") || _input.LT(1).getText().equals(")")}?  /* empty */
	|   ';'
	;
