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
	import java.util.List;
	import java.util.ArrayList;
	import java.util.Set;
	import java.util.HashSet;
}

@parser::members {
	public enum ElemType {
		VOID(0),
		INT(4),
		CHAR(1),
		BOOLEAN(1),
		INVALID(0);

		private String width;

		ElemType(int width) {
			this.width = String.valueOf(width);
		}

		public String getWidth() {
			return width;
		}
	}

	public class DataType {
		private ElemType elemType;
		private String size;

		public DataType(ElemType elemType, String size) {
			this.elemType = elemType;
			this.size = size;
		}

		public DataType(ElemType elemType) {
			this(elemType, null);
		}

		public ElemType getElem() {
			return elemType;
		}

		@Override
		public String toString() {
			if (size != null) {
				return "ARRAY(" + size + "," + elemType + ")";
			}
			return elemType.toString();
		}
	}

	public class Symbol {
		private String name;
		private DataType type;

		private static final String TEMP_VAR_PREFIX = "t~";

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
			return name + "\t\t" + type;
		}
	}

	public static final int INITIAL_CAPACITY = 100;
	public static int temporariesCounter = 0;

	public class SymbolTable {
		private SymbolTable parent;
		private List<SymbolTable> children;
		private List<Symbol> symbols;

		public SymbolTable(SymbolTable parent) {
			this.parent = parent;
			this.children = new ArrayList<>();
			this.symbols = new ArrayList<>(INITIAL_CAPACITY);
		}

		public SymbolTable() {
			this(null);
		}

		public Symbol addUserVariable(String name, DataType type) {
			Symbol foundSymbol = searchList(name);
			if (foundSymbol != null) {
				return foundSymbol;
			}
			Symbol newSymbol = new Symbol(name, type);
			symbols.add(newSymbol);
			return newSymbol;
		}

		public Symbol addIntConstant(String name) {
			return addUserVariable(name, new DataType(ElemType.INT));
		}

		public Symbol addTemporary(DataType type) {
			Symbol newSymbol = new Symbol(temporariesCounter, type);
			symbols.add(newSymbol);
			temporariesCounter++;
			return newSymbol;
		}

		private Symbol searchList(String name) {
			for (int i = 0; i < symbols.size(); i++) {
				Symbol currentSymbol = symbols.get(i);
				if (currentSymbol.getName().equals(name)) {
					return currentSymbol;
				}
			}
			return null;
		}

		public Symbol lookup(String name) {
			for (SymbolTable s = this; s != null; s = s.getParent()) {
				Symbol foundSymbol = s.searchList(name);
				if (foundSymbol != null) {
					return foundSymbol;
				}
			}
			return null;
		}

		public SymbolTable createChild() {
			SymbolTable child = new SymbolTable(this);
			this.children.add(child);
			return child;
		}

		public SymbolTable createChild(SymbolTable child) {
			child.setParent(this);
			this.children.add(child);
			return child;
		}

		public void setParent(SymbolTable parent) {
			this.parent = parent;
		}

		public SymbolTable getParent() {
			return this.parent;
		}

		public DataType getType(Symbol symbol) {
			if (symbol == null) {
				return new DataType(ElemType.INVALID);
			}
			return symbol.getType();
		}

		public String getName(Symbol symbol) {
			if (symbol == null) {
				return "";
			}
			return symbol.getName();
		}

		@Override
		public String toString() {
			StringBuilder sb = new StringBuilder();
			for (Symbol symbol : symbols) {
				sb.append(symbol);
				sb.append("\n");
			}
			for (int i = 0; i < children.size(); i++) {
				SymbolTable currentSymTab = children.get(i);
				sb.append("\n");
				sb.append(currentSymTab);
			}
			return sb.toString();
		}
	}

	public SymbolTable symbolTable = new SymbolTable();
	public SymbolTable nextChild = null;

	public void createScope() {
		if (nextChild != null) {
			symbolTable = symbolTable.createChild(nextChild);
		} else {
			symbolTable = symbolTable.createChild();
		}
	}

	public void exitScope() {
		symbolTable = symbolTable.getParent();
		nextChild = null;
	}

	public class Quad {
		private int label;
		private String op;
		private Symbol src1;
		private Symbol src2;
		private Symbol dst;

		Quad (int label, Symbol dst, Symbol src1, Symbol src2, String op) {
			this.label = label;
			this.dst = dst;
			this.src1 = src1;
			this.src2 = src2;
			this.op = op;
		}

		private boolean isControl() {
			return op.equals("if") || op.equals("ifFalse") || op.equals("goto");
		}

		public boolean isUnpatched() {
			return isControl() && dst == null;
		}

		public Symbol getDst() {
			return dst;
		}

		public void setDst(Symbol dst) {
			this.dst = dst;
		}

		@Override
		public boolean equals(Object otherObj) {
			if (otherObj == null || (this.getClass() != otherObj.getClass())) {
				return false;
			}
			Quad otherQuad = (Quad) otherObj;
			return this.label == otherQuad.label;
		}

		@Override
		public int hashCode() {
			return label;
		}

		@Override
		public String toString() {
			StringBuilder sb = new StringBuilder();
			if (op.equals("method")) { // eg. <function_name>:
				sb.append(symbolTable.getName(dst));
				sb.append(":");
			} else {
				sb.append("L_");
				sb.append(label);
				sb.append(": ");
				if (op.equals("call")) {
					if (dst != null) {
						sb.append(symbolTable.getName(dst));
						sb.append(" = ");
					}
					sb.append(op);
					sb.append(" ");
					sb.append(symbolTable.getName(src1));
					sb.append(" ");
					sb.append(symbolTable.getName(src2));
				} else if (op.equals("ret")) {
					sb.append(op);
					if (src1 != null) {
						sb.append(" ");
						sb.append(symbolTable.getName(src1));
					}
				} else if (op.equals("[]=")) { // array write
					sb.append(symbolTable.getName(dst));
					sb.append("[ ");
					sb.append(symbolTable.getName(src1));
					sb.append(" ]");
					sb.append(" = ");
					sb.append(symbolTable.getName(src2));
				} else if (op.equals("=[]")) { // array read
					sb.append(symbolTable.getName(dst));
					sb.append(" = ");
					sb.append(symbolTable.getName(src1));
					sb.append("[ ");
					sb.append(symbolTable.getName(src2));
					sb.append(" ]");
				} else {
					sb.append(symbolTable.getName(dst));
					if (op.equals("param")) { // eg. L_0: <symbol_name> param
						sb.append(symbolTable.getName(src1));
						sb.append(" ");
						sb.append(op);
					} else {
						sb.append(" = ");
						sb.append(symbolTable.getName(src1));
						// Check to prevent trailing " = " for assignment quads
						// eg. L_0: <var> = <value>
						if (!op.equals("=")) {
							sb.append(" ");
							sb.append(op);
							sb.append(" ");
							sb.append(symbolTable.getName(src2));
						}
					}
				}
			}
			return sb.toString();
		}
	}

	public class QuadTable {
		private List<Quad> quads;

		QuadTable () {
			quads = new ArrayList<>(INITIAL_CAPACITY);
		}

		public Quad add(Symbol dst, Symbol src1, Symbol src2, String op) {
			Quad newQuad = new Quad(quads.size(), dst, src1, src2, op);
			quads.add(newQuad);
			return newQuad;
		}

		private void backpatch(Quad srcQuad, Quad dstQuad) {
			if (srcQuad.isUnpatched()) {
				srcQuad.setDst(dstQuad.getDst());
			}
		}

		public void backpatch(Set<Quad> srcQuads, Quad dstQuad) {
			for (Quad quad : srcQuads) {
				backpatch(quad, dstQuad);
			}
		}

		public void backpatchAll(Quad dstQuad) {
			for (Quad quad : quads) {
				backpatch(quad, dstQuad);
			}
		}

		@Override
		public String toString() {
			StringBuilder sb = new StringBuilder();
			for (Quad quad : quads) {
				sb.append(quad);
				sb.append("\n");
			}
			return sb.toString();
		}
	}

	public String stripQuotes(String quotedString) {
		return quotedString.substring(1, (quotedString.length() - 1));
	}

	public QuadTable quadTable = new QuadTable();
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
| f=field_decls inited_field_decl ';'
|
;

