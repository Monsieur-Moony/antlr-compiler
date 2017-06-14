// Define a grammar called Hello
grammar Hello;
prog: Class Program '{' field_decls method_decls '}';

field_decls: field_decls field_decl ';'
           | field_decls inited_field_decl ';'
           | ;

field_decl: field_decl ',' Ident
          | Type Ident;

inited_field_decl: Type Ident '=' literal;

method_decls: method_decls method_decl
            | ;

method_decl: Type Ident '(' params ')' block
           | Void Ident '(' params ')' block;

params: Type Ident nextParams
      | ;

nextParams: nextParams ',' Type Ident
          | ;

block: '{' var_decls statements '}';

var_decls: var_decls var_decl ';'
         | ;

var_decl: var_decl ',' Ident
        | Type Ident;

statements: statement statements
          | ;

statement: location eqOp expr ';'
         | block;

expr: literal
    | expr binOp expr
    | location;

location: Ident;

// *******************************************

num
: DecNum
| HexNum
;

literal
: num
| Char
| BoolLit
;

eqOp
: '='
| AssignOp
;

mathOp
: '-'
| ArithOp
;

boolOp
: '!'
| CondOp
;

binOp
: mathOp
| RelOp
| CondOp
;

fragment Delim
: ' '
| '\t'
| '\n'
;

fragment Letter
: [a-zA-Z]
;

fragment Digit
: [0-9]
;

fragment HexDigit
: Digit
| [a-f]
| [A-F]
;

fragment Alpha
: Letter
| '_'
;

fragment AlphaNum
: Alpha
| Digit
;

WhiteSpace
: Delim+ -> skip
;

Char
: '\'' ~('\\') '\''
| '\'\\' . '\''
;

Str
:'"' ((~('\\' | '"')) | ('\\'.))* '"'
;

Class
: 'class'
;

Program
: 'Program'
;

Void
: 'void'
;

If
: 'if'
;

Else
: 'else'
;

For
: 'for'
;

Ret
: 'return'
;

Brk
: 'break'
;

Cnt
: 'continue'
;

Callout
: 'callout'
;

DecNum
: Digit+
;

HexNum
: '0x'HexDigit+
;

BoolLit
: 'true'
| 'false'
;

Type
: 'int'
| 'boolean'
;

Ident
: Alpha AlphaNum*
;

RelOp
: '<='
| '>='
| '<'
| '>'
| '=='
| '!='
;

AssignOp
: '+='
| '-='
;

ArithOp
: '+'
| '*'
| '/'
| '%'
;

CondOp
: '&&'
| '||'
;


//start: 'if' condition block;
//condition: '(' expr ')';
//expr: term | term ( '==' | '<=' | '>=' | '>' | '<' ) term;
//term: ID | 'true' | 'false' | NUM | condition;
//block: '{' (stmts | block) '}';
//stmts: stmt | stmts stmt;
//stmt: ID ';';
////r  : 'hello' l ;          // match keyword hello followed by an identifier
////l  : r | ID ;         // match keyword hello followed by an identifier
//ID : [a-z]+ ;             // match lower-case identifiers
//NUM: [1-9][0-9]*;
//WS : [ \t\r\n]+ -> skip ; // skip spaces, tabs, newlines
