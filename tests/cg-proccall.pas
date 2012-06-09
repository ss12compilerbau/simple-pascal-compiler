Program procCall;
var testRet: Longint;

Procedure test1(x: Longint; y: Longint);
var loc: Longint;
begin
    loc := 1;
    testRet := x + y;
    testRet := testRet + loc;
end;
(*
Procedure test2(x: Longint; y: Longint);
var loc2: Longint;
begin
    loc2 := 2;
    testRet := x + y;
    testRet := testRet + loc2;
end;
*)
Var sum: Longint;
begin
    sum := 1;
    test1(2, 3);
    sum := testRet + sum;
    Writeln(sum);
end.