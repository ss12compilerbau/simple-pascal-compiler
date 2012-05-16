// *****************************
// ***  Code-generation API  ***
// *****************************

// ***** Register allocation API ******
var cgRegisterUsage: ^Longint;
Var outputfile: Text;

// cgRequestRegister() reserves a register and returns its number.
Var cgRequestRegisterRet: Longint;
Procedure cgRequestRegister();
var i: Longint;
Begin
    cgRequestRegisterRet := -1;
    i := 0;
    while ((cgRegisterUsage[i] = cTrue) AND (i<32)) do begin
        i := i+1;
    end;
    if i < 32 then begin
        cgRegisterUsage[i] := cTrue;
        cgRequestRegisterRet := i;
    end else begin
        Writeln('ERROR: Register allocation failed, all registers taken!');
    end;
End;

// cgReleaseRegister(i) releases register i
Procedure cgReleaseRegister(i: Longint);
Begin
    if i = 0 then begin
        errorMsg('cgReleaseRegister: Register 0 cannot be released!');
    end else begin
        cgRegisterUsage[i] := cFalse;
    end;
End;

// Initialize the register allocation API related variables
Procedure cgRegAllocInit();
Var i: Longint;
Begin
    infoMsg('cgRegAllocInit called');
    New(cgRegisterUsage);
    i := 0;
    while i<31 do begin
        cgRegisterUsage[i] := cFalse;
        i := i + 1;
    end;
    cgRegisterUsage[0] := cTrue;
    cgRegisterUsage[28] := cTrue; // Reserved for Global Variable address pointer
End;


// ***** Code emitting ******
Type 
    ptCodeline = ^tCodeline;
    tCodeline = Record
        op: String;
        a: Longint;
        b: Longint;
        c: Longint;
        rem: String;
    End;
Var cgCodeLines: Array of ptCodeLine; // Array
Var pc: Longint;

procedure cgPut(op: String; a: Longint; b: Longint; c: Longint; rem: String);
begin
    New(cgCodeLines[PC]);
    cgCodeLines[PC]^.op := op;
    cgCodeLines[PC]^.a := a;
    cgCodeLines[PC]^.b := b;
    cgCodeLines[PC]^.c := c;
    cgCodeLines[PC]^.rem := rem;
    Writeln(op, ', ', a, ', ', b, ', ', c, '; ', rem);
    PC := PC + 1;
End;
procedure cgCodegenInit();
Begin
    setLength(cgCodeLines, 1000);
    PC := 0;
End;

procedure cgCodegenFinish();
Var i: Longint;
Begin
    Assign(outputfile, 'out.asm');
    Rewrite(outputfile);
    i := 0;
    While i < PC Do Begin
        Writeln(outputfile, cgCodelines[i]^.op, ', ', cgCodelines[i]^.a, ', ', cgCodelines[i]^.b, ', ', cgCodelines[i]^.c, '; ', cgCodelines[i]^.rem);
        i := i + 1;
    End;
    close(outputfile);
End;

// ***** Item API ****
Type
    ptItem = ^tItem;
    tItem = Record
        fMode: Longint; // one of mCONST, mVAR, mREG, mREF
        fType: ptType;
        fReg: Longint; // reg[reg] + offset -> address
        fOffset: Longint;
        fValue: Longint;
        fOperator: Longint; // Operator token
        fls: Longint;
        tru: Longint;
    end;

var mCONST: Longint;
var mVar: Longint;
var mREG: Longint;
var mREF: Longint;

// Initialize the ITEM API related parts
Procedure cgItemInit();
Begin
    mCONST := 1;
    mVAR := 2;
    mREG := 3;
    mREF := 4;
End;

procedure const2Reg(item: ptItem);
Begin
    item^.fMode := mREG;
    cgRequestRegister;
    item^.fReg := cgRequestRegisterRet;
    // assumes_ R0 = 0
    cgPut('ADDI', item^.fReg, 0, item^.fValue, 'cg Const2Reg');
    item^.fValue := 0;
    item^.fOffset := 0;
End;

procedure var2Reg(item: ptItem);
Begin
    if item^.fMode <> mVar then begin
        errorMsg('var2Reg: item is not in VAR mode!');
    end else begin
        item^.fMode := mREG;
        cgRequestRegister;
        cgPut('LDW', cgRequestRegisterRet, item^.fReg, item^.fOffset, 'cg var2Reg');
        item^.fReg := cgRequestRegisterRet;
    end;
End;

procedure ref2Reg(item: ptItem);
Begin
    Writeln('var2Reg not yet implemented!');
end;

procedure cgLoad(item: ptItem);
Begin
    if item^.fMode = mCONST then begin
        const2Reg(item);
    end else begin 
        if item^.fMode = mVAR then begin
            var2Reg(item);
        end else begin 
            if item^.fMode = mREF then begin
                ref2Reg(item);
            end;
        end;
    end;
End;

