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
        mode: Longint; // one of mCONST, mVAR, mREG, mREF
        ptype: ptType;
        reg: Longint; // reg[reg] + offset -> address
        offset: Longint;
        value: Longint;
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
    item^.mode := mREG;
    cgRequestRegister;
    item^.reg := cgRequestRegisterRet;
    // assumes_ R0 = 0
    cgPut('ADDI', item^.reg, 0, item^.value, 'cg Const2Reg');
    item^.value := 0;
    item^.offset := 0;
End;

procedure var2Reg(item: ptItem);
Begin
    item^.mode := mREG;
    cgRequestRegister;
    cgPut('LDW', cgRequestRegisterRet, item^.reg, item^.offset, 'cg var2Reg');
    item^.reg := cgRequestRegisterRet;
End;

procedure ref2Reg(item: ptItem);
Begin
    Writeln('var2Reg not yet implemented!');
end;

procedure load(item: ptItem);
Begin
    if item^.mode = mCONST then begin
        const2Reg(item);
    end else begin 
        if item^.mode = mVAR then begin
            var2Reg(item);
        end else begin 
            if item^.mode = mREF then begin
                ref2Reg(item);
            end;
        end;
    end;
End;


// TODO
procedure assignmentOperator(leftItem: ptItem; rightItem: ptItem);
Begin
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

