Program procCall;
var testRet: Longint;

Procedure test(n: Longint);
begin
    Writeln(3);
end;

Procedure test1(x: Longint; y: Longint);
var sum: Longint;
begin
    sum := 1;
    testRet := x + y;
    testRet := testRet + sum;
end;

Procedure test2(x: Longint; y: Longint);
var sum: Longint;
begin
    sum := 2;
    testRet := x + y;
    testRet := testRet + sum;
end;

Var sum: Longint;
begin
    test(2);
    sum := 1;
    test2(2, 3);
    sum := testRet + sum;
    Writeln(sum);
end.