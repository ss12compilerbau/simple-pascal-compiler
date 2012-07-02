Program records;
// optional
Type tRecord = record
    f: Longint;
    g: Longint
End;
Type ptRecord = ^tRecord;
Var r1: tRecord;

// required
Var r2: ptRecord;

// required
Type ptRecordOfRecord = ^tRecordOfRecord;
    tRecordOfRecord = record
        f: Longint;
        g: ptRecordOfRecord
    end;
Type ptRecordOfRecord2 = ^tRecordOfRecord2;
    tRecordOfRecord2 = record
        h: Longint;
        i: ptRecordOfRecord2
    end;
Var r3: ptRecordOfRecord;

// required
Type tArray = Array of Longint;
Var a1: tArray;

Type tRecordOfArray = record
    f: Longint;
    g: tArray
end;
Var r4: ^tRecordOfArray;

// required
Type tArrayOfRecordReferences = Array of ptRecord;
Var a2: tArrayOfRecordReferences;

// optional
Var a3: tArrayOfRecordReferences;

begin
    (*
    r1.f := 1;
    r1.g := 2;
    Writeln(r1.f); // 1
    *)
    New(r2);
    r2^.f := 3;
    r2^.g := 4;
    Writeln(r2^.f); // 3

    New(r3);
    r3^.f := 5;
    r3^.g := r3;
    Writeln(r3^.f); // 5

(*
    setLength(a1, 10);
    New(r4);
    r4^.f := 6;
    r4^.g := a1;

    setLength(a2, 2);
    a2[1] := r2;
    Writeln(a2[1]^.g);
*)

    setLength(a3, 2);
    a3[1] := r2;
    Writeln(a3[1]^.f); // 3
    Writeln(a3[1]^.g); // 4
end.

// Should come out 3 5 3 4