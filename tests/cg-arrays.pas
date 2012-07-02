(*

program Test;
type tArr = array of longint;
var arr: tArr;
var i: longint;
var sum: longint;

begin
    Setlength(arr, 3);
    arr[0] := 10;
    arr[1] := 20;
    arr[2] := 30;

    i:= 0;
    sum := 0;
    while( i <= 3) do begin
        sum := sum + arr[i];
        i := i + 1;
    end;
    writeln(sum);
end.
*)

program Test;
type tArr = array of longint;
type tArrArr = array of tArr;
var arr: tArrArr;
var i: longint;
var j: longint;
var sum: longint;

begin
    Setlength(arr, 3);
    setlength(arr[0], 5);
    setlength(arr[1], 5);
    setlength(arr[2], 5);

    sum := 0;
    i := 0;
    while( i < 3) do begin
        j := 0;
        while( j < 5) do begin
            arr[i][j] := i*100 + j;
            sum := sum + 2 * arr[i][j];
            j := j + 1;
        end;
        i := i + 1;
    end;
    writeln( sum);
end.

// -> 3060