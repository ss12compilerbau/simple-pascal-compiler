Program procCall;

Var testRet: Longint;
Procedure test(a: Longint; b: Longint);

begin
    testRet := a + b;
end;

Var sum: Longint;
begin
    sum := 1;
    test(2, 3);
    sum := testRet + sum;
    Writeln(sum);
end.