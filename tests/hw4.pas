Program hw4;
    Type tArray = array of Longint;
    Var sum: Longint;
    var i: Longint;

    Var len: Longint;
    Var data: tArray;
Begin
    sum := 0;
    i := 0;
    len := 0;
    
    setLength(data, len);

    // statically initialize your data array with some values
//    data[0] := 10;
//    data[1] := 20;
//    data[2] := 30;
    (*
    *)

    while (i < len) do begin
        sum := sum + data[i];
        i := i + 1;
    end;

    if((len <> 0) and (sum/len > 0)) then begin
        Writeln ('Average is >0.');
    end;
End.