procedure cgAssignmentOperator(leftItem: ptItem; rightItem: ptItem);
Begin
    if(leftItem^.fType <> rightItem^.fType) then begin
        errorMsg('Type mismatch in assignment');
    End;
    cgLoad(rightItem);

    // leftItem must be in VAR_MODE, rightItem must be in REG_MODE
    cgPut('STW', rightItem^.fReg, leftItem^.fReg, leftItem^.fOffset, 'assignmentOperator');
    cgReleaseRegister(rightItem^.fReg);
End;

Var cgTermRet: Longint;
procedure cgTerm( leftItem: ptItem; rightItem: ptItem; op: longint);
	var ret: longint;
	var bothLongint: longint;
	var bothBool: longint;
begin
	// both Items longint ?
	bothLongint := cTrue;
	if leftItem^.fType <> stLongintType THEN begin
		bothLongint := cFalse;
	end;
	if rightItem^.fType <> stLongintType then begin
		bothLongint := cFalse;
	end;
	
	// both Items mBool ?
	bothBool := cTrue;
	if leftItem^.fType <> stBooleanType THEN begin
		bothBool := cFalse;
	end;
	if rightItem^.fType <> stBooleanType then begin
		bothBool := cFalse;
	end;
	
	ret := cTrue;
	if bothLongInt = cTrue then begin
		if rightItem^.fMode = mConst then begin
			if leftItem^.fMode = mConst then begin
				// z.B. 6 * 7 * 2
				if op = cTimes then begin
					leftItem^.fValue := leftItem^.fValue * rightItem^.fValue;
				end;
				if op = cColon then begin
					leftItem^.fValue := leftItem^.fValue DIV rightItem^.fValue
				end;
			end
			else begin
				// z.B. i * 3
				cgLoad( leftItem);
				if op = cTimes then begin
					cgPut('MULI', leftItem^.fReg, leftItem^.fReg, rightItem^.fValue, 'cgTerm');
				end;
				if op = cColon then begin
					cgPut('DIVI', leftItem^.fReg, leftItem^.fReg, rightItem^.fValue, 'cgTerm');
				end;
			end;
		end
		else begin
			// z.B. 3 * j oder i * j
			cgLoad( leftItem);
			cgLoad( rightItem);
			if op = cTimes then begin
				cgPut('MUL', leftItem^.fReg, leftItem^.fReg, rightItem^.fReg, 'cgTerm');
			end;
			if op = cColon then begin
				cgPut('DIV', leftItem^.fReg, leftItem^.fReg, rightItem^.fReg, 'cgTerm');
			end;
			cgReleaseRegister(rightItem^.fReg);
		end;
	end
	else begin
		if bothBool = cTrue then begin
			// AND
			if op = cAND then begin
				if( (leftItem^.fValue = cTrue) AND (rightItem^.fValue = cTrue)) then begin
					leftItem^.fValue := cTrue;
				end
				else begin
					leftItem^.fValue := cFalse;
				end
			end
			else begin
				errorMsg( 'cgTerm: boolean expressions expected');
			ret := cFalse;
			end;
		end
		else begin
			errorMsg( 'cgTerm: Integer expressions expected');
			ret := cFalse;
		end;
	end;
	cgTermRet := ret;
end;

Var cgSimpleExpressionRet: Longint;
procedure cgSimpleExpression( leftItem: ptItem; rightItem: ptItem; op: longint);
	var ret: longint;
	var bothLongint: longint;
	var bothBool: longint;
begin
	// both Items longint ?
	bothLongint := cTrue;
	if leftItem^.fType <> stLongintType THEN begin
		bothLongint := cFalse;
	end;
	if rightItem^.fType <> stLongintType then begin
		bothLongint := cFalse;
	end;
	
	// both Items mBool ?
	bothBool := cTrue;
	if leftItem^.fType <> stBooleanType THEN begin
		bothBool := cFalse;
	end;
	if rightItem^.fType <> stBooleanType then begin
		bothBool := cFalse;
	end;
	
	ret := cTrue;
	if bothLongInt = cTrue then begin
		if rightItem^.fMode = mConst then begin
			if leftItem^.fMode = mConst then begin
				// z.B. 6 + 7 + 2
				if op = cPlus then begin
					leftItem^.fValue := leftItem^.fValue + rightItem^.fValue;
				end;
				if op = cMinus then begin
					leftItem^.fValue := leftItem^.fValue - rightItem^.fValue
				end;
			end
			else begin
				// z.B. i + 3
				cgLoad( leftItem);
				if op = cPlus then begin
					cgPut('ADDI', leftItem^.fReg, leftItem^.fReg, rightItem^.fValue, 'cgSimpleExpression');
				end;
				if op = cMinus then begin
					cgPut('SUBI', leftItem^.fReg, leftItem^.fReg, rightItem^.fValue, 'cgSimpleExpression');
				end;
			end;
		end
		else begin
			// z.B. 3 + j oder i + j
			cgLoad( leftItem);
			cgLoad( rightItem);
			if op = cPlus then begin
				cgPut('ADD', leftItem^.fReg, leftItem^.fReg, rightItem^.fReg, 'cgSimpleExpression');
			end;
			if op = cMinus then begin
				cgPut('SUB', leftItem^.fReg, leftItem^.fReg, rightItem^.fReg, 'cgSimpleExpression');
			end;
			cgReleaseRegister(rightItem^.fReg);
		end;
	end
	else begin
		if bothBool = cTrue then begin
			// OR
			if op = cOR then begin
				if( (leftItem^.fValue = cTrue) OR (rightItem^.fValue = cTrue)) then begin
					leftItem^.fValue := cTrue;
				end
				else begin
					leftItem^.fValue := cFalse;
				end
			end
			else begin
				errorMsg( 'cgSimpleExpression-1: boolean expressions expected');
				ret := cFalse;
			end;
		end
		else begin
			errorMsg( 'cgSimpleExpression-2: Integer expressions expected');
			ret := cFalse;
		end;
	end;
	cgSimpleExpressionRet := ret;
