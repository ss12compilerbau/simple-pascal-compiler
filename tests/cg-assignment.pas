Program simple;
Var i: Longint;
Var j: Longint;
begin
 // i := 12;
 // j := 3 * 4 * 5;
 // j := 100 : 10;
 // j := i * 3;
 // j := 3 * i;
 // j := i * j;
 
 
	i := 3 * 4 + 5 * (6 - 4);
    (* 16.5.2012
    ADDI, 1, 0, 22; cg Const2Reg
	STW, 1, 28, 0; assignmentOperator
	*)
    
    i := i - 5;
    j := 1;
	j := 3 * i + j * (23 - i);
    (* 16.5.2012
    ADDI, 1, 0, 3; cg Const2Reg
	LDW, 2, 28, 0; cg var2Reg
	MUL, 1, 1, 2; cgTerm
	ADDI, 2, 0, 13; cg Const2Reg
	LDW, 3, 28, 0; cg var2Reg
	SUB, 2, 2, 3; cgSimpleExpression
	LDW, 3, 28, 0; cg var2Reg
	MUL, 3, 3, 2; cgTerm
	DIVI, 3, 3, 4; cgTerm
	ADD, 1, 1, 3; cgSimpleExpression
	STW, 1, 28, 0; assignmentOperator
	*)
	    Writeln(i);
    Writeln(j);
//  j := i + 3;
//  j := 3 + i;
end.

