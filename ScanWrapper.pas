PROGRAM SPC;


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
		while( sym <> cEOF) DO
		BEGIN
			if sym = cIdent then
			BEGIN
				// write( W, sym);
				// if debugmode then 
				write(sym);
				// write( W, '  ident = ');
				// if debugmode then 
				write( '  ident = ');
				printId( id);
			END

			ELSE IF sym = cNumber then
			BEGIN
				// write( W, sym);
				// if debugmode then 
				write( sym);
				// write( W, '  ident = ');
				// if debugmode then 
				write( '  ident = ');
				// writeln( W, val);
				// if debugmode then 
				writeln(val);
			END

			ELSE IF sym = cString then
			BEGIN
				// write( W, sym);
				// if debugmode then 
				write( sym);
				// write( W, '  str = ');
				// if debugmode then 
				write( '  str = ');
				printStr( str);
			END

			ELSE BEGIN
			  	// writeln( W, sym);
				// if debugmode then 
				writeln( sym);
			END;
			getSymbol;
		END;
		// writeln( W, sym);
		// if debugmode then 
		writeln( sym);

		close( R);
		// close( W);
	END;


BEGIN
    scannerInit();
	if ParamCount < 1 then begin
			writeln('Not enough parameters given. Usage: ' + ParamStr(0) + ' input.pas');
			halt(1);
		end
	else begin
		scan(ParamStr(1));
	end;
END.

