// TODOs
// (1) lineNr falsch. Eventuell wegen ($ include
// (2) infoMsg( 'Unrecognized "/"'); funktioniert nicht
//     infoMsg( 'Unrecognized "/"'); geht schon;
// (3) (nextChr);(nextChr;) funktioniert nicht  
// (4) beim parsen von ScanWrapper sagt Scanner "unrecog. Symbol"
//		in einer Endlosschleife ==> halt(1) eingefügt.


PROGRAM SPC;

	var scannerParamStr0 : string;
	var scannerParamStr1 : string;


	{$include 'scanner.pas';}

	(* druckt ID aus *)
	PROCEDURE printId(str: String);
	BEGIN
		writeln( str);
	END;

	(* druckt ID aus *)
	PROCEDURE printStr(str: String);
	BEGIN
		printId( str);
	END;

	PROCEDURE Scan( inputFile: String );
	BEGIN

        scanInitFile(inputFile);
		getSymbol;
		while sym <> cEOF DO
		BEGIN
			if sym = cIdent then
			BEGIN
				write(sym);
				write( '  ident = ');
				printId( id);
			END

			ELSE begin
				IF sym = cNumber then BEGIN
					write( sym);
					write( '  ident = ');
					writeln(val);
				END
				ELSE begin
					IF sym = cString then BEGIN
						write( sym);
						write( '  str = ');
						printStr( str);
					END
					ELSE BEGIN
						writeln( sym);
					END;
				END;
			end;
			getSymbol;
		end;
		
		writeln( sym);
		close( R);
	END;


BEGIN
    scannerInit;
	if ParamCount < 1 then begin
			scannerParamStr0 := ParamStr(0);
			writeln( 'Not enough parameters given. Usage: ' + scannerParamStr0 + ' input.pas');
			halt(1);
		end
	else begin
		scannerParamStr1 := ParamStr(1);
		scan(scannerParamStr1);
	end;

	END.
