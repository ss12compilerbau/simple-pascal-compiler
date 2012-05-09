// Code-generation API

// Register allocation API
var cgRegisterUsage: Array of Longint;

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

Procedure cgRegAllocInit();
Var i: Longint;
Begin
    setLength(cgRegisterUsage, 32);
    i := 0;
    while i<31 do begin
        cgRegisterUsage[i] := cFalse;
        i := i + 1;
    end;
    cgRegisterUsage[0] := cTrue;
    cgRegisterUsage[28] := cTrue; // Reserved for Global Variable address pointer
End;

// Item API




Procedure cgInit();
Begin
    cgRegAllocInit;
End;

