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

    // Constants for use as labels of AST nodes
    public static final String ASTNode_Program          = "Program";
    public static final String ASTNode_FieldDecls       = "Field_decls";
    public static final String ASTNode_FieldDecl        = "Field_decl";
    public static final String ASTNode_InitedFieldDecl  = "Inited_field_decl";
    public static final String ASTNode_MethodDecls      = "Method_decls";
    public static final String ASTNode_MethodDecl       = "Method_decl";
    public static final String ASTNode_MethodArgs       = "Method_args";
    public static final String ASTNode_Block            = "Block";
    public static final String ASTNode_VarDecls         = "Var_decls";
    public static final String ASTNode_VarDecl          = "Var_decl";
    public static final String ASTNode_Seq              = "Seq";
    public static final String ASTNode_Assign           = "Assign";
    public static final String ASTNode_Call             = "Call";
    public static final String ASTNode_If               = "If";
    public static final String ASTNode_IfElse           = "If_Else";
    public static final String ASTNode_For              = "For";
    public static final String ASTNode_Ret              = "Ret";
    public static final String ASTNode_Brk              = "Break";
    public static final String ASTNode_Cont             = "Cont";
    public static final String ASTNode_UserMeth         = "User_meth";
    public static final String ASTNode_ExtMeth          = "Ext_meth";
    public static final String ASTNode_Loc              = "Loc";
    public static final String ASTNode_ArrayLoc         = "Array_loc";
    public static final String ASTNode_LocExpr          = "Loc_expr";
    public static final String ASTNode_CallExpr         = "Call_expr";
    public static final String ASTNode_ConstExpr        = "Const_expr";
    public static final String ASTNode_BinExpr          = "Bin_expr";
    public static final String ASTNode_NegExpr          = "Neg_expr";
    public static final String ASTNode_NotExpr          = "Not_expr";
    public static final String ASTNode_StringArg        = "String_arg";
    public static final String ASTNode_ExprArg          = "Expr_arg";
}