field_decl returns [DataType t]
: f=field_decl ',' Ident
{
	$t = $f.t;
	symbolTable.addUserVariable($Ident.text, $t);
}
| f=field_decl ',' Ident '[' num ']'
{
	$t = $f.t;
	DataType compoundType = new DataType($t.getElem(), $num.text);
	symbolTable.addUserVariable($Ident.text, compoundType);
}
| Type Ident
{
	$t = new DataType(ElemType.valueOf($Type.text.toUpperCase()));
	symbolTable.addUserVariable($Ident.text, $t);
}
| Type Ident '[' num ']'
{
	ElemType baseType = ElemType.valueOf($Type.text.toUpperCase());
	$t = new DataType(baseType);
	DataType compoundType = new DataType(baseType, $num.text);
	symbolTable.addUserVariable($Ident.text, compoundType);
}
;

inited_field_decl
: Type Ident '=' literal
{
	DataType type = new DataType(ElemType.valueOf($Type.text.toUpperCase()));
	Symbol decl = symbolTable.addUserVariable($Ident.text, type);
	quadTable.add(decl, $literal.id, null, "=");
}
;

method_decls returns [int id]
: m=method_decls method_decl
|
;

method_decl
: Type Ident
{
	DataType type = new DataType(ElemType.valueOf($Type.text.toUpperCase()));
	Symbol method = symbolTable.addUserVariable($Ident.text, type);
	quadTable.add(method, null, null, "method");
} '(' params ')' block
| Void Ident
{
	DataType type = new DataType(ElemType.VOID);
	Symbol method = symbolTable.addUserVariable($Ident.text, type);
	quadTable.add(method, null, null, "method");
} '(' params ')' block
;

