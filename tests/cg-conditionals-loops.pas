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

    x := 0;
    y := 1;
    if x > y then begin
        x := y;
    end else begin
        y := x;
    end;
    Writeln(x);
    Writeln(y);

    while (x < (y + 10)) do begin
        x := x + 1;
    end;
    writeln(x);
end.
