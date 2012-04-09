PROGRAM SPC;

	Var debugmode: boolean;

{$include 'scanner.pas';}
{$include 'parser.pas';}
{$include 'symboltable.pas';}


	BEGIN
		debugmode := true;

	    scannerInit();
	    parserInit();
	    STInit();


    if ParamCount < 2 then
    begin
        writeln('Not enough parameters given. Usage: ' + ParamStr(0) + ' input.pas output.out');
        halt(1);
    end
    else begin
		(* scan( ParamStr(1), ParamStr(2) ) *)
		parse( ParamStr(1), ParamStr(2) );
    end;

  END.

