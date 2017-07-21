/*************************************************
 * Course: CMPT 379 Compilers - Summer 2017      *
 * Instructor: ***REMOVED*** ***REMOVED***                        *
 *                                               *
 * Author: Karan Sharma                          *
 * ID: ***REMOVED***                                 *
 * Email: ***REMOVED***                           *
 *************************************************/
// NOTE: Changes to Sessions 1 and 3 were made with the instructor's permission

grammar A3Code;

//---------------------------------------------------------------------------------------------------
// Session 1: ANTLR API, You SHOULD NOT make any modification to this session
//---------------------------------------------------------------------------------------------------
@header {
	import java.io.*;
	import java.util.ArrayList;
	import java.util.List;
}

@parser::members {
	public enum DataType {
		VOID(0), INT(4), BOOLEAN(1), INVALID(0);

		private int numBytes;

		DataType(int numBytes) {
			this.numBytes = numBytes;
		}

		public int getNumBytes() {
			return numBytes;
		}
	}

	public class Symbol {
		private String name;
		private DataType type;

		private static final String TEMP_VAR_PREFIX = "~t";

		public Symbol(String name, DataType type) {
			this.name = name;
			this.type = type;
		}

		public Symbol(int id, DataType type) {
			this.name = TEMP_VAR_PREFIX + id;
			this.type = type;
		}

		public DataType getType() {
			return type;
		}

		public String getName() {
			return name;
		}

		@Override
		public boolean equals(Object otherObj) {
			if (otherObj == null || (this.getClass() != otherObj.getClass())) {
				return false;
			}
			Symbol otherSymbol = (Symbol) otherObj;
			return this.name.equals(otherSymbol.name);
		}

		@Override
		public int hashCode() {
			return name.hashCode();
		}

		@Override
		public String toString() {
			return name + "\t" + type;
		}
	}

	public static final int INITIAL_CAPACITY = 1000;

	public class SymbolTable {
		private List<Symbol> symbols;
		private int temporariesCounter;

		public SymbolTable(int initialCapacity) {
			this.symbols = new ArrayList<>(initialCapacity);
			this.temporariesCounter = 0;
		}

		public int addUserVariable(String name, DataType type) {
			int oldSize = symbols.size();
			Symbol newSymbol = new Symbol(name, type);
			int newSymbolIndex = symbols.indexOf(newSymbol);
			if (newSymbolIndex >= 0) {
				return newSymbolIndex;
			}
			symbols.add(newSymbol);
			return oldSize;
		}

		public int addTemporary(DataType type) {
			int oldSize = symbols.size();
			symbols.add(new Symbol(temporariesCounter, type));
			temporariesCounter++;
			return oldSize;
		}

		public int find(String name) {
			for (int i = 0; i < symbols.size(); i++) {
				String currentSymbolName = symbols.get(i).getName();
				if (currentSymbolName.equals(name)) {
					return i;
				}
			}
			return -1;
		}

		public DataType getType(int index) {
			if (index < 0) {
				return DataType.INVALID;
			}
			return symbols.get(index).getType();
		}

		public String getName(int index) {
			if (index < 0) {
				return "";
			}
			return symbols.get(index).getName();
		}

		@Override
		public String toString() {
			StringBuilder sb = new StringBuilder();
			for (Symbol symbol : symbols) {
				sb.append(symbol + "\n");
			}
			return sb.toString();
		}
	}

	public SymbolTable symbolTable = new SymbolTable(INITIAL_CAPACITY);

	public class Quad {
		private int label;
		private String op;
		private int src1;
		private int src2;
		private int dst;

		Quad (int label, int dst, int src1, int src2, String op) {
			this.label = label;
			this.dst = dst;
			this.src1 = src1;
			this.src2 = src2;
			this.op = op;
		}

		@Override
		public String toString() {
			StringBuilder sb = new StringBuilder();
			sb.append("L_");
			sb.append(label);
			sb.append(": ");
			sb.append(symbolTable.getName(dst));
			if (op.equals("param")) {
				sb.append(" ");
				sb.append(op);
			} else {
				sb.append(" = ");
				sb.append(symbolTable.getName(src1));
				if (src2 != -1) {
					sb.append(" ");
					sb.append(op);
					sb.append(" ");
					sb.append(symbolTable.getName(src2));
				}
			}
			return sb.toString();
		}
	}

	public class QuadTable {
		private List<Quad> quads;

		QuadTable (int initialCapacity) {
			quads = new ArrayList<>(initialCapacity);
		}

		public int add(int dst, int src1, int src2, String op) {
			int oldSize = quads.size();
			quads.add(new Quad(oldSize, dst, src1, src2, op));
			return oldSize;
		}

		@Override
		public String toString() {
			StringBuilder sb = new StringBuilder();
			for (Quad quad : quads) {
				sb.append(quad + "\n");
			}
			return sb.toString();
		}
	}

	public QuadTable quadTable = new QuadTable(INITIAL_CAPACITY);
}

//---------------------------------------------------------------------------------------------------
// Session 2: Fill your code here
//---------------------------------------------------------------------------------------------------
prog
: Class Program '{' field_decls method_decls '}'
{
	System.out.print(symbolTable);
	System.out.println("------------------------------------");
	System.out.print(quadTable);
}
;

field_decls 
: f=field_decls field_decl ';'
{

}
| f=field_decls inited_field_decl ';'
{

}
|
{

}
;

