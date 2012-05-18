Program whilestatement;
Var i: Longint;
Var j: Longint;
Var k: Longint;

begin
    i := 3;
    j := 10;
    k := 100;
    while i < j do begin
        k := k + 10;
        i := i + 1;
    end;
    Writeln(k); // 170

end.
