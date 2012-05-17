Program records;
// optional
Type tRecord = record
    f: Longint;
    g: Longint;
End;

Var r1: tRecord;

// required
Var r2: ^tRecord;

// required
Type ptRecordOfRecord: ^tRecordOfRecord;
    tRecordOfRecord = record
        f: Longint;
        g: ptRecordOfRecord;
    end;
Var ptRecordOfRecord r3;

// required
Type tArray: Array of Longint;
Var a1: tArray;

Type tRecordOfArray = record
    f: Longint;
    g: tArray;
end;

Var r4: ^tRecordOfArray;

// required
Type tArrayOfRecordReferences = Array of ptRecord;
Var a2: tArrayOfRecordReferences;

// optional
Type tArrayOfRecords = Array of tRecord;
Var a3: tArrayOfRecords;

begin
    r1.f = 1;
    r1.g = 2;

    New(r2);
    r2^.f := 3;
    r2^.g := 4;

    New(r3);
    r3^.f := 5;
    r3^.g := r3;

    setLength(a1, 10);

    New(r4);
    r4^.f = 6;
    r4^.g = a1;

    New(a2);
    a2[1] := r2;
    Writeln('a2[1]^g: ', a2[1]^.g);

    New(a3);
    a3[1] := r1;
    Writeln('a3[1].g: ', a3[1]^.g);
end.