field_decl returns [DataType t]
: f=field_decl ',' Ident
{
	$t = $f.t;
	symbolTable.addUserVariable($Ident.text, $t);
}
| f=field_decl ',' Ident '[' num ']'
{

}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	symbolTable.addUserVariable($Ident.text, $t);
	
}
| Type Ident '[' num ']'
{

}
;

inited_field_decl returns [int id]
: Type Ident '=' literal
{

}
;

method_decls returns [int id]
: m=method_decls method_decl
{

}
|
{
	
}
;

method_decl
: Type Ident '(' params ')' block
{
	symbolTable.addUserVariable($Ident.text, DataType.valueOf($Type.text.toUpperCase()));
}
| Void Ident '(' params ')' block
{
	symbolTable.addUserVariable($Ident.text, DataType.VOID);
}
;

params
: Type Ident nextParams
{

}
|
{

}
;

nextParams
: n=nextParams ',' Type Ident
{

}
|
{

}
;

block 
: '{' var_decls statements '}'
;

var_decls 
: v=var_decls var_decl ';'
| 
;

var_decl returns [DataType t]
: v=var_decl ',' Ident
{
	$t = $v.t;
	symbolTable.addUserVariable($Ident.text, $t);
}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	symbolTable.addUserVariable($Ident.text, $t);
	
}
;

statements 
: statement t=statements
|
;

// TODO: previously the rule was "location '=' expr ';'"
statement
: location eqOp expr ';'
{
	quadTable.add($location.id, $expr.id, -1, "=");
}
| If '(' expr ')' block
{

}
| If '(' expr ')' b1=block Else b2=block
{

}
| For Ident '=' e1=expr ',' e2=expr block
{

}
| Ret ';'
{

}
| Ret '(' expr ')' ';'
{

}
| Brk ';'
{

}
| Cnt ';'
{

}
| block
{

}
| methodCall ';'
{

}
;

methodCall
: Ident '(' args ')'
{
	
}
| Callout '(' Str calloutArgs ')'
{

}
;

args
: someArgs
{

}
|
{

}
;

someArgs
: t=someArgs ',' expr
{

}
| expr
{

}
;

calloutArgs
: c=calloutArgs ',' expr
{

}
| c=calloutArgs ',' Str
{

}
|
{

}
;

expr returns [int id]
: literal
{
	$id = $literal.id;
}
| location
{
	$id = $location.id;
}
| '(' e=expr ')'
{
	$id = $e.id;
}
| SubOp e=expr
{
	$id = symbolTable.addTemporary(symbolTable.getType($e.id));
	int zeroSymbol = symbolTable.addUserVariable("0", DataType.INT);
    quadTable.add($id, zeroSymbol, $e.id, $SubOp.text);
}
// | '!' e=expr
// {
// 	$id = symbolTable.addTemporary(symbolTable.getType($e1.id));
//     quadTable.add($id, $e1.id, $e2.id, $MulDiv.text);

// 	$id = PrintNode("Not_expr");
// 	PrintEdge($id, $e.id);
// }
| e1=expr MulDiv e2=expr
{
	$id = symbolTable.addTemporary(symbolTable.getType($e1.id));
    quadTable.add($id, $e1.id, $e2.id, $MulDiv.text);
}
| e1=expr AddOp e2=expr
{
	$id = symbolTable.addTemporary(symbolTable.getType($e1.id));
    quadTable.add($id, $e1.id, $e2.id, $AddOp.text);
}
| e1=expr SubOp e2=expr
{
	$id = symbolTable.addTemporary(symbolTable.getType($e1.id));
    quadTable.add($id, $e1.id, $e2.id, $SubOp.text);
}
| e1=expr RelOp e2=expr
{
	$id = symbolTable.addTemporary(symbolTable.getType($e1.id));
    quadTable.add($id, $e1.id, $e2.id, $RelOp.text);
}
//| e1=expr AndOp e2=expr
//{
//	$id = symbolTable.addTemporary(symbolTable.getType($e1.id));
//    quadTable.add($id, $e1.id, $e2.id, $AndOp.text);
//}
//| e1=expr OrOp e2=expr
//{
//	$id = symbolTable.addTemporary(symbolTable.getType($e1.id));
//    quadTable.add($id, $e1.id, $e2.id, $OrOp.text);
//}
//| methodCall
//{
//	$id = PrintNode("Call_expr");
//
//	PrintEdge($id, $methodCall.id);
//}
;

location returns [int id]
: Ident
{
	$id = symbolTable.find($Ident.text);
}
// | Ident '[' expr ']'
// {

// }
;

num
: DecNum
| HexNum
;

literal returns [int id]
: num
{
	$id = symbolTable.addUserVariable($num.text, DataType.INT);
}
// | Char
// | BoolLit
;

eqOp
: '='
| AssignOp
;

//--------------------------------------------- END OF SESSION 2 -----------------------------------

//---------------------------------------------------------------------------------------------------
// Session 3: Lexical definition, You SHOULD NOT make any modification to this session
//---------------------------------------------------------------------------------------------------
fragment Delim
: ' '
| '\t'
| '\n'
| '\r'
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

MulDiv
: '*'
| '/'
| '%'
;

AddOp
: '+'
;

SubOp
: '-'
;

AndOp
: '&&'
;

OrOp
: '||'
;