end;


Var cgExpressionRet: Longint;
procedure cgExpression( leftItem: ptItem; rightItem: ptItem; op: longint);
	var ret: longint;
	var bothLongint: longint;
	var expr: longint;
begin

	// both Items longint ?
	bothLongint := cTrue;
	if leftItem^.fType <> stLongintType THEN begin
		bothLongint := cFalse;
	end;
	if rightItem^.fType <> stLongintType then begin
		bothLongint := cFalse;
	end;
	
	ret := cTrue;
	if bothLongInt = cTrue then begin
		if rightItem^.fMode = mConst then begin
			if leftItem^.fMode = mConst then begin
				// 3 = 4
				leftItem^.fType := stBooleanType;
				expr := cFalse;
				
				if op = cLss then begin // <
					if leftItem^.fValue < rightItem^.fValue then begin
						expr := cTrue;
					end;
				end;
				if op = cLeq then begin // <=
					if leftItem^.fValue <= rightItem^.fValue then begin
						expr := cTrue;
					end;
				end;
				if op = cEql then begin	// =
					if leftItem^.fValue = rightItem^.fValue then begin
						expr := cTrue;
					end;
				end;
				if op = cNeq then begin	// # i.e. <>
					if leftItem^.fValue <> rightItem^.fValue then begin
						expr := cTrue;
					end;
				end;
				if op = cGeq then begin	// >=
					if leftItem^.fValue >= rightItem^.fValue then begin
						expr := cTrue;
					end;
				end;
				if op = cGtr then begin	// >
					if leftItem^.fValue > rightItem^.fValue then begin
						expr := cTrue;
					end;
				end;
				leftItem^.fValue := expr;
			end
			else begin
				errorMsg( 'cgExpression-1: Constant Integer expressions expected');
				ret := cFalse;
			end;
		end
		else begin
			errorMsg( 'cgExpression-2: Constant Integer expressions expected');
			ret := cFalse;
		end;
	end
	
	else begin
		errorMsg( 'cgExpression-6: Integer expressions expected');
		ret := cFalse;
	end;

	cgExpressionRet := ret;
end;


// cEql -> BNE
// cNeq -> BEQ
// cLss -> BGE
// cGeq -> BLT
// cLeq -> BGT
// cGtr -> BLE
Var branchNegateRet: String;
Procedure branchNegate(operatorSymbol: Longint);
Begin
    if operatorSymbol = cEql then begin branchNegateRet := 'BNE';end;
    if operatorSymbol = cNeq then begin branchNegateRet := 'BEQ';end;
    if operatorSymbol = cLss then begin branchNegateRet := 'BGE';end;
    if operatorSymbol = cGeq then begin branchNegateRet := 'BLT';end;
    if operatorSymbol = cLeq then begin branchNegateRet := 'BGT';end;
    if operatorSymbol = cGtr then begin branchNegateRet := 'BLE';end;
End;

// Conditional Jump, to be fixed up later
Procedure cJump(item: ptItem);
Begin
    branchNegate(item^.fOperator);
    cgPut(branchNegateRet, item^.fReg, 0, item^.fls, 'cJump');
    cgReleaseRegister(item^.fReg);
    item^.fls := PC - 1;// Remember address of branch instruction for later fixup
End;

Var fJumpRet: Longint;
Procedure fJump();
Begin
    cgPut('BR', 0,0,0, 'fJump');
    fJumpRet := PC - 1;// remember address for later fixup
End;

Procedure fixUp(branchAddress: Longint);
Begin
    cgCodeLines[branchAddress]^.c := PC - branchAddress;
    cgCodeLines[branchAddress]^.rem := cgCodeLines[branchAddress]^.rem + ' /fixedUp/';
End;

Procedure fixLink(branchAddress: Longint);
Var nextBranchAddress: Longint;
Begin
    while(branchAddress <> 0) do begin
        nextBranchAddress := cgCodelines[branchAddress]^.c;
        fixUp(branchAddress);
        branchAddress := nextBranchAddress;
    end;
End;


// Initialize Parts of this module
Procedure cgInit();
Begin
    cgCodegenInit;
    cgRegAllocInit;
    cgItemInit;
    // cgPut('ADDI', 1,1,2, 'Test');
End;

Procedure cgEnd();
Begin
    cgCodegenFinish;
End;

