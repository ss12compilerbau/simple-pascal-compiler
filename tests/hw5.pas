Program hw5;

Type numArray = Array of Longint;
Var numbers: numArray;
Var len: Longint;

var oddRet: Longint;
Procedure odd(num: Longint); forward;

var evenRet: Longint;
Procedure even(num: Longint);
var ret: Longint;
Begin
    if (num = 0) then begin
        ret := 1;
    end else begin
        odd(num-1);
        ret := oddRet;
    end;
    evenRet := ret;
end;

Procedure odd(num: Longint);
var ret: Longint;
Begin
    if (num = 0) then begin
        ret := 0;
    end else begin
        even(num-1);
        ret := evenRet;
    end;
    oddRet := ret;
end;

Procedure evenOrOdd(numbers: numArray; numLen: Longint);
Var i: Longint;
var lEven: Longint;
var lOdd: Longint;
Begin
    i := 0;
    lEven := 0;
    lOdd := 0;
    while (i < numLen) do begin


        if (numbers[i] >= 0) then begin
            even(numbers[i]);
            lEven := evenRet;
            if(lEven > 0) then begin
                // writeln('number is even');
                writeln(2);
            end;
        end;
        if (numbers[i] >= 0) then begin
            odd(numbers[i]);
            lOdd := oddRet;
            if (lOdd > 0) then begin
                // Writeln('number is odd');
                Writeln(1);
            end;
        end else begin
            // Writeln('number is < 0, sorry...');
            Writeln(5);
        end;
        i := i + 1;
    end;
end;

begin
    len := 3;
    setLength(numbers, len);
    numbers[0] := 3210;
    numbers[1] := 2345;
    numbers[2] := 0 - 11;
    evenOrOdd(numbers, len);
end.
