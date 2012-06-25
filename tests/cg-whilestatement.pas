Program whilestatement;
Var i: Longint;
Var j: Longint;
Var k: Longint;
Var n: Longint;

begin
    i := 3;
    j := 10;
    k := 100;
    n := 0;
    while i < j do begin
        n := 6;
        while n < 8 do begin
            writeln(n);
            n := n + 1;
        end;
        k := k + 10;
        i := i + 1;
    end;
    Writeln(k); // 170

end.
