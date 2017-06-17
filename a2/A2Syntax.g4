/*************************************************
 * Course: CMPT 379 Compilers - Summer 2017      *
 * Instructor: ***REMOVED*** ***REMOVED***                        *
 *                                               *
 * Author: Karan Sharma                          *
 * ID: ***REMOVED***                                 *
 * Email: ***REMOVED***                           *
 *************************************************/
 // NOTE: Changes to Sessions 1 and 3 were made with the instructor's permission
 
grammar A2Syntax;

//---------------------------------------------------------------------------------------------------
// Session 1: ANTLR tree plotting API, You SHOULD NOT make any modification to this session
//---------------------------------------------------------------------------------------------------
@header {

import java.io.*;
}

@parser::members {
	//AST node count
	int count = 0;
	String graph = "";

	int GetId() {
		return count++;
	}
	
	public class MySet {
		int[] ids;
		int size;

		MySet () {
			System.out.println("\n\nInitArray\n-------------");

			ids = new int [100];		
			size = 0;
		}

		void ExtendArray(int val) {
			System.out.println("\n\nExtendArray\n-------------\nsize = " + size + "\nval = " + val);

			ids[size] = val;
			size ++;
		}

		void AppendArray(MySet s) {
			for (int i = 0; i < s.size; i ++) {
				ExtendArray(s.ids[i]);
			}
		}
	} //MySet

	String ProcessString(String s) {
		String x = "\\" + s.substring(0, s.length() - 1) + "\\\"";
		return x;
	}

	int PrintNode (String label) {
		System.out.println("\n\nPrintNode\n-------------\nlabel = " + label + "\nid = " + count);

		int id = GetId();
		graph += (id + " [label=\"" + label + "\"]\n");
		return id;
	}

	void PrintEdge (int id1, int id2) {
		System.out.println("\n\nPrintEdge\n-------------\nid1 = " + id1 + "\nid2 = " + id2);
		
		if ((id1 != -1) && (id2 != -1)) graph += (id1 + " -> " + id2 + "\n");
	}

	void PrintEdges (int id, MySet s) {
		System.out.println("\n\nPrintEdges\n-------------\nid = " + id + "\nsize = " + s.size);
		
		for (int i = 0; i < s.size; i ++) {
			PrintEdge(id, s.ids[i]);
		}
	}

	void PrintGraph () throws IOException {
		System.out.println("\n\nPrintGraph\n-------------");

		File file = new File("test.dot");
		file.createNewFile();
		FileWriter writer = new FileWriter(file); 
		writer.write("digraph G {\nordering=out\n" + graph + "\n}\n"); 
		writer.flush();
		writer.close();

		System.out.println("digraph G {\nordering=out\n" + graph + "\n}\n");
	}
}


//---------------------------------------------------------------------------------------------------
// Session 2: Fill the Grammer definition here
//---------------------------------------------------------------------------------------------------
prog
: Class Program '{' field_decls method_decls '}'
{
	int selfId = PrintNode($Program.text);

	if ($field_decls.s.size > 0) {
		int fieldDeclId = PrintNode("Field_decls");
		PrintEdges(fieldDeclId, $field_decls.s);
		PrintEdge(selfId, fieldDeclId);
	}

	if ($method_decls.s.size > 0) {
		int methodDeclId = PrintNode("Method_decls");
		PrintEdges(methodDeclId, $method_decls.s);
		PrintEdge(selfId, methodDeclId);
	}

	try {
		PrintGraph();
	} catch (IOException e) {
		// do nothing
	}
}
;

field_decls returns [MySet s]
: f=field_decls field_decl ';'
{
	$s = $f.s;
	$s.ExtendArray($field_decl.id);
}
| f=field_decls inited_field_decl ';'
{
	$s = $f.s;
	$s.ExtendArray($inited_field_decl.id);
}
| 
{
	$s = new MySet();
}
;

field_decl returns [int id]
: f=field_decl ',' Ident ('[' Num ']')?
{
	$id = $f.id;

	PrintEdge($f.id, PrintNode($Ident.text));
	if ($Num != null) {
		PrintEdge($id, PrintNode($Num.text));
	}
}
| Type Ident ('[' Num ']')?
{
	$id = PrintNode("Field_decl");

	PrintEdge($id, PrintNode($Type.text));
	PrintEdge($id, PrintNode($Ident.text));
	if ($Num != null) {
		PrintEdge($id, PrintNode($Num.text));
	}
}
;

inited_field_decl returns [int id]
: Type Ident '=' literal
{
	$id = PrintNode("Inited_field_decl");

	PrintEdge($id, PrintNode($Type.text));
	PrintEdge($id, PrintNode($Ident.text));
	PrintEdge($id, PrintNode($literal.text));
}
;

