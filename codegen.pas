// *****************************
// ***  Code-generation API  ***
// *****************************

// ***** Register allocation API ******
var cgRegisterUsage: ^Longint;
Var outputfile: Text;

Var PC: Longint;
Var GP: Longint; // global pointer (first byte over the global variables = bottom of heap)
Var FP: Longint; // frame pointer
Var SP: Longint; // frame pointer
Var HP: Longint; // heap pointer
Var RR: Longint;
Var LINK: Longint;

procedure cgPut(op: String; a: Longint; b: Longint; c: Longint; rem: String);forward;

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
        errorMsg('cgRequestRegister: Register allocation failed, all registers taken!');
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

Procedure cgPushUsedRegisters;
Var i: Longint;
Begin
    i := 1;
    while i < 25 do begin
        if cgRegisterUsage[i] = cTrue then begin
            cgPut('PSH', i, SP, 4, 'cgPushUsedRegisters');
        end;
    end;
End;

Procedure cgPopUsedRegisters;
Var i: Longint;
Begin
    i := 25;
    while i > 0 do begin
        if cgRegisterUsage[i] = cTrue then begin
            cgPut('POP', i, SP, 4, 'cgPopUsedRegisters');
        end;
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
    cgRegisterUsage[GP] := cTrue; // Reserved for Global Variable address pointer
    cgRegisterUsage[FP] := cTrue;
    cgRegisterUsage[SP] := cTrue;
    cgRegisterUsage[HP] := cTrue; // Reserved for Heap address pointer
    cgRegisterUsage[LINK] := cTrue;
    cgRegisterUsage[RR] := cTrue;

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
    GP := 28;
    FP := 27;
    HP := 29;
    SP := 30;
    RR := 26;
    LINK := 31;
    cgPut('SUBI', GP, GP, 0, 'Reserve command to shift space for global variables');
    cgPut('ADDI', HP, GP, 0, 'Set Heap beginning');
End;

procedure cgCodegenFinish();
Var i: Longint;
Begin
    cgCodeLines[0]^.c := stGlobalScope^.fSP;
    cgPut('EXT', 0, 0, 0, 'Exit program');
    Assign(outputfile, 'out.asm');
    Rewrite(outputfile);
    i := 0;
    While i < PC Do Begin
        Writeln(outputfile, cgCodelines[i]^.op, ' ', cgCodelines[i]^.a, ',', cgCodelines[i]^.b, ',', cgCodelines[i]^.c, '; ', cgCodelines[i]^.rem);
        i := i + 1;
    End;
    close(outputfile);
End;

Var cgIsBSRRet: Longint;
Procedure cgIsBSR(address: Longint);
Begin
    if cgCodeLines[address]^.op = 'BSR' then begin
        cgIsBSRRet := cTrue;
    end else begin
        cgIsBSRRet := cFalse;
    end;

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
        fFls: Longint;
        fTru: Longint;
    end;

var mCONST: Longint;
var mVar: Longint;
var mREG: Longint;
var mREF: Longint;
var mCOND: Longint;


// Initialize the ITEM API related parts
Procedure cgItemInit();
Begin
    mCONST := 1;
    mVAR := 2;
    mREG := 3;
    mREF := 4;
    mCOND := 5;
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
        item^.fOffset := 0;
    end;
End;

procedure ref2Reg(item: ptItem);
Begin
    item^.fMode := mReg;
    cgPut('LDW', item^.fReg, item^.fReg, item^.fOffset, 'ref2Reg');
    item^.fOffset := 0;
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

Procedure cgLoadBool(item: ptItem);
Begin
    if item^.fMode <> mCOND then begin
        cgLoad(item);
        item^.fMode := mCOND;
        item^.fOperator := cNeq;
        item^.fFls := 0;
        item^.fTru := 0;
    end;
end;

