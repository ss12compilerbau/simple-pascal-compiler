Program hw4;
    Type tArray = array of Longint;
    Var sum: Longint;
    var i: Longint;

    Var len: Longint;
    Var data: tArray;
Begin
    sum := 0;
    i := 0;
    len := 3;

    if (len > 0) then begin
        setLength(data, len);
//    end else begin
//        data := Nil;
    end;

    // statically initialize your data array with some values
    data[0] := 10;
    data[1] := 20;
    data[2] := 30;
    (*
    *)

    while (i < len) do begin
        sum := sum + data[i];
        i := i + 1;
    end;

    if((len <> 0) and ((sum DIV len) > 0)) then begin
        // Writeln('Average is >0.');
        Writeln(sum DIV len);
    end;
End.