method_decls returns [MySet s]
: m=method_decls method_decl
{
	$s = $m.s;
	$s.ExtendArray($method_decl.id);
}
|
{
	$s = new MySet();
}
;

method_decl returns [int id]
: Type Ident '(' params ')' block
{
	$id = PrintNode("Method_decl");

	PrintEdge($id, PrintNode($Type.text));
	PrintEdge($id, PrintNode($Ident.text));
	PrintEdge($id, $params.id);
	PrintEdge($id, $block.id);	
}
| Void Ident '(' params ')' block
{
	$id = PrintNode("Method_decl");

	PrintEdge($id, PrintNode($Void.text));
	PrintEdge($id, PrintNode($Ident.text));
	PrintEdge($id, $params.id);
	PrintEdge($id, $block.id);
}
;

params returns [int id]
: Type Ident nextParams
{
	$id = PrintNode("Method_args");
	
	PrintEdge($id, PrintNode($Type.text));
	PrintEdge($id, PrintNode($Ident.text));
	PrintEdges($id, $nextParams.s);
}
|
{
	$id = -1;
}
;

nextParams returns [MySet s]
: n=nextParams ',' Type Ident
{
	$s = $n.s;
	
	$s.ExtendArray(PrintNode($Type.text));
	$s.ExtendArray(PrintNode($Ident.text));
}
|
{
	$s = new MySet();
}
;

block returns [int id]
: '{' var_decls statements '}'
{
	$id = -1;
	if ($var_decls.s.size > 0) {
		$id = PrintNode("Block");
		int id2 = PrintNode("Var_decls");
		PrintEdges(id2, $var_decls.s);
		PrintEdge($id, id2);
	}
	if ($statements.id != -1) {
		if ($id == -1) $id = PrintNode("Block");
		PrintEdge($id, $statements.id);
	}
}
;

var_decls returns [MySet s]
: v=var_decls var_decl ';'
{
	$s = $v.s;
	$s.ExtendArray($var_decl.id);
}
| 
{
	$s = new MySet();
}
;


var_decl returns [int id]
: v=var_decl ',' Ident
{
	$id = $v.id;
	PrintEdge($id, PrintNode($Ident.text));
}
| Type Ident
{
	$id = PrintNode("Var_decl");

	PrintEdge($id, PrintNode($Type.text));
	PrintEdge($id, PrintNode($Ident.text));
}
;

statements returns [int id]
: statement t=statements
{
	if ($t.id != -1) {
		$id = PrintNode("Seq");
		PrintEdge($id, $statement.id);
		PrintEdge($id, $t.id);
	} else {
		$id = $statement.id;
	}
}
|
{
	$id = -1;
}
;

statement returns [int id]
: location assignOp expr ';'
{
	$id = PrintNode("Assign");

	PrintEdge($id, $location.id);
	PrintEdge($id, PrintNode($assignOp.text));
	PrintEdge($id, $expr.id);
}
| method_call ';'
{
	$id = PrintNode("Call");

	PrintEdge($id, $method_call.id);
}
| If '(' expr ')' b1=block (Else b2=block)?
{
	$id = PrintNode("If");

	PrintEdge($id, $expr.id);
	PrintEdge($id, $b1.id);

	if ($Else != null) {
		PrintEdge($id, $b2.id);
	}
}
| For Ident '=' e1=expr ',' e2=expr block
{
	$id = PrintNode("For");

	PrintEdge($id, PrintNode($Ident.text));
	PrintEdge($id, $e1.id);
	PrintEdge($id, $e2.id);
	PrintEdge($id, $block.id);
}
| Ret (expr)? ';'
{
	$id = PrintNode($Ret.text);

	if ($expr.ctx != null) {
		PrintEdge($id, $expr.id);
	}
}
| Brk ';'
{
	$id = PrintNode($Brk.text);
}
| Cnt ';'
{
	$id = PrintNode($Cnt.text);
}
| block
{
	$id = $block.id;
}
;

method_call returns [int id]
: Ident '(' call_args ')'
{
	$id = PrintNode("User_meth");

	PrintEdge($id, PrintNode($Ident.text));
	PrintEdge($id, $call_args.id);
}
| Callout '(' Str callout_args ')'
{
	$id = PrintNode("Ext_meth");
	int callExprId = PrintNode("Call_expr");

	PrintEdge($id, PrintNode(ProcessString($Str.text)));
	PrintEdge($id, callExprId);
	PrintEdges(callExprId, $callout_args.s);
}
;

callout_args returns [MySet s]
: c=callout_args ',' callout_arg
{
	$s = $c.s;
	$s.ExtendArray($callout_arg.id);
}
|
{
	$s = new MySet();
};

