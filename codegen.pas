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
    cgRegisterUsage[i] := cFalse;
End;

// Initialize the register allocation API related variables
Procedure cgRegAllocInit();
Var i: Longint;
Begin
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
Var cgCodeLines: ^ptCodeLine; // Array
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
    New(cgCodeLines);
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
    item^.fMode := mREG;
    cgRequestRegister;
    cgPut('LDW', cgRequestRegisterRet, item^.fReg, item^.fOffset, 'cg var2Reg');
    item^.fReg := cgRequestRegisterRet;
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
End;

// TODO
// cEql -> BNE
// cNeq -> BEQ
// cLss -> BGE
// cGeq -> BLT
// cLeq -> BGT
// cGtr -> BLE
Var branchNegateRet: String;
Procedure branchNegate(operatorSymbol: Longint);
Begin
End;

// Conditional Jump, to be fixed up later
Procedure cJump(item: ptItem);
Begin
    branchNegate(item^.fOperator);
    cgPut(branchNegateRet, item^.fReg, 0, item^.fls);
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

