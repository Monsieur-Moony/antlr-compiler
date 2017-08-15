/*************************************************
 * Course: CMPT 379 Compilers - Summer 2017      *
 * Instructor: ***REMOVED*** ***REMOVED***                        *
 *                                               *
 * Author: Karan Sharma                          *
 * ID: ***REMOVED***                                 *
 * Email: ***REMOVED***                           *
 *************************************************/
package x86;

public class Quad {
	Symbol label;
	String op;
	Symbol src1;
	Symbol src2;
	Symbol dst;

	public Quad (SymStack s, int l, Symbol d, Symbol s1, Symbol s2, String o) {
		label = s.Add(l);
		dst = d;
		src1 = s1;
		src2 = s2;
		op = o;
	}

	public Quad (Symbol l) {
		label = l;
		dst = null;
		src1 = null;
		src2 = null;
		op = "";
	}

	public void BackPatch (Symbol l) {
		dst = l;
	}

	public Symbol GetLabel () {
		return label;
	}

	public void Print () {
		System.out.print(label.GetName() + ": ");
		if (dst != null) System.out.print(dst.GetName());
		if (src1 != null) System.out.print(" = " + src1.GetName());
		System.out.print(" " + op + " ");
		if (src2 != null) System.out.print(src2.GetName());
		System.out.println("");
	}

	public void AsmPrint () {
		System.out.print(label.GetName() + ": ");

		switch (op) {
			case "":
				System.out.println("push %rbp");
				System.out.println("mov %rsp, %rbp");
				break;
			case "frame":
				System.out.println("sub " + dst.AsmPrint() + ", %rsp");
				break;
			case "call":
				System.out.println("call " + src1.GetName());
				break;
			case "callexp":
				System.out.println("call " + src1.GetName());
				StoreSrc1(dst);
				break;
			case "ret":
				if (src1 != null) System.out.println("mov -" + src1.GetOffset() + "(%rbp), %rax");
				System.out.println("add $" + dst.GetName() + ", %rsp");
				System.out.println("pop %rbp");
				System.out.println("ret");
				break;
			case "=":
				ReadSrc1(src1);
				WriteDst(dst);
				break;
			case "+":
				ReadSrc1(src1);
				ReadSrc2(src2);
				Compute("add");
				WriteDst(dst);
				break;
			case "-":
				ReadSrc1(src1);
				ReadSrc2(src2);
				Compute("sub");
				WriteDst(dst);
				break;
			case "*":
				ReadSrc1(src1);
				ReadSrc2(src2);
				System.out.println("mulq %rbx");
				WriteDst(dst);
				break;
			case "/":
				System.out.println("mov $0, %rdx");
				ReadSrc1(src1);
				ReadSrc2(src2);
				System.out.println("idiv %rbx");
				WriteDst(dst);
				break;
			case "[]":
				ReadSrc1(src1);
				ReadSrc2(src2);
				Compute("add");
				System.out.println("mov (%rax), %rbx");
				StoreSrc2(dst);
				break;
			case "[]=":
				ReadSrc1(dst);
				ReadSrc2(src1);
				Compute("add");
				ReadSrc2(src2);
				System.out.println("mov %rbx, (%rax)");
				break;
			case "goto":
				System.out.println("jmp " + dst.GetName());
				break;
			case "je":
			case "jg":
			case "jge":
			case "jl":
			case "jle":
			case "jne":
				System.out.println(op + " " + dst.GetName());
				break;
			case "cmp":
				ReadSrc1(src1);
				ReadSrc2(src2);
				System.out.println("cmp %rax, %rbx");
				break;
			default:
				if (op.startsWith("push")) { // e.g. when op is "push %rdi"
					String sourceReg = op.substring(op.lastIndexOf(" ") + 1);
					System.out.println("mov " + sourceReg + ", " + src2.AsmPrint());
				} else {
					if (dst != null) { // e.g. when op is "rsi", "rdi" etc
						System.out.println("mov " + dst.AsmPrint() + ", %" + op);
					}
				}
		}
	}

	void Compute (String opcode) {
		System.out.println(opcode + " %rbx, %rax");
	}

	void ReadSrc1 (Symbol src) {
		System.out.println("mov " + src.AsmPrint() + ", %rax");
	}

	void StoreSrc1 (Symbol dst) {
		System.out.println("mov %rax, " + dst.AsmPrint());
	}

	void ReadSrc2 (Symbol src) {
		System.out.println("mov " + src.AsmPrint() + ", %rbx");
	}

	void StoreSrc2 (Symbol dst) {
		System.out.println("mov %rbx, " + dst.AsmPrint());
	}

	void WriteDst (Symbol dst) {
		System.out.println("mov %rax, " + dst.AsmPrint());
	}
}