//---------------------------------------------------------------------------------------------------
// Session 2: Fill the Grammer definition here
//---------------------------------------------------------------------------------------------------
prog
: Class Program '{' field_decls method_decls '}'
{
    int selfId = PrintNode(ASTNode_Program);

    if ($field_decls.s.size > 0) {
        int fieldDeclId = PrintNode(ASTNode_FieldDecls);
        PrintEdges(fieldDeclId, $field_decls.s);
        PrintEdge(selfId, fieldDeclId);
    }

    if ($method_decls.s.size > 0) {
        int methodDeclId = PrintNode(ASTNode_MethodDecls);
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
    $id = PrintNode(ASTNode_FieldDecl);

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
    $id = PrintNode(ASTNode_InitedFieldDecl);

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
    $id = PrintNode(ASTNode_MethodDecl);

    PrintEdge($id, PrintNode($Type.text));
    PrintEdge($id, PrintNode($Ident.text));
    PrintEdge($id, $params.id);
    PrintEdge($id, $block.id);  
}
| Void Ident '(' params ')' block
{
    $id = PrintNode(ASTNode_MethodDecl);

    PrintEdge($id, PrintNode($Void.text));
    PrintEdge($id, PrintNode($Ident.text));
    PrintEdge($id, $params.id);
    PrintEdge($id, $block.id);
}
;

params returns [int id]
: Type Ident nextParams
{
    $id = PrintNode(ASTNode_MethodArgs);
    
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
        $id = PrintNode(ASTNode_Block);
        int id2 = PrintNode(ASTNode_VarDecls);
        PrintEdges(id2, $var_decls.s);
        PrintEdge($id, id2);
    }
    if ($statements.id != -1) {
        if ($id == -1) $id = PrintNode(ASTNode_Block);
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
        $id = PrintNode(ASTNode_Seq);
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
    $id = PrintNode(ASTNode_Assign);

    PrintEdge($id, $location.id);
    PrintEdge($id, PrintNode($assignOp.text));
    PrintEdge($id, $expr.id);
}
| method_call ';'
{
    $id = PrintNode(ASTNode_Call);

    PrintEdge($id, $method_call.id);
}
| If '(' expr ')' b1=block (Else b2=block)?
{
    if ($Else != null) {
        $id = PrintNode(ASTNode_IfElse);
    } else {
        $id = PrintNode(ASTNode_If);
    }

    PrintEdge($id, $expr.id);
    PrintEdge($id, $b1.id);

    if ($Else != null) {
        PrintEdge($id, $b2.id);
    }
}
| For Ident '=' e1=expr ',' e2=expr block
{
    $id = PrintNode(ASTNode_For);

    PrintEdge($id, PrintNode($Ident.text));
    PrintEdge($id, $e1.id);
    PrintEdge($id, $e2.id);
    PrintEdge($id, $block.id);
}
| Ret (expr)? ';'
{
    $id = PrintNode(ASTNode_Ret);

    if ($expr.ctx != null) {
        PrintEdge($id, $expr.id);
    }
}
| Brk ';'
{
    $id = PrintNode(ASTNode_Brk);
}
| Cnt ';'
{
    $id = PrintNode(ASTNode_Cont);
}
| block
{
    $id = $block.id;
}
;

method_call returns [int id]
: Ident '(' call_args ')'
{
    $id = PrintNode(ASTNode_UserMeth);

    PrintEdge($id, PrintNode($Ident.text));
    PrintEdge($id, $call_args.id);
}
| Callout '(' Str callout_args ')'
{
    $id = PrintNode(ASTNode_ExtMeth);
    int callExprId = PrintNode(ASTNode_CallExpr);
    int stringArgId = PrintNode(ASTNode_StringArg);

    PrintEdge($id, stringArgId);
    PrintEdge(stringArgId, PrintNode(ProcessString($Str.text)));
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
}
;

callout_arg returns [int id]
: expr
{
    $id = PrintNode(ASTNode_ExprArg);

    PrintEdge($id, $expr.id);
}
| Str
{
    $id = PrintNode(ASTNode_StringArg);

    PrintEdge($id, PrintNode(ProcessString($Str.text)));
}
;

call_args returns [int id]
: expr next_call_args
{
    $id = PrintNode(ASTNode_CallExpr);

    int exprArgId = PrintNode(ASTNode_ExprArg);
    PrintEdge(exprArgId, $expr.id);
    PrintEdge($id, exprArgId);
    PrintEdges($id, $next_call_args.s);
}
|
{
    $id = -1;
}
;

next_call_args returns [MySet s]
: n=next_call_args ',' expr
{
    $s = $n.s;
    int exprArgId = PrintNode(ASTNode_ExprArg);

    PrintEdge(exprArgId, $expr.id);
    $s.ExtendArray(exprArgId);
}
|
{
    $s = new MySet();
}
;

// Precedence levels (low to high):
//      ||
//      &&
//      == !=
//      < <= > >=
//      + -
//      * / %
//      - ! <unary>
//      <method call> <literal> <location> ()
expr returns [int id]
: logical_or_expr
{
    $id = $logical_or_expr.id;
}
;

logical_or_expr returns [int id]
: lo=logical_or_expr Or logical_and_expr
{
    $id = PrintNode(ASTNode_BinExpr);

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
    $id = PrintNode(ASTNode_BinExpr);

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
    $id = PrintNode(ASTNode_BinExpr);

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
    $id = PrintNode(ASTNode_BinExpr);

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
    $id = PrintNode(ASTNode_BinExpr);

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
    $id = PrintNode(ASTNode_BinExpr);

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
    $id = PrintNode(ASTNode_NegExpr);

    PrintEdge($id, $u.id);
}
| '!' u=unary_expr
{
    $id = PrintNode(ASTNode_NotExpr);

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
    $id = PrintNode(ASTNode_Call);

    PrintEdge($id, $method_call.id);
}
| literal
{
    $id = PrintNode(ASTNode_ConstExpr);

    PrintEdge($id, PrintNode($literal.text));
}
| location
{
    $id = PrintNode(ASTNode_LocExpr);

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
    $id = PrintNode(ASTNode_Loc);

    PrintEdge($id, PrintNode($Ident.text));
}
| Ident '[' expr ']'
{
    $id = PrintNode(ASTNode_ArrayLoc);

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
