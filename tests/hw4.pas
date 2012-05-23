Program hw4;
	type tArr = array of longint;
	type tArrArr = array of tArr;
    Var sum: Longint;
    var i: Longint;
    var j: Longint;

    Var rows: Longint;
    Var columns: longint;
    Var data: tArrArr;
    
    type complex = record
		rl: longint;
		ig: longint
	end;
 
Begin
    rows := 3;
    columns := 5;
	
    if( rows > 0) AND (columns > 0) then begin
		setlength(data, rows);
		i := 0;
		while( i < rows) do begin
			setlength(data[i], columns);
			i := i + 1;
		end;
    end 
    else begin
        data := Nil;
    end;

    sum := 0;
    i := 0;
    while( i < rows) do begin
        j := 0;
        while( j < columns) do begin
            data[i][j] := i*100 + j;
            sum := sum + data[i][j];
            j := j + 1;
        end;
        i := i + 1;
    end;

    if((rows > 0) and (columns > 0) and (sum > 0)) then begin
        // Writeln('Average is >0.');
        sum := sum div rows div columns;
        //Writeln(sum);
    end;
    
    //writeln(sum);
    
End.
