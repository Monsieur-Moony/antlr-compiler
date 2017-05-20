lexer grammar A1Lexer;

Class
: 'class'
;

// FIXME: Is this a keyword?
Program
: 'Program'
;

LeftBrace
: '{'
;

RightBrace
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

LeftBracket
: '['
;

RightBracket
: ']'
;

Minus
: '-'
;

Not
: '!'
;

LeftParen
: '('
;

RightParen
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

fragment EscapedChar
: '\\'('\\'|'\''|'n'|'t'|'r'|'v'|'b'|'a'|'f')
;

fragment Char
: ~('\''|'\\')
;

CharLiteral
: '\''(Char|EscapedChar)'\''
;

fragment StringChar
: ~('"'|'\n'|'\\')
;

StringLiteral
: '"'(StringChar|EscapedChar)*'"'
;

fragment Delim
: (' '|'\t'|'\n'|'\r'|'\b')
;

WhiteSpace
: Delim+ -> skip
;










