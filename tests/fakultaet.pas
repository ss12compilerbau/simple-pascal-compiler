Program fakultaet;

Var i: Longint;
Var j: Longint;
Type row = Array of Longint;
Type tBoard = Array of row;
Var board: tBoard;

Var fakRet: Longint;
Procedure fak(f: Longint);
begin
    if f <= 1 then begin
        fakRet := 1;
    end else begin
        fak(f - 1);
        fakRet := fakRet * f;
    end;
end;

Procedure listBoard(n: Longint; m: Longint);
Var i: Longint;
Var j: Longint;
var sum: Longint;
begin
    i := 0;
    While i < m do begin
        j := 0;
        While j < n do begin
            Writeln(board[i][j]);
            j := j + 1;
        end;
        i := i + 1;
    end;
end;

begin
    setLength(board, 3);
    i := 0;
    While i < 3 do begin
        setLength(board[i], 3);
        i := i + 1;
    end;

    i := 0;
    While i < 3 do begin
        j := 0;
        While j < 3 do begin
            fak(i + j);
            board[i][j] := fakRet;
            j := j + 1;
        end;
        i := i + 1;
    end;
    listBoard(3, 3);
end.