Procedure cgSetLength(item: ptItem; lengthItem: ptItem);
Begin
    cgPut('STW', HP, item^.fReg, item^.fOffset, 'cgSetLength');
    cgLoad(lengthItem);
    cgPut('MULI', lengthItem^.fReg, lengthItem^.fReg, 4, 'cgSetLength'); // TODO Replace 4 by sizeof(item^.fType)
    cgPut('ADD', HP, HP, lengthItem^.fReg, 'cgSetLength');
    cgReleaseRegister(lengthItem^.fReg);
End;

Procedure cgNew(item: ptItem);
Begin
    //TODO
    // stSizeOf(item)
    cgPut('STW', HP, GP, item^.fOffset, 'cgSetLength');
    // cgPut('ADDI', HP, HP, sizeofRet, 'cgNew');
End;

Var cgEmitStringRet: Longint;
Procedure cgEmitString(str: String);
// var len: Longint;
Begin
    // len := length(str);
    cgEmitStringRet := PC;
    cgPut('BR', 0, 0, 6, 'emitString');
    cgPut('STR', 0, 0, 5, str);
    cgPut(';', 0,0,0,'noop');
    cgPut(';', 0,0,0,'noop');
    cgPut(';', 0,0,0,'noop');
    cgPut(';', 0,0,0,'noop');
End;

Procedure cgWrite(item: ptItem);
begin
    cgLoad(item);
    if item^.fType = stLongintType then begin
        cgPut('WRN', item^.fReg,0,0,'Write longint');
    end;
    if item^.fType = stStringType then begin
        cgPut('WRS', item^.fReg, 0,0,'Write String');
    end;
end;

Procedure cgWriteCR;
begin
    cgPut('WCR', 0,0,0,'Write Carriage Return');
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
    cgPut(branchNegateRet, item^.fReg, 0, item^.fFls, 'cJump');
    cgReleaseRegister(item^.fReg);
    item^.fFls := PC - 1;// Remember address of branch instruction for later fixup
End;

Procedure bJump(backAddress: Longint);
Begin
    cgPut('BR', 0,0, backAddress - PC, 'bJump');
End;

Var fJumpRet: Longint;
Procedure fJump();
Begin
    cgPut('BR', 0,0,0, 'fJump');
    fJumpRet := PC - 1;// remember address for later fixup
End;

Procedure cgFixUp(branchAddress: Longint);
Begin
    cgCodeLines[branchAddress]^.c := PC - branchAddress;
    cgCodeLines[branchAddress]^.rem := cgCodeLines[branchAddress]^.rem + ' /fixedUp/';
End;

Procedure cgFixLink(branchAddress: Longint);
Var nextBranchAddress: Longint;
Begin
    while(branchAddress <> 0) do begin
        nextBranchAddress := cgCodelines[branchAddress]^.c;
        cgFixUp(branchAddress);
        branchAddress := nextBranchAddress;
    end;
End;

Var sJumpRet: Longint;
procedure sJump(branchAddress: Longint);
begin
    cgPut('BSR', 0,0,branchAddress, 'sJump');
    sJumpRet := PC - 1;
end;

procedure cgAssignmentOperator(leftItem: ptItem; rightItem: ptItem);
Begin
    if(leftItem^.fType <> rightItem^.fType) then begin
        errorMsg('Type mismatch in assignment');
    End;
    if rightItem^.fMode = mCond then begin
        cJump(rightItem);
        cgFixLink(rightItem^.fTru);
        rightItem^.fMode := mReg;
        cgPut('ADDI', rightItem^.fReg, 0,1, 'cgAssignmentOperator');
        cgPut('BR', 0,0,2, 'cgAssignmentOperator');
        cgFixLink(rightItem^.fFls);
        cgPut('ADDI', rightItem^.fReg, 0, 0, 'cgAssignmentOperator');
    end else begin
        cgLoad(rightItem);
    end;

    // leftItem must be in VAR_MODE, rightItem must be in REG_MODE
    cgPut('STW', rightItem^.fReg, leftItem^.fReg, leftItem^.fOffset, 'assignmentOperator');

    cgReleaseRegister(rightItem^.fReg);
    if leftItem^.fMode = mRef then begin
        cgReleaseRegister(leftItem^.fReg);
    end;
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
				if op = cDiv then begin
					leftItem^.fValue := leftItem^.fValue DIV rightItem^.fValue
				end;
			end
			else begin
				// z.B. i * 3
				cgLoad( leftItem);
				if op = cTimes then begin
					cgPut('MULI', leftItem^.fReg, leftItem^.fReg, rightItem^.fValue, 'cgTerm');
				end;
				if op = cDiv then begin
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
			if op = cDiv then begin
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
begin
    if leftItem^.fType = rightItem^.fType then begin
        if leftItem^.fType = stLongintType then begin
            // Longints
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
        end else begin
            if leftItem^.fType = stBooleanType then begin
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
            end else begin
			    errorMsg( 'cgSimpleExpression: Boolean or Longint expressions expected');
            end;
        end;
    end else begin
        errorMsg('cgSimpleExpression: Type mismatch!');
		ret := cFalse;
    end;
	cgSimpleExpressionRet := ret;
end;


Var cgExpressionRet: Longint;
procedure cgExpression( leftItem: ptItem; rightItem: ptItem; op: longint);
	var ret: longint;
begin
    if ((leftItem^.fType = stLongintType) and (rightItem^.fType = stLongintType)) then begin
        cgLoad(leftItem);
        if((rightItem^.fMode <> mCONST) or (rightItem^.fValue <> 0)) then begin
            cgLoad(rightItem);
            cgPut('CMP', leftItem^.fReg, leftItem^.fReg, rightItem^.fReg, 'cgExpression');
            cgReleaseRegister(rightItem^.fReg);
        end;
        leftItem^.fMode := mCOND;
        leftItem^.fType := stBooleanType;
        leftItem^.fOperator := op;
        leftItem^.fFls := 0;
        leftItem^.fTru := 0;
        ret := cTrue;
    end else begin
        errorMsg('cgExpression: Longint expression expected!');
		ret := cFalse;
    end;

	cgExpressionRet := ret;
end;

Procedure cgIndex(item: ptItem; indexItem: ptItem);
Begin
    if indexItem^.fMode = mConst then begin
        cgLoad(item);
        item^.fMode := mRef;
        item^.fOffset := indexItem^.fValue * 4;
    end else begin
        cgLoad(indexItem);
        cgPut('MULI', indexItem^.fReg, indexItem^.fReg, 4, 'cgIndex');

        cgLoad(item);
        item^.fMode := mREF;
        // item^.fOffset := 0;
        cgPut('ADD', item^.fReg, item^.fReg, indexItem^.fReg, 'cgIndex');
        cgReleaseRegister(indexItem^.fReg);
    end;
    item^.fType := item^.fType^.fBase;
end;

procedure cgPrologue(localsize: Longint);
Begin
    cgPut('PSH', LINK, SP, 4, 'cgPrologue: save return address');
    cgPut('PSH', FP, SP, 4, 'cgPrologue: save callers frame');
    cgPut('ADD', FP, 0, SP, 'cgPrologue: allocate callees frame');
    cgPut('SUBI', SP, SP, localsize, 'cgPrologue: Allocate callees local variables');
End;

procedure cgEpilogue(paramsize: Longint);
Begin
    cgPut('ADD', SP, 0, FP, 'cgEpilogue: Deallocate callees frame and local variables');
    cgPut('POP', FP, SP, 4, 'cgEpilogue: Restore callers frame');
    cgPut('POP', LINK, SP, paramsize + 4, 'cgEpilogue: Restore return address, deallocate parameters');
    cgPut('RET', 0, 0, LINK, 'cgEpilogue: Return');
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

