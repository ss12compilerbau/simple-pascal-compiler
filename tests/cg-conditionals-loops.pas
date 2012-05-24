Program simple;
Var i: Longint;
Var j: Longint;
Var x: Longint;
Var y: Longint;
begin
    x := 0;
    y := 1;
    if x < y then begin
        x := y;
    end else begin
        y := x;
    end;
    Writeln(x);
    Writeln(y);
    // LDW 1, 28, -4
    // LDW 2, 28, -8
    // CMP 1, 1, 2
    // BGE 1, 0, 4 fixup in fls
    // LDW 1, 28, -8
    // STW 1, 28, -4
    // BR 0, 0, 3 fixup in fJumpAddress
    // LDW 1, 28, -4
    // STW 1, 28, -8
    // ...
    while (x < y) do begin
        x := x + 1;
    end;
    writeln(x);
    // LDW 1, 28, -4
    // LDW 2, 28, -8
    // CMP 1, 1, 2
    // BGE 1, 0, 5 fixup in fls
    // LDW 1, 28, -4
    // ADDI 1, 1, 1
    // STW 1, 28, -4
    // BR 0, 0, -7
    // ...
end.