callout_arg returns [int id]
: expr
{
	$id = PrintNode("Expr_arg");

	PrintEdge($id, $expr.id);
}
| Str
{
	$id = PrintNode("String_arg");

	PrintEdge($id, PrintNode(ProcessString($Str.text)));
};

call_args returns [int id]
: expr next_call_args
{
	$id = PrintNode("Call_expr");

	int exprArgId = PrintNode("Expr_arg");
	PrintEdge(exprArgId, $expr.id);
	PrintEdge($id, exprArgId);
	PrintEdges($id, $next_call_args.s);
}
|
{
	$id = -1;
};

next_call_args returns [MySet s]
: n=next_call_args ',' expr
{
	$s = $n.s;
	int exprArgId = PrintNode("Expr_arg");

	PrintEdge(exprArgId, $expr.id);
	$s.ExtendArray(exprArgId);
}
|
{
	$s = new MySet();
};

expr returns [int id]
: logical_or_expr
{
	$id = $logical_or_expr.id;
}
;

logical_or_expr returns [int id]
: lo=logical_or_expr Or logical_and_expr
{
	$id = PrintNode("Bin_expr");

	PrintEdge($id, $lo.id);
	PrintEdge($id, PrintNode($Or.text));
	PrintEdge($id, $logical_and_expr.id);
}
| logical_and_expr
{
	$id = $logical_and_expr.id;
}
;

logical_and_expr returns [int id]
: la=logical_and_expr And equality_expr
{
	$id = PrintNode("Bin_expr");

	PrintEdge($id, $la.id);
	PrintEdge($id, PrintNode($And.text));
	PrintEdge($id, $equality_expr.id);
}
| equality_expr
{
	$id = $equality_expr.id;
}
;

equality_expr returns [int id]
: e=equality_expr EqOp rel_expr
{
	$id = PrintNode("Bin_expr");

	PrintEdge($id, $e.id);
	PrintEdge($id, PrintNode($EqOp.text));
	PrintEdge($id, $rel_expr.id);
}
| rel_expr
{
	$id = $rel_expr.id;
}
;

rel_expr returns [int id]
: r=rel_expr RelOp additive_expr
{
	$id = PrintNode("Bin_expr");

	PrintEdge($id, $r.id);
	PrintEdge($id, PrintNode($RelOp.text));
	PrintEdge($id, $additive_expr.id);
}
| additive_expr
{
	$id = $additive_expr.id;
}
;

additive_expr returns [int id]
: a=additive_expr addOp multiplicative_expr
{
	$id = PrintNode("Bin_expr");

	PrintEdge($id, $a.id);
	PrintEdge($id, PrintNode($addOp.text));
	PrintEdge($id, $multiplicative_expr.id);
}
| multiplicative_expr
{
	$id = $multiplicative_expr.id;
}
;

multiplicative_expr returns [int id]
: m=multiplicative_expr MultOp unary_expr
{
	$id = PrintNode("Bin_expr");

	PrintEdge($id, $m.id);
	PrintEdge($id, PrintNode($MultOp.text));
	PrintEdge($id, $unary_expr.id);
}
| unary_expr
{
	$id = $unary_expr.id;
}
;

unary_expr returns [int id]
: '-' u=unary_expr
{
	$id = PrintNode("Neg_expr");

	PrintEdge($id, $u.id);
}
| '!' u=unary_expr
{
	$id = PrintNode("Not_expr");

	PrintEdge($id, $u.id);
}
| primary_expr
{
	$id = $primary_expr.id;
}
;

primary_expr returns [int id]
: method_call
{
	$id = PrintNode("Call");

	PrintEdge($id, $method_call.id);
}
| literal
{
	$id = PrintNode("Const_expr");

	PrintEdge($id, PrintNode($literal.text));
}
| location
{
	$id = PrintNode("Loc_expr");

	PrintEdge($id, $location.id);
}
| '(' expr ')'
{
	$id = $expr.id;
}
;

location returns [int id]
:Ident
{
	$id = PrintNode("Loc");

	PrintEdge($id, PrintNode($Ident.text));
}
| Ident '[' expr ']'
{
	$id = PrintNode("Array_loc");

	PrintEdge($id, PrintNode($Ident.text));
	PrintEdge($id, $expr.id);
}
;

//--------------------------------------------- END OF SESSION 2 -----------------------------------


//---------------------------------------------------------------------------------------------------
// Session 3: Lexical definition, You SHOULD NOT make any modification to this session
//---------------------------------------------------------------------------------------------------
literal
: Num
| Char
| BoolLit
;

assignOp
: '+='
| '-='
| '='
;

addOp
: '+'
| '-'
;

Num
: DecNum
| HexNum
;

EqOp
: '=='
| '!='
;

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
;

MultOp
: '*'
| '/'
| '%'
;

And
: '&&'
;

Or
: '||'
;
