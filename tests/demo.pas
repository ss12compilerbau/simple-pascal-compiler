Program BoardGame;

Var isFinished: Longint;
Type row = Array of Longint;
Type tBoard = Array of row;
Var board: tBoard;

Type tSteps = Array of Longint;
Var steps: tSteps;

Var stepNr: Longint;
Var cTrue: Longint;
Var cFalse: Longint;

Procedure checkFinished(tp: Longint); forward;
Procedure listBoard(tp: Longint); forward;

Procedure doStep(tp: Longint);
Var i: Longint;
Var j: Longint;
Var k: Longint;
Begin
    isFinished := cFalse;
    listBoard(1);
    i := 1;
    While (i <= 5) And (isFinished = cFalse) do begin
        j := 1;
        While (j <= 5) And (isFinished = cFalse) do begin
            k := 1; // von links nach rechts
            While (k <= 4) And (isFinished = cFalse) do begin
                        Writeln( 7 );
                If (k = 1) And (j <= 3) then begin
                        Writeln( 8 );
                    If (board[i][j] = cTrue) And ((board[i][j + 1]) = cTrue) And ((board[i][j + 2]) = cFalse) then begin
                        Writeln( 9 );
                        board[i][j] := cFalse;
                        board[i][j + 1] := cFalse;
                        board[i][j + 2] := cTrue;

                        stepNr := stepNr + 1;
                        Writeln( 10 );
                        steps[stepNr] := ((i * 100) + (j * 10)) + k;
                        Writeln( 11 );
                        checkFinished(1);
                        If isFinished = cFalse then begin
                            listBoard(0);
                            doStep(1);
                            If isFinished = cFalse then begin
                                stepNr := stepNr - 1;
                            end;
                        End;
                        board[i][j] := cTrue;
                        board[i][j + 1] := cTrue;
                        board[i][j + 2] := cFalse;
                        // i := 0;
                    End;
                End;
                If (k = 2) And (i <= 3) And (isFinished = cFalse) then begin // von oben nach unten
                    If (board[i][j] = cTrue) And (board[i + 1][j] = cTrue) And (board[i + 2][j] = cFalse) then begin
                        board[i][j] := cFalse;
                        board[i + 1][j] := cFalse;
                        board[i + 2][j] := cTrue;
                        stepNr := stepNr + 1;
                        steps[stepNr] := ((i * 100) + (j * 10)) + k;
                        checkFinished(1);
                        If isFinished = cFalse then begin
                            doStep(1);
                            If isFinished = cFalse then begin
                                stepNr := stepNr - 1;
                            end;
                        End;
                        board[i][j] := cTrue;
                        board[i + 1][j] := cTrue;
                        board[i + 2][j] := cFalse;
                        // i := 0;
                    End;
                End;
                If (k = 3) And (j >= 3) And (isFinished = cFalse) then begin // von rechts nach links
                    If (board[i][j] = cTrue) And (board[i][j - 1] = cTrue) And (board[i][j - 2] = cFalse) then begin
                        board[i][j] := cFalse;
                        board[i][j - 1] := cFalse;
                        board[i][j - 2] := cTrue;
                        stepNr := stepNr + 1;
                        steps[stepNr] := ((i * 100) + (j * 10)) + k;
                        checkFinished(1);
                        If isFinished = cFalse then begin
                            doStep(1);
                            If isFinished = cFalse then begin
                                stepNr := stepNr - 1;
                            end;
                        End;
                        board[i][j] := cTrue;
                        board[i][j - 1] := cTrue;
                        board[i][j - 2] := cFalse;
                        // i := 0;
                    End;
                End;
                If (k = 4) And (i >= 3) And (isFinished = cFalse) then begin // vom unten nach oben
                    If (board[i][j] = cTrue) And (board[i - 1][j] = cTrue) And (board[i - 2][j] = cFalse) then begin
                        board[i][j] := cFalse;
                        board[i - 1][j] := cFalse;
                        board[i - 2][j] := cTrue;
                        stepNr := stepNr + 1;
                        steps[stepNr] := ((i * 100) + (j * 10)) + k;
                        checkFinished(1);
                        If isFinished = cFalse then begin
                            doStep(1);
                            If isFinished = cFalse then begin
                                stepNr := stepNr - 1;
                            end;
                        End;
                        board[i][j] := cTrue;
                        board[i - 1][j] := cTrue;
                        board[i - 2][j] := cFalse;
                        // i := 0;
                    End;
                End;

                k := k + 1;
            End;
            j := j + 1;
        End;
        i := i + 1;
    End;

End;

Procedure checkFinished(tp: Longint);
Var i: Longint;
Var j: Longint;
Var chkF: Longint;
begin
    chkF := cTrue;

    i := 1;
    While i <= 5 do begin
        j := 1;
        While j <= 5 do begin
            If (i = 3) And (j = 3) then begin
                If board[i][j] = cFalse then begin
                    chkF := cFalse;
                end;
            end Else begin
                If board[i][j] = cTrue then begin
                    chkF := cFalse;
                end;
            End;
            j := j + 1;
        End;
        i := i + 1;
    End;

    If chkF = cTrue then begin
        i := 1;
        While i <= stepNr do begin
            Writeln(steps[i]);
            i := i + 1;
        End;
        isFinished := cTrue;
        listBoard(1);
    End;
End;

Procedure listBoard(tp: Longint);
Var i: Longint;
Var j: Longint;
var sum: Longint;
begin
    Writeln(stepNr);
    i := 1;
    While i <= 5 do begin
        sum := ((board[i][1] * 10000) + (board[i][2] * 1000)) + (((board[i][3] * 100) + (board[i][4] * 10)) + board[i][5]);
        Writeln(sum);
        i := i + 1;
    end;
    writeln(88);
end;

Var i: Longint;
Var j: Longint;

Begin
    cTrue := 1;
    cFalse := 0;
    Writeln(2);
    setLength(steps, 100);
    setLength(board, 6);
    i := 1;
    While i <= 5 do begin
        setLength(board[i], 6);
        j := 1;
        While j <= 5 do begin
            board[i][j] := cFalse;
            j := j + 1;
        end;
        i := i + 1;
    end;
    board[1][1] := cTrue;
    board[1][2] := cTrue;
    board[1][4] := cTrue;
    board[2][1] := cTrue;
    board[2][2] := cTrue;
    board[2][4] := cTrue;
    board[3][2] := cTrue;
    board[4][2] := cTrue;
    board[4][4] := cTrue;
    board[5][3] := cTrue;


    stepNr := 0;
    Writeln(0 - 1);
    listBoard(1);
    Writeln( 99 );
    doStep(1);

End.