params
: Type Ident
{
	nextChild = new SymbolTable();
	DataType type = new DataType(ElemType.valueOf($Type.text.toUpperCase()));
	nextChild.addUserVariable($Ident.text, type);
} nextParams
|
;

nextParams
: n=nextParams ',' Type Ident
{
	DataType type = new DataType(ElemType.valueOf($Type.text.toUpperCase()));
	nextChild.addUserVariable($Ident.text, type);
}
|
;

block 
: '{' { createScope(); } var_decls statements '}' { exitScope(); }
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
	$t = new DataType(ElemType.valueOf($Type.text.toUpperCase()));
	symbolTable.addUserVariable($Ident.text, $t);
}
;

statements 
: statement t=statements
|
;

statement
: location '=' expr ';'
{
	if ($location.offset == null) { // non-array location
		quadTable.add($location.id, $expr.id, null, "=");
	} else {
		quadTable.add($location.id, $location.offset, $expr.id, "[]=");
	}
}
| location AssignOp expr ';'
{
	// Use fist character from the lexeme as operator
	// E.g. op for "+=" is "+"
	String op = $AssignOp.text.substring(0, 1);
	if ($location.offset == null) { // non-array location
		Symbol temp = symbolTable.addTemporary(symbolTable.getType($location.id));
		quadTable.add(temp, $location.id, $expr.id, op);
		quadTable.add($location.id, temp, null, "=");
	} else {
		DataType type = new DataType(symbolTable.getType($location.id).getElem());
		Symbol temp1 = symbolTable.addTemporary(type);
		quadTable.add(temp1, $location.id, $location.offset, "=[]");

		Symbol temp2 = symbolTable.addTemporary(type);
		quadTable.add(temp2, temp1, $expr.id, op);
		quadTable.add($location.id, $location.offset, temp2, "[]=");
	}
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
    quadTable.add(null, null, null, "ret");
}
| Ret '(' expr ')' ';'
{
    quadTable.add(null, $expr.id, null, "ret");
}
| Brk ';'
{

}
| Cnt ';'
{

}
| block
| methodCall ';'
{
	Symbol count = symbolTable.addIntConstant(String.valueOf($methodCall.count));
	quadTable.add(null, $methodCall.id, count, "call");
}
;

methodCall returns [Symbol id, int count]
: Ident '(' args ')'
{
	$id = symbolTable.lookup($Ident.text);
	$count = $args.count;
}
| Callout '(' Str calloutArgs ')'
{
	DataType type = new DataType(ElemType.VOID);
	$id = symbolTable.addUserVariable(stripQuotes($Str.text), type);
	$count = $calloutArgs.count;
}
;

args returns [int count]
: someArgs
{
	$count = $someArgs.count;
}
|
{
	$count = 0;
}
;

someArgs returns [int count]
: t=someArgs ',' expr
{
	quadTable.add(null, $expr.id, null, "param");
	$count = $t.count + 1;
}
| expr
{
	quadTable.add(null, $expr.id, null, "param");
	$count = 1;
}
;

calloutArgs returns [int count]
: c=calloutArgs ',' expr
{
	quadTable.add(null, $expr.id, null, "param");
	$count = $c.count + 1;
}
| c=calloutArgs ',' Str
{
	String strLength = String.valueOf($Str.text.length() - 2); // quotes are not part of char array
	DataType type = new DataType(ElemType.CHAR, strLength);
	Symbol str = symbolTable.addUserVariable($Str.text, type);
	quadTable.add(null, str, null, "param");
	$count = $c.count + 1;
}
|
{
	$count = 0;
}
;

expr returns [Symbol id]
: literal
{
	$id = $literal.id;
}
| location
{
	if ($location.offset == null) { // non-array location
		$id = $location.id;
	} else {
		DataType type = new DataType(symbolTable.getType($location.id).getElem());
		$id = symbolTable.addTemporary(type);
		quadTable.add($id, $location.id, $location.offset, "=[]");
	}
}
| '(' e=expr ')'
{
	$id = $e.id;
}
| SubOp e=expr
{
	$id = symbolTable.addTemporary(symbolTable.getType($e.id));
	Symbol zeroSymbol = symbolTable.addIntConstant("0");
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
| methodCall
{
	Symbol count = symbolTable.addIntConstant(String.valueOf($methodCall.count));
	$id = symbolTable.addTemporary(symbolTable.getType($methodCall.id));
	quadTable.add($id, $methodCall.id, count, "call");
}
;

location returns [Symbol id, Symbol offset]
: Ident
{
	$id = symbolTable.lookup($Ident.text);
	$offset = null;
}
| Ident '[' expr ']'
{
	$id = symbolTable.lookup($Ident.text);
	DataType type = symbolTable.getType($id);
	$offset = symbolTable.addTemporary(new DataType(type.getElem()));
	Symbol typeWidth = symbolTable.addIntConstant(type.getElem().getWidth());
	quadTable.add($offset, typeWidth, $expr.id, "*");
}
;

num
: DecNum
| HexNum
;

literal returns [Symbol id]
: num
{
	$id = symbolTable.addIntConstant($num.text);
}
| Char
{
	int charValue = (int) $Char.text.charAt(0);
	$id = symbolTable.addUserVariable(String.valueOf(charValue), new DataType(ElemType.CHAR));
}
| BoolLit
{
	$id = symbolTable.addUserVariable($BoolLit.text, new DataType(ElemType.BOOLEAN));
}
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