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
}

@parser::members {
	public enum DataType {
		INT, BOOLEAN, INVALID
	}

	public static final String TEMP_VAR_PREFIX = "~t";

	public class Symbol {
		private String name;
		private DataType type;

		public Symbol(String name, DataType type) {
			this.name = name;
			this.type = type;
		}

		public Symbol(int id, DataType type) {
			this.name = TEMP_VAR_PREFIX + id;
			this.type = type;
		}

		public DataType getType() {
			return this.type;
		}

		public String getName() {
			return this.name;
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
			return this.name.hashCode();
		}

		@Override
		public String toString() {
			return this.name + "\t" + this.type;
		}
	}

	public static final int INITIAL_MAX_SYMBOLS = 100;
	public static final int CAPACITY_EXPAND_FACTOR = 2;

	public class SymbolTable {
		private int symbols[];
		private int size;
		private int capacity;
		private int temporariesCounter;

		public SymbolTable(int capacity) {
			this.capacity = capacity;
			this.size = 0;
			this.symbols = new Symbol[this.capacity];
			this.temporariesCounter = 0;
		}

		private void expandCapacity() {
			capacity = capacity * CAPACITY_EXPAND_FACTOR;
			tempSymbols = this.symbols;
			this.symbols = new Symbol[this.capacity];
			for (int i = 0; i < capacity; i++) {
				this.symbols[i] = tempSymbols[i];
			}
		}

		public int addUserVariable(String name, DataType type) {
			if (size + 1 > capacity) {
				this.expandCapacity();
			}
			// check if newSymbol exists in table already, return null if true
			symbols[size] = new Symbol(name, type);
			return size++;
		}

		public int addTemporary(DataType type) {
			if (size + 1 > capacity) {
				this.expandCapacity();
			}
			symbols[size] = new Symbol(temporariesCounter, type);
			temporariesCounter++;
			return size++;
		}

		public DataType getType(int index) {
			return (index < 0 ? DataType.INVALID : symbols[index].getType());
		}

		@Override
		public String toString() {
			StringBuilder sb = new StringBuilder();
			for (Symbol symbol : symbols) {
				sb.append(symbol + "\n")
			}
			return sb.toString();
		}
	}

	public class SymTab {
		Symbol st[];
		int size;
		int temps;

		SymTab () {
			st = new Symbol[1000];
			size = 0;
			temps = 0;
		}

		int Find (String n) {
			for (int  i = 0; i < size; i ++) {
				if (st[i].Equal(n)) return i;
			}
			
			return -1;
		}

		int insert(String n, DataType d) {
			int id = Find(n);
			if (id != -1) return id;

			st[size] = new Symbol(n, d);
			return (size ++);
		}

		int Add (DataType d) {
			st [size] = new Symbol (temps, d);
			temps ++;
			return (size ++);
		}

		DataType GetType (int id) {
			if (id == -1) return DataType.INVALID;
			return (st[id].GetType());
		}

		String GetName (int id) {
			if (id == -1) return ("");
			return (st[id].GetName()); 
		}

		void Print() {
			for (int  i = 0; i < size; i ++) {
				st[i].Print();
			}
		}
	}

	SymTab s = new SymTab();

	public class Quad {
		int label;
		String op;
		int src1;
		int src2;
		int dst;

		Quad (int l, int d, int s1, int s2, String o) {
			label = l;
			dst = d;
			src1 = s1;
			src2 = s2;
			op = o;
		}

		void Print () {
			System.out.println("L_" + label + ": " + s.GetName(dst) + " = " 
					+ s.GetName(src1) + " " + op + " " + s.GetName(src2));
		}
	}

	public class QuadTab {
		Quad qt[];
		int size;

		QuadTab () {
			qt = new Quad[1000];
			size = 0;
		}

		int Add(int dst, int src1, int src2, String op) {
			qt[size] = new Quad(size, dst, src1, src2, op);
			return (size ++);
		}

		void Print() {
			for (int  i = 0; i < size; i ++) {
				qt[i].Print();
			}
		}
	}

	QuadTab q = new QuadTab();
}

//---------------------------------------------------------------------------------------------------
// Session 2: Fill your code here
//---------------------------------------------------------------------------------------------------
prog
: Class Program '{' field_decls method_decl '}'
{
	s.Print();
	System.out.println("------------------------------------");
	q.Print();
}
;

field_decls 
: f=field_decls field_decl ';'
| 
;

field_decl returns [DataType t]
: f=field_decl ',' Ident
{
	$t = $f.t;
	s.insert($Ident.text, $t);
}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t);					
	
}
;

method_decl 
: Type Ident '('  ')' block
{
	s.insert($Ident.text, DataType.valueOf($Type.text.toUpperCase()));
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
	s.insert($Ident.text, $t);
}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t);					
	
}
;

statements 
: statement t=statements
|
;

statement 
: location '=' expr ';'
{
	q.Add($location.id, $expr.id, -1, "=");
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
| e1=expr '+' e2=expr
{
	$id = s.Add(s.GetType($e1.id));
	q.Add($id, $e1.id, $e2.id, "+");
}
;

location returns [int id]
:Ident
{
	$id = s.Find($Ident.text);
}
;

num
: DecNum
| HexNum
;

literal returns [int id]
: num
{
	$id = s.insert($num.text, DataType.INT);
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

Type
: 'int'
| 'boolean'
;

Ident
: Alpha AlphaNum* 
;
