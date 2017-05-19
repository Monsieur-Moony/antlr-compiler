lexer grammar A1Lexer;

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

Num
: Digit+
;

WhiteSpace
: Delim+ -> skip
;

Callout
: 'callout'
;

OParen
: '('
;

CParen
: ')'
;

SemiColon
: ';'
;











