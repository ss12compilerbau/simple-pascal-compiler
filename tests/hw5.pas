Program hw5;

Var numbers: Array of Longint;
Var len: Longint;

var evenRet: Longint;
Procedure even(num: Longint);forward;
var oddRet: Longint;
Procedure odd(num: Longint);forward;
Procedure evenOrOdd(numbers: Array of Longint; numLen: Longint);forward;

Procedure evenOrOdd(numbers: Array of Longint; numLen: Longint);
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
            Writeln(-1);
        end;
        i := i + 1;
    end;
end;

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

begin
    len := 3;
    setLength(numbers, len);
    numbers[0] := -3;
    numbers[1] := 2;
    numbers[2] := 7;
    evenOrOdd(numbers, len);
    Writeln(0);
end.
