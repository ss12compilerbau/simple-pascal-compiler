PROGRAM SPC;
	CONST
		(* größte Zahl, die im Source angegeben werden darf *)
		cMaxNumber = 1000000;
		(* weder letter noch digit, um Ende eines Keywords zu kennzeichnen *)
		cChr0 = #0;
	
		cIdLen = 32; (* maximale Länge von Schlüsselwörter und Variablen etc. *)
		cKWMaxNumber = 34; (* Anzahl der Key- Wörter *)
		cStrLen = 1024; (* maximale Länge von Strings *)
	
		(* symbols *)
		cNull = 0;
		cTimes = 1;
		cDiv = 3; cMod = 4;
		cAnd = 5; cOr = 8;
		cPlus = 6; cMinus = 7;
		cEql = 9; cNeq = 10;
		cLss = 11; cGeq = 12; cLeq = 13; cGtr = 14;
		cPeriod = 18; cComma = 19; cColon = 20;
		cRParen = 22; cLParen = 29;
		cRBrak = 23; cLBrak = 30;
		cOf = 25;
		cThen = 26;
		cDo = 27;
		cNot = 32;
		cBecomes = 33;
		cNumber = 34;
		cIdent = 37;
		cSemicolon = 38;
		cEnd = 40;
		cIf = 44; cElse = 41; cElsif = 42;
		cWhile = 46;
		cArray = 54;
		cRecord = 55;
		cConst = 57;
		cType = 58;
		cVar = 59;
		cProcedure = 60;
		cBegin = 61;
		cProgram = 62;
		cModule = 63;
		cEof = 64;
		cFunction = 97;
		cString = 98; (* Strings beginnen und enden mit ' *)
		cQuote = 99;
		cUses = 96;
		cUnit = 95;
		cInterface = 94;
		cImplementation = 93;
		cForward = 92;
	
	
	TYPE 
		tInt = LONGINT;
		tStrId = ARRAY [0..cIdLen - 1] OF CHAR;
		tStr = ARRAY [0..cStrLen - 1] OF CHAR;
	
	
	
	VAR
		(* Konstanten *)
		cTrue : longint;
		cFalse : longint;
	
	
		sym: tInt; (* speichert das nächste Symbol des Scanners *)
		val: tInt; (* wenn sym = cNumber, dann speichert val den longint- Wert *)
		id: tStrId; (* wenn sym = cIdent, dann speichert id den Identifier *)
		str: tStr; (* wenn sym = cString, dann speichert str den string- Wert *)
		(* error: BOOLEAN; *)
	
		lastSymWasPeek : longint; (* cTrue, falls sym durch Aufruf peekSymbol *)
	
		ch: CHAR; (* UCase *)
		nKW: tInt;
		(*errpos: LONGINT;*) (* never used *)
		R: Text;
		W: Text;
		KWs: ARRAY [1..cKWMaxNumber] OF
			RECORD
				sym: tInt;
				id: tStrId;
			END;
		debugmode: boolean;


	(***************************************************
	* IO
	***************************************************)
	PROCEDURE NextChar();
	BEGIN
		Read(R, ch);
	END;
	
	PROCEDURE Mark(msg: STRING);
	BEGIN
		Writeln( msg);
	END;


	(* true, falls ch eine Ziffer *)
	FUNCTION isDigit( ch: CHAR): BOOLEAN;
	BEGIN
		isDigit := ( ch >= '0') AND ( ch <= '9');
	END;

	(* true, falls ch ein Buchstabe *)
	FUNCTION isLetter( ch: CHAR): BOOLEAN;
	BEGIN
		isLetter := ((ch >= 'a') AND (ch <= 'z')) OR ((ch >= 'A') AND (ch <= 'Z'));
	END;
	
	(* true, falls ch letter oder digit *)
	FUNCTION isLetterOrDigit( ch: CHAR): BOOLEAN;
	BEGIN
		isLetterOrDigit := isLetter( ch) or isDigit( ch);
	END;
	
	FUNCTION UCase(c: CHAR) : CHAR;
	BEGIN
		IF( (c >= 'a') AND ( c <= 'z')) THEN
			UCase := chr( ord('A') + ord(c) - ord('a'))
		ELSE
			UCase := c;
	END;
	
	
	(* true, falls beide ID's gleich sind *)
	(* nicht case sensitiv *)
	FUNCTION isEquStrId( id1: tStrId; id2: tStrId): BOOLEAN;
		VAR i: tInt;
		equal: BOOLEAN;
	BEGIN
		equal := TRUE; i := 1;
		WHILE isLetterOrDigit( id1[i]) AND equal DO
		BEGIN
			equal := ( UCase(id1[i]) = UCASE(id2[i]));
			i := i + 1;
		END;

		equal := equal AND ( NOT isLetterOrDigit(id2[i]));
		isEquStrId := equal;
	END;
	
	
	
	(* druckt ID aus *)
	PROCEDURE printId(str: tStrId);
		VAR i: tInt;
	BEGIN
		i := 0;
		(* WHILE isLetterOrDigit( str[i]) DO *)
		while not ( str[i] = cChr0 ) DO
		BEGIN
			WRITE( W, str[i]);
			if debugmode then WRITE( str[i]);
			i := i + 1;
		END;
		writeln( W);
	END;
	
	(* druckt ID aus *)
	PROCEDURE printStr(str: tStr);
		VAR i: tInt;
	BEGIN
		i := 0;
		(* WHILE isLetterOrDigit( str[i]) DO *)
		while not ( str[i] = cChr0 ) DO
		BEGIN
			WRITE( W, str[i]);
			if debugmode then WRITE( str[i]);
			i := i + 1;
		END;
		writeln( W);
	END;

	


	(* Liefert das nächste Symbol aus der Input- Datei *)
	(* PROCEDURE getSym(VAR sym: tInt); *)
	PROCEDURE getSymSub;

		(* falls beim Lesen erkannt wurde, dass es sich um ein Symbol handelt *)
		(* z.B. Keyword oder Variable *)
		PROCEDURE Ident;
			VAR i, k: tInt;
		BEGIN
			i := 0;
			REPEAT
				IF i < cIdLen THEN
				BEGIN
					id[i] := ch;
					i := i + 1; (* INC(i); *)
				END;
				NextChar;				

			(* ??? UNTIL (ch < '0') OR (ch > '9') AND (CAP(ch) < 'A') OR (CAP(ch) > 'Z'); *)
			UNTIL ( NOT isLetterOrDigit( ch));

			id[i] := cChr0;
			k := 0;

			WHILE (k < nKW) AND (NOT isEquStrId(id, KWs[k].id)) DO
			BEGIN
				k := k + 1; (* INC(k); *)
			END;

			IF k < nKW THEN	sym := KWs[k].sym
			ELSE BEGIN sym := cIdent;	END
		END;

        (* falls beim Lesen erkannt wurde, dass es sich um ein String handelt *)
        PROCEDURE getString;
            var i: tInt;
        BEGIN
            (* komsumiere "'" am Anfang *)
            NextChar;
			i := 0;
			REPEAT
				IF i < cStrLen THEN
				BEGIN
					str[i] := ch;
					i := i + 1; (* INC(i); *)
					if ch = '''' then 
					begin
					    NextChar;
					end;
				END;
				NextChar;

			(* ??? UNTIL (ch < '0') OR (ch > '9') AND (CAP(ch) < 'A') OR (CAP(ch) > 'Z'); *)
			UNTIL ( ch = '''' );
			str[i] := cChr0;
			sym := cString;
			NextChar;
        END;

		(* falls beim Lesen erkannt wurde, dass es sich um eine Zahl handelt *)
		PROCEDURE Number;
			BEGIN
				val := 0;
				sym := cNumber;

				REPEAT
					IF val <= (cMaxNumber - ORD( ch) + ORD( '0')) DIV 10 THEN
						val := 10 * val + ( ORD( ch) - ORD( '0'))
					ELSE BEGIN
						Mark( 'number too large');
						val := 0
					END ;
					NextChar;
				UNTIL ( NOT IsDigit(ch))
			END;

		(* falls beim Lesen erkannt wurde, dass es sich um einen Kommentar handelt *)
		(*
		PROCEDURE comment;
		BEGIN
			NextChar;
			WHILE true DO
			BEGIN
				WHILE true DO
				BEGIN
					WHILE ch = '(' DO
					BEGIN
						NextChar;
						IF ch = '*' THEN comment;
					END;
					IF ch = '*' THEN BEGIN NextChar; EXIT END ;

					IF eof( R) THEN EXIT;
					NextChar;
				END ;

				IF ch = ')' THEN BEGIN NextChar; EXIT END ;

				IF eof( R) THEN
				BEGIN
					Mark('comment not terminated');
					EXIT
				END;
			END;
		END;
		*)
		Procedure comment;
			var inComment: BOOLEAN;
		BEGIN
			inComment := TRUE;
			NextChar;
			
			WHILE inComment DO
			BEGIN
				if eof( R) THEN
				BEGIN
					Mark('ERROR: comment not terminated');
					EXIT
				END;
				IF( ch = '*') THEN
				BEGIN
					nextChar;
					if eof( R) THEN
					BEGIN
						Mark('ERROR: comment not terminated');
						EXIT
					END;
					inComment := (ch <> ')')
				END;
				nextChar;
			END;
		END; 

	BEGIN
		debugmode := false;
	
		(* WHILE ~R.eof & (ch <= " ") DO Texts.Read(R, ch) END; *)
		WHILE NOT EOF( R) AND ( ch <= ' ') DO BEGIN NextChar; END;

		(* IF R.eot THEN sym := eof *)
		IF EOF( R) THEN sym := cEof

		ELSE IF ch = '&' THEN BEGIN NextChar; sym := cAnd END
		ELSE IF ch = '*' THEN BEGIN NextChar; sym := cTimes END
		ELSE IF ch = '+' THEN BEGIN NextChar;; sym := cPlus END
		ELSE IF ch = '-' THEN BEGIN NextChar; sym := cMinus END
		ELSE IF ch = '=' THEN BEGIN NextChar; sym := cEql END
		ELSE IF ch = '#' THEN BEGIN NextChar; sym := cNeq END
		ELSE IF ch = '<' THEN BEGIN
							NextChar;
							IF ch = '=' THEN
							BEGIN
								NextChar;
								sym := cLeq
							END
							ELSE sym := cLss;
						END
		ELSE IF ch = '>' THEN BEGIN
							NextChar;
							IF ch = '=' THEN
							BEGIN
								NextChar;
								sym := cGeq
							END
							ELSE sym := cGtr
						END

		ELSE IF ch = ';' THEN BEGIN NextChar; sym := cSemicolon END
		ELSE IF ch = ',' THEN BEGIN NextChar; sym := cComma END
		ELSE IF ch = ':' THEN BEGIN
							NextChar;
							IF ch = '=' THEN
							BEGIN
								NextChar;
								sym := cBecomes
							END
							ELSE sym := cColon
						END
		ELSE IF ch = '.' THEN BEGIN NextChar; sym := cPeriod END
		ELSE IF ch = '(' THEN BEGIN
							NextChar;
							IF ch = '*' THEN
							BEGIN
								comment;
								getSymSub;
							END
							ELSE sym := cLparen
						END
		ELSE IF ch = ')' THEN BEGIN NextChar; sym := cRparen END
		ELSE IF ch = '[' THEN BEGIN NextChar; sym := cLbrak END
		ELSE IF ch = ']' THEN BEGIN NextChar; sym := cRbrak END
		ELSE IF ch = '''' THEN getString (* es war mal.. Read( R, ch); sym := cQuote END*)
		ELSE IF isDigit(  ch) THEN Number
		ELSE IF isLetter( ch) THEN Ident
		ELSE IF ch = '~' THEN BEGIN NextChar; sym := cNot END

		ELSE BEGIN
			NextChar;
			sym := cNull
		END;


	END;


	procedure getSymbol;
	begin
		if lastSymWasPeek = cTrue then begin
			(* Symbol steht schon in sym, da letzter Aufruf peekSymbol *)
			lastSymWasPeek := cFalse; (* nächster Aufruf holt neues Symbol *)
		end
		else begin
			getSymSub;
		end;
	end;
		
	procedure peekSymbol;
	begin
		if lastSymWasPeek = cFalse then begin
			getSymbol;
			lastSymWasPeek := cTrue;
		end;
	end;
		
	
		
	(*
	PROCEDURE Init*(T: Texts.Text; pos: LONGINT);
	BEGIN error := FALSE; errpos := pos; Texts.OpenReader(R, T, pos); Texts.Read(R, ch)
	END Init;
	* *)

	PROCEDURE copyKW( fromString: tStrID; VAR id: tStrID);
		VAR i : tInt;
	BEGIN
		i := 0;
		WHILE isLetterOrDigit( fromString[i]) DO
		BEGIN
			id[i] := fromString[i];
			i := i + 1;
		END;
	END;


	PROCEDURE EnterKW( sym: tInt; name: tStrID);
	BEGIN
		KWs[nKW].sym := sym;
		copyKW( name, KWs[nKW].id);
		nKW := nKW + 1; (* INC(nKW); *)
	END;

	PROCEDURE Scan( inputFile: String; outputFile: String );
	BEGIN

		Assign( R, inputFile);
		Reset( R); NextChar;

		Assign( W, outputFile);
		Rewrite( W);

		getSymbol;
		while( sym <> cEOF) DO
		BEGIN
			if sym = cIdent then
			BEGIN
				write( W, sym); 
				if debugmode then write(sym);
				write( W, '  ident = '); 
				if debugmode then write( '  ident = ');
				printId( id);
			END
			
			ELSE IF sym = cNumber then
			BEGIN
				write( W, sym); 
				if debugmode then write( sym);
				write( W, '  ident = '); 
				if debugmode then write( '  ident = ');
				writeln( W, val);
				if debugmode then writeln( val);
			END

			ELSE IF sym = cString then
			BEGIN
				write( W, sym); 
				if debugmode then write( sym);
				write( W, '  ident = '); 
				if debugmode then write( '  ident = ');
				printStr( str);
			END

			ELSE BEGIN
			  writeln( W, sym); 
				if debugmode then writeln( sym);
			END;
			getSymbol;
		END;
		writeln( W, sym); 
		if debugmode then writeln( sym);

		close( R); close( W);
	END;
 
	(***************************************************************)
	(* Beginn Parser *)
	
	function parseCodeBlock : longint; forward;
	function parseDeclaration : longint; forward;
  
	procedure parserErrorStr( errMsg : String);
	begin
		writeln( errMsg);
	end;
	procedure parserErrorInt( errCode : longint);
	begin
		writeln( errCode);
	end;
	

	procedure parserDebugStr( msg: String);
	begin
		//writeln( msg);
	end;
	procedure parserDebugInt( code: longint);
	begin
		//writeln( code);
	end;
	procedure parserDebugStrInt( msg : String; code: longint);
	begin
		(*
		write( msg);
		write( ' ');
		write( code);
		writeln( );
		*)
	end;
	
	
	
	function parseSymbol( s : longint) : longint;
		var symFound : longint; (* ob Symbol in case verarbeitet *)
	begin
		symFound := cFalse;
		getSymbol;
		if sym = s then begin
			parseSymbol := cTrue;
		end
		else begin
			if sym <> s then begin
				parseSymbol := cFalse;
				if s = cSemicolon then begin
					parserErrorStr( '91 121 Semicolon missing');
					symFound := cTrue;
				end;
				if s = cPeriod then begin
					parserErrorStr( '91 122 Period missing');
					symFound := cTrue;
				end;
				if s = cProgram then begin
					parserErrorStr( '91 123 PROGRAM missing');
					symFound := cTrue;
				end;
				if s = cUses then begin
					parserErrorStr( '91 124 USES missing');
					symFound := cTrue;
				end;
				if s = cType then begin
					parserErrorStr( '91 125 TYPE missing');
					symFound := cTrue;
				end;
				if symFound = cFalse then begin
					parserErrorStr( '91 139 Symbol missing');
					parserErrorInt( s);
				end;
			end;
		end;
	end;
	
	function parseIsSymbol( s : longint) : longint;
	begin
		peekSymbol;
		parseIsSymbol := cFalse;
		if sym = s then begin
			parseIsSymbol := cTrue;
		end;
	end;

	(* Identifiers *)
	function parseIdentifier : longint;
		var ret : longint;
	begin
		getSymbol;
		if sym = cIdent then begin
			ret := cTrue;
		end
		else begin
			ret := cFalse;
		end;
		
		parseIdentifier := ret;
	end;
	
	function parsePgmIdentifier : longint;
		var ret : longint;
	begin
		ret := parseIdentifier;
		if ret = cFalse then begin
			parserErrorStr( '91 101 PgmIdentifier missing');
		end;
		parsePgmIdentifier := ret;
	end;
	
	function parseUseIdentifier : longint;
		var ret : longint;
	begin
		ret := parseIdentifier;
		if ret = cFalse then begin
			parserErrorStr( '91 103 UseIdentifier missing');
		end;
		parseUseIdentifier := ret;
	end;
	
	function parseUnitIdentifier : longint;
		var ret : longint;
	begin
		ret := parseIdentifier;
		if ret = cFalse then begin
			parserErrorStr( '91 103 UseIdentifier missing');
		end;
		parseUnitIdentifier := ret;
	end;
	
	function parseVarIdentifier : longint;
		var ret : longint;
	begin

		ret := parseIdentifier;
		if ret = cFalse then begin
			parserErrorStr( '91 105 VarIdentifier missing');
		end;
		parseVarIdentifier := ret;

	end;
	
	function parseTypeIdentifier : longint;
		var ret : longint;
	begin
		ret := parseIdentifier;
		if ret = cFalse then begin
			parserErrorStr( '91 107 TypeIdentifier missing');
		end;
		parseTypeIdentifier := ret;
	end;
	
	function parseProcIdentifier : longint;
		var ret : longint;
	begin
		ret := parseIdentifier;
		if ret = cFalse then begin
			parserErrorStr( '91 109 ProcIdentifier missing');
		end;
		parseProcIdentifier := ret;
	end;
	
	function parseFuncIdentifier : longint;
		var ret : longint;
	begin
		ret := parseIdentifier;
		if ret = cFalse then begin
			parserErrorStr( '91 111 FuncIdentifier missing');
		end;
		parseFuncIdentifier := ret;
	end;
	
	

		
	
	
	function parseDefParameters : longint;
		var ret : longint;
		var again : longint;
		var bTry : longint;
		var bParse : longint;
	begin
		parserDebugStr( 'parseDefParameters');
		ret := parseIsSymbol( cLParen);
		
		if ret = cTrue then begin
			getSymbol; // ist '('
			
			
			
			ret := parseDeclaration;
			
			bTry := parseIsSymbol( cSemicolon); 
			again := bTry;
			while (again = cTrue) do begin
				if bTry = cTrue then begin
					bParse := parseSymbol( cSemicolon);
					if bParse = cTrue then begin
						bParse := parseDeclaration;
					end;
				end;
				if bParse = cTrue then begin
					bTry := parseIsSymbol( cSemicolon);
					again := bTry;
				end
				else begin
					again := cFalse;
				end;
			end;
		
			if bTry = cFalse then begin
				ret := cTrue;
			end
			else begin
				ret := bParse;
			end;
			
			if ret = cTrue then begin
				ret := parseSymbol( cRParen); 
			end	
		end
		
		else begin
			ret := cTrue;
		end;
		
		parserDebugStrInt( 'parseDefParameters', ret);
		parseDefParameters := ret;
	end;
	
	function parseType : longint;
		var ret : longint;
	begin
		getSymbol;
		ret := cTrue;
		parseType := ret;
	end;
	
	
	
	function parseDeclaration : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseDeclaration');
		ret := parseVarIdentifier;
		write( ' *** VAR ', id);
		
		if ret = cTrue then begin
			ret := parseSymbol( cColon);
		end;
		
		if ret = cTrue then begin
			ret := parseType;
			writeln( ' ', id);
		end;
		
		parserDebugStrInt( 'parseDeclaration', ret);
		parseDeclaration := ret;
	end;
	
	
	function parseRecordType : longint;
		var ret : longint;
		var again : longint;
		var bTry : longint;
		var bParse : longint;
	begin
		parserDebugStr( 'parseRecordType');
		ret := parseSymbol( cRecord);
		
		if ret = cTrue then begin
			ret := parseDeclaration;
		end;

		bTry := parseIsSymbol( cSemicolon); 
		again := bTry;
		while (again = cTrue) do begin
			if bTry = cTrue then begin
				bParse := parseSymbol( cSemicolon);
				if bParse = cTrue then begin
					bParse := parseDeclaration;
				end;
			end;
			if bParse = cTrue then begin
				bTry := parseIsSymbol( cSemicolon);
				again := bTry;
			end
			else begin
				again := cFalse;
			end;
		end;
		
		if bTry = cFalse then begin
			ret := cTrue;
		end
		else begin
			ret := bParse;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cEnd); 
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon); 
		end;
		
		parserDebugStrInt( 'parseRecordType', ret);
		parseRecordType := ret;
	end;





	
	
	
	
	function parseProcCallTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseProcCallTry');
		ret := cFalse;
		
		parserDebugStrInt( 'parseProcCallTry', ret);
		parseProcCallTry := ret;
	end;
	
	function parseProcCall : longint;
		var ret : longint;
	begin
		ret := cFalse;
		
		parseProcCall := ret;
	end;


	function parseWhileStatementTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseWhileStatementTry');
		ret := parseIsSymbol( cWhile);
		
		parserDebugStrInt( 'parseWhileStatementTry', ret);
		parseWhileStatementTry := ret;
	end;
	
	function parseWhileStatement : longint;
		var ret : longint;
	begin
		ret := parseSymbol( cWhile);
		
		if ret = cTrue then begin
			ret := parseSymbol( cDo);
		end;
		
		if ret = cTrue then begin
			ret := parseCodeBlock;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon);
		end;
		
		parseWhileStatement := ret;
	end;
	

	function parseIfStatementTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseIfStatementTry');
		ret := parseIsSymbol( cIf);
		
		parserDebugStrInt( 'parseIfStatementTry', ret);
		parseIfStatementTry := ret;
	end;
	
	function parseIfStatement : longint;
		var ret : longint;
	begin
		ret := parseSymbol( cIf);
		
		if ret = cTrue then begin
			ret := parseSymbol( cThen);
		end;
		
		if ret = cTrue then begin
			ret := parseCodeBlock;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon);
		end;
		
		parseIfStatement := ret;
	end;


	function parseSimpleStatementTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseSimpleStatementTry');
		ret := cFalse;
		
		parserDebugStrInt( 'parseSimpleStatementTry', ret);
		parseSimpleStatementTry := ret;
	end;
	
	function parseSimpleStatement : longint;
		var ret : longint;
	begin
		ret := cFalse;
		
		parseSimpleStatement := ret;
	end;


	function parseStatementTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseStatementTry');
		ret := parseSimpleStatementTry;
		
		if ret = cFalse then begin
			ret := parseIfStatementTry;
		end;
		
		if ret = cFalse then begin
			ret := parseWhileStatementTry;
		end;
		
		if ret = cFalse then begin
			ret := parseProcCallTry;
		end;
		
		parserDebugStrInt( 'parseStatementTry', ret);
		parseStatementTry := ret;
	end;
	
	function parseStatement : longint;
		var ret : longint;
		var bTry : longint;
	begin
		parserDebugStr( 'parseStatement');
		ret := cTrue;
		bTry := parseSimpleStatementTry;
		if bTry = cTrue then begin
			ret := parseSimpleStatement;
		end
		else begin
			bTry := parseIfStatementTry;
			if bTry = cTrue then begin
				ret := parseIfStatement;
			end
			else begin
				bTry := parseWhileStatementTry;
				if bTry = cTrue then begin
					ret := parseWhileStatement;
				end
				else begin
					bTry := parseProcCallTry;
					if bTry = cTrue then begin
						ret := parseProcCall;
					end
					else begin
						parserErrorStr( 'parseStatement');
						ret := cFalse;
					end;
				end;
			end;
		end;
		
		parserDebugStrInt( 'parseStatement', ret);
		parseStatement := ret;
	end;
	
	
	function parseStatements : longint;
		var ret : longint;
		var again : longint;
		var bTry : longint;
		var bParse : longint;
	begin
		parserDebugStr( 'parseStatements');
		bTry := parseStatementTry; 
		again := bTry;
		while (again = cTrue) do begin
			if bTry = cTrue then begin
				bParse := parseStatement;
			end;
			if bParse = cTrue then begin
				bTry := parseStatementTry;
				again := bTry;
			end
			else begin
				again := cFalse;
			end;
		end;
		if bTry = cFalse then begin
			ret := cTrue;
		end
		else begin
			ret := bParse;
		end;
		
		parserDebugStrInt( 'parseStatements', ret);
		parseStatements := ret;
	end;

	
	function parseCodeBlock : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseCodeBlock');
		ret := parseSymbol( cBegin);
		
		if ret = cTrue then begin
			ret := parseStatements;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cEnd); 
		end;
		
		parseCodeBlock := ret;
		parserDebugStrInt( 'parseCodeBlock', ret);
	end;
	
		
	function parseTypeDeclarationTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseTypeDeclarationTry');
		ret := parseIsSymbol( cType);
		
		parserDebugStrInt( 'parseTypeDeclarationTry', ret);
		parseTypeDeclarationTry := ret;
	end;
	
	function parseTypeDeclaration : longint;
		var ret : longint;
	begin
		ret := parseSymbol( cType);
		
		if ret = cTrue then begin
			ret := parseTypeIdentifier;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cEql);
		end;
		
		if ret = cTrue then begin
			ret := parseRecordType;
		end;
		
		parseTypeDeclaration := ret;
	end;
	
	
	function parseVarDeclarationTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseVarDeclarationTry');
		ret := parseIsSymbol( cVar);
		
		parserDebugStrInt( 'parseVarDeclarationTry', ret);
		parseVarDeclarationTry := ret;
	end;
	
	function parseVarDeclaration : longint;
		var ret : longint;
	begin
		ret := parseSymbol( cVar);
		
		if ret = cTrue then begin
			ret := parseDeclaration;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon);
		end;
		
		parseVarDeclaration := ret;
	end;
	
	
	function parseVarDeclarations : longint;
		var ret : longint;
		var again : longint;
		var bTry : longint;
		var bParse : longint;
	begin
		bTry := parseVarDeclarationTry; 
		again := bTry;
		while (again = cTrue) do begin
			if bTry = cTrue then begin
				bParse := parseVarDeclaration;
			end;
			if bParse = cTrue then begin
				bTry := parseVarDeclarationTry; 
				again := bTry;
			end
			else begin
				again := cFalse;
			end;
		end;
		if bTry = cFalse then begin
			ret := cTrue;
		end
		else begin
			ret := bParse;
		end;
		
		parseVarDeclarations := ret;
	end;
	

	function parseFuncHeading : longint;
		var ret : longint;
	begin	
		ret := parseSymbol( cFunction);
		
		if ret = cTrue then begin
			ret := parseFuncIdentifier;
		end;
		
		if ret = cTrue then begin
			ret := parseDefParameters; 
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cColon); 
		end;
		
		if ret = cTrue then begin
			ret := parseType; 
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon); 
		end;
		
		parseFuncHeading := ret;
	end;
	
	
	function parseFuncDeclarationTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseFuncDeclarationTry');
		ret := parseIsSymbol( cFunction);
		
		parserDebugStrInt( 'parseFuncDeclarationTry', ret);
		parseFuncDeclarationTry := ret;
	end;
	
	function parseFuncDeclaration : longint;
		var ret : longint;
	begin
		ret := parseFuncHeading;
		
		if ret = cTrue then begin
			ret := parseVarDeclarations;
		end;
		
		if ret = cTrue then begin
			ret := parseCodeBlock;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon);
		end;
		
		parseFuncDeclaration := ret;
	end;


	
	function parseProcHeading : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseProcHeading');
		ret := parseSymbol( cProcedure);
		
		if ret = cTrue then begin
			ret := parseProcIdentifier;
		end;
		
		if ret = cTrue then begin
			ret := parseDefParameters; 
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon); 
		end;
		
		parserDebugStrInt( 'parseProcHeading', ret);
		parseProcHeading := ret;
	end;
	
	
	function parseProcDeclarationTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseProcDeclarationTry');
		ret := parseIsSymbol( cProcedure);
		
		parserDebugStrInt( 'parseProcDeclarationTry', ret);
		parseProcDeclarationTry := ret;
	end;
	
	function parseProcDeclaration : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parseProcDeclaration');
		ret := parseProcHeading;
		
		if ret = cTrue then begin
			ret := parseVarDeclarations;
		end;
		
		if ret = cTrue then begin
			ret := parseCodeBlock;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon);
		end;
		
		parserDebugStrInt( 'parseProcDeclaration', ret);
		parseProcDeclaration := ret;
	end;
	
	
	function parsePgmDeclarationTry : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parsePgmDeclarationTry');
		ret := parseVarDeclarationTry;
		
		if ret = cFalse then begin
			ret := parseTypeDeclarationTry;
		end;
		
		if ret = cFalse then begin
			ret := parseProcDeclarationTry;
		end;
		
		if ret = cFalse then begin
			ret := parseFuncDeclarationTry;
		end;
		
		parserDebugStrInt( 'parsePgmDeclarationTry', ret);
		parsePgmDeclarationTry := ret;
	end;
	
	function parsePgmDeclaration : longint;
		var ret : longint;
		var bTry : longint;
	begin
		parserDebugStr( 'parsePgmDeclaration');
		ret := cTrue;
		bTry := parseVarDeclarationTry;
		if bTry = cTrue then begin
			ret := parseVarDeclaration;
		end
		else begin
			bTry := parseTypeDeclarationTry;
			if bTry = cTrue then begin
				ret := parseTypeDeclaration;
			end
			else begin
				bTry := parseProcDeclarationTry;
				if bTry = cTrue then begin
					ret := parseProcDeclaration;
				end
				else begin
					bTry := parseFuncDeclarationTry;
					if bTry = cTrue then begin
						ret := parseFuncDeclaration;
					end
					else begin
						parserErrorStr( 'parsePgmDeclaration');
						ret := cFalse;
					end;
				end;
			end;
		end;
		
		parserDebugStrInt( 'parsePgmDeclaration', ret);
		parsePgmDeclaration := ret;
	end;
	
	
	function parsePgmDeclarations : longint;
		var ret : longint;
		var again : longint;
		var bTry : longint;
		var bParse : longint;
	begin
		parserDebugStr( 'parsePgmDeclarations');
		bTry := parsePgmDeclarationTry; 
		again := bTry;
		while (again = cTrue) do begin
			if bTry = cTrue then begin
				bParse := parsePgmDeclaration;
			end;
			if bParse = cTrue then begin
				(* procDeclaration is parsable *)
				bTry := parsePgmDeclarationTry;
				again := bTry;
			end
			else begin
				again := cFalse;
			end;
		end;
		if bTry = cFalse then begin
			ret := cTrue;
		end
		else begin
			ret := bParse;
		end;
		
		parserDebugStrInt( 'parsePgmDeclarations', ret);
		parsePgmDeclarations := ret;
	end;
	
	
	function parsePgmHeading : longint;
		var ret : longint;
	begin
		parserDebugStr( 'parsePgmHeading');
		ret := parseSymbol( cProgram);
		
		if ret = cTrue then begin
			ret := parsePgmIdentifier;
		end;
		
		if ret = cTrue then begin
			ret := parseSymbol( cSemicolon); 
		end;
		
		parsePgmHeading := ret;
		parserDebugStrInt( 'parsePgmHeading', ret);
	end;
	
	(*
	function parsePgmUsesTry : longint;
		var ret : longint;
	begin
		ret := parseIsSymbol( cUses);
		parsePgmUsesTry := ret;
	end;
	
	function parsePgmUses : longint;
		var ret : longint;
		var again : longint;
		var bTry : longint;
		var bParse : longint;
	begin
		ret := parseSymbol( cUses);
		
		if ret = cTrue then begin
			ret := parseUseIdentifier;
		end;
		
		bTry := parseIsSymbol( cComma); 
		again := bTry;
		while (again = cTrue) do begin
			if bTry = cTrue then begin
				bParse := parseSymbol( cComma);
				if bParse = cTrue then begin
					bParse := parseUseIdentifier;
				end;
			end;
			if bParse = cTrue then begin
				bTry := parseIsSymbol( cComma);;
				again := bTry;
			end
			else begin
				again := cFalse;
			end;
		end;
		if bTry = cFalse then begin
			ret := cTrue;
		end
		else begin
			ret := bParse;
		end;
		
		parsePgmUses := ret;
	end;
	*)
	
	function parsePgm : longint;
		var ret : longint;
		(*var pgmUsesTry : longint;*)
	begin
		ret := parsePgmHeading;
		
		(*
		if ret = cTrue then begin
			pgmUsesTry := parsePgmUsesTry;
			if pgmUsesTry = cTrue then begin
				ret := parsePgmUses;
			end;
		end;
		*)
		
		if ret = cTrue then begin
			ret := parsePgmDeclarations;
		end;
		
		if ret = cTrue then begin
			ret := parseCodeBlock;
		end;
		
		parsePgm := ret;
	end;
	
	
	PROCEDURE Parse( inputFile: String; outputFile: String );
	BEGIN

		Assign( R, inputFile);
		Reset( R); NextChar;

		Assign( W, outputFile);
		Rewrite( W);
		
		writeln( parsePgm);
		
		close( R); close( W);
	end;

	(* end Parser *)
	(***************************************************************)

	BEGIN
		cTrue := 1;
		cFalse := 0;
		lastSymWasPeek := cFalse;
		
		(* Error := TRUE; *)
		nKW := 0;
		EnterKW( cNull, 'BY');
		EnterKW( cDo, 'DO');
		EnterKW( cIf, 'IF');
		EnterKW( cNull, 'IN');
		EnterKW( cNull, 'IS');
		EnterKW( cOf, 'OF');
		EnterKW( cOr, 'OR');
		EnterKW( cNull, 'TO');
		EnterKW( cEnd, 'END');
		EnterKW( cNull, 'FOR');
		EnterKW( cMod, 'MOD');
		EnterKW( cNull, 'NIL');
		EnterKW( cVar, 'VAR');
		EnterKW( cNull, 'CASE');
		EnterKW( cElse, 'ELSE');
		EnterKW( cNull, 'EXIT');
		EnterKW( cThen, 'THEN');
		EnterKW( cType, 'TYPE');
		EnterKW( cNull, 'WITH');
		EnterKW( cArray, 'ARRAY');
		EnterKW( cBegin, 'BEGIN');
		EnterKW( cConst, 'CONST');
		EnterKW( cElsif, 'ELSIF');
		EnterKW( cNull, 'IMPORT');
		EnterKW( cForward, 'FORWARD');
		EnterKW( cWhile, 'WHILE');
		EnterKW( cRecord, 'RECORD');
		EnterKW( cFunction, 'FUNCTION');
		EnterKW( cNull, 'RETURN');
		EnterKW( cNull, 'POINTER');
		EnterKW( cProcedure, 'PROCEDURE');
		EnterKW( cProgram, 'PROGRAM');
		EnterKW( cDiv, 'DIV');
		EnterKW( cNull, 'LOOP');
		EnterKW( cModule, 'MODULE');

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

