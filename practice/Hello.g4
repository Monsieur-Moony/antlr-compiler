// Define a grammar called Hello
grammar Hello;
prog: Class Program '{' field_decls method_decls '}';

field_decls: field_decls field_decl ';'
           | field_decls inited_field_decl ';'
           | ;

field_decl: field_decl ',' Ident
          | field_decl ',' Ident '[' num ']'
          | Type Ident
          | Type Ident '[' num ']';

inited_field_decl: Type Ident '=' literal;

method_decls: method_decls method_decl
            | ;

method_decl: Type Ident '(' params ')' block
           | Void Ident '(' params ')' block;

params: Type Ident next_params
      | ;

next_params: next_params ',' Type Ident
           | ;

block: '{' var_decls statements '}';

var_decls: var_decls var_decl ';'
         | ;

var_decl: var_decl ',' Ident
        | Type Ident;

statements: statement statements
          | ;

statement: location eqOp expr ';'
         | method_call ';'
         | If '(' expr ')' block (Else block)?
         | For Ident '=' expr ',' expr block
         | Ret (expr)? ';'
         | Brk ';'
         | Cnt ';'
         | block;

method_call: Ident '(' method_args ')'
           | Callout '(' Str callout_args ')';

callout_args: callout_args ',' callout_arg
            | ;

callout_arg: expr
           | Str;

method_args: expr next_method_args
           | ;

next_method_args: next_method_args ',' expr
                | ;

// Precedence: ||
//             &&
//             == !=
//             < <= > >=
//             + -
//             * / %
//             - ! <unary>
//             <method call> <literal> <location> ()
expr: logical_or_expr;

logical_or_expr: logical_or_expr '||' logical_and_expr
               | logical_and_expr;

logical_and_expr: logical_and_expr '&&' equality_expr
                | equality_expr;

equality_expr: equality_expr ('==' | '!=') rel_expr
             | rel_expr;

rel_expr: rel_expr ('<' | '<=' | '>' | '>=') additive_expr
        | additive_expr;

additive_expr: additive_expr ('+' | '-') multiplicative_expr
             | multiplicative_expr;

multiplicative_expr: multiplicative_expr ('*' | '/' | '%') unary_expr
                   | unary_expr;

unary_expr: ('-' | '!') unary_expr
          | primary_expr;

primary_expr: method_call
            | literal
            | location
            | '(' expr ')';

location: Ident
        | Ident '[' expr ']';

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
