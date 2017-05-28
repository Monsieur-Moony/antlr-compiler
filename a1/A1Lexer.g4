lexer grammar A1Lexer;

Class
: 'class'
;

// FIXME: Is this a keyword?
Program
: 'Program'
;

OBrace
: '{'
;

CBrace
: '}'
;

SemiColon
: ';'
;

VoidType
: 'void'
;

IntType
: 'int'
;

BoolType
: 'boolean'
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

Comma
: ','
;

Return
: 'return'
;

Break
: 'break'
;

Continue
: 'continue'
;

Assign
: '='
;

IncAssign
: '+='
;

DecAssign
: '-='
;

Callout
: 'callout'
;

OSquareBrace
: '['
;

CSquareBrace
: ']'
;

Minus
: '-'
;

Not
: '!'
;

OParen
: '('
;

CParen
: ')'
;

Plus
: '+'
;

Mult
: '*'
;

Div
: '/'
;

Modulo
: '%'
;

LessThan
: '<'
;

GreaterThan
: '>'
;

LessThanEqual
: '<='
;

GreaterThanEqual
: '>='
;

Equal
: '=='
;

NotEqual
: '!='
;

And
: '&&'
;

Or
: '||'
;

True
: 'true'
;

False
: 'false'
;

fragment Alphabet
: [a-zA-Z_]
;

fragment Digit
: [0-9]
;

Id
: Alphabet(Alphabet|Digit)*
;

fragment DecLiteral
: Digit+
;

fragment HexLiteral
: '0'('x'|'X')(Digit|[a-fA-F])+
;

IntLiteral
: DecLiteral | HexLiteral
;

fragment Char
: ~('\''|'\b'|'\f'|'\t'|'\n'|'\r'|'\\')
;

fragment EscapedChar
: '\\'('\\'|'\''|'"'|'a'|'b'|'f'|'n'|'r'|'t'|'v')
;

CharLiteral
: '\''(Char|EscapedChar)'\''
;

fragment StringChar
: ~('"'|'\b'|'\f'|'\t'|'\n'|'\r'|'\\')
;

StringLiteral
: '"'(StringChar|EscapedChar)*'"'
;

WhiteSpace
: (' '|'\b'|'\f'|'\t'|'\n'|'\r')+ -> skip
;

