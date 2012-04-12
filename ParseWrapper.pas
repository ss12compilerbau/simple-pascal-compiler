PROGRAM SPC;

	Var debugmode: boolean;

{$include 'scanner.pas';}
{$include 'symboltable.pas';}
{$include 'parser.pas';}
 

	BEGIN
		debugmode := true;

	    scannerInit();
	    parserInit();
    	STInit();


    if ParamCount < 1 then
    begin
        writeln('Not enough parameters given. Usage: ' + ParamStr(0) + ' input.pas output.out');
        halt(1);
    end
    else begin
		(* scan( ParamStr(1), ParamStr(2) ) *)
		printSymbolTable(stSymbolTable, '');
		stInsertSymbol('I', stVar, cFalse, 'LONGINT');
		parse( ParamStr(1));
		printSymbolTable(stSymbolTable, '');
    end;

  END.

