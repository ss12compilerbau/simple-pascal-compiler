PROGRAM SPC;

	// Var debugmode: boolean;
	var parseParamStr0 : string;
	var parseParamStr1 : string;

{$include 'scanner.pas';}
{$include 'symboltable.pas';}
{$include 'parser.pas';}
 

	BEGIN
		//debugmode := true;

		
		chr10 := chr(10);
		chrQuote := chr(39); // singel Quote

	    scannerInit;
	    parserInit;
    	STInit;
	
	
	    if ParamCount < 1 then
	    begin
			parseParamStr0 := ParamStr(0);
	        writeln( 'Not enough parameters given. Usage: ' + 
				parseParamStr0 + ' input.pas output.out');
	        halt(1);
	    end
	    else begin
			(* scan( ParamStr(1), ParamStr(2) ) *)
			printSymbolTable( stSymbolTable, ' ');
	
			parseParamStr1 := ParamStr(1);
			parse( parseParamStr1);
			
			printSymbolTable( stSymbolTable, ' ');
	    end;

	END.

