PROGRAM SPC;
	CONST
	    (* debugmode = true; *)
		(* größte Zahl, die im Source angegeben werden darf *)
		cMaxNumber = 1000000;
		(* weder letter noch digit, um Ende eines Keywords zu kennzeichnen *)
		cChr0 = #0;
	
		cIdLen = 16; (* maximale Länge von Schlüsselwörter und Variablen etc. *)
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
		cRparen = 22; cLparen = 29;
		cRbrak = 23; cLbrak = 30;
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
		cString = 98; (* Strings beginnen und enden mit ' *)
		cQuote = 99;


	TYPE 
		tInt = LONGINT;
		tStrId = ARRAY [0..cIdLen - 1] OF CHAR;
		tStr = ARRAY [0..cStrLen - 1] OF CHAR;


	VAR
		sym: tInt;
		val: tInt;
		id: tStrId;
		str: tStr;
		(* error: BOOLEAN; *)

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
	PROCEDURE getSymbol(VAR sym: tInt);

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
								getSymbol(sym);
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
		EnterKW( cNull, 'UNTIL');
		EnterKW( cWhile, 'WHILE');
		EnterKW( cRecord, 'RECORD');
		EnterKW( cNull, 'REPEAT');
		EnterKW( cNull, 'RETURN');
		EnterKW( cNull, 'POINTER');
		EnterKW( cProcedure, 'PROCEDURE');
		EnterKW( cProgram, 'PROGRAM');
		EnterKW( cDiv, 'DIV');
		EnterKW( cNull, 'LOOP');
		EnterKW( cModule, 'MODULE');

		getSymbol( sym);
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
			getSymbol( sym);
		END;
		writeln( W, sym); 
		if debugmode then writeln( sym);

		close( R); close( W);
  END;

  BEGIN
    if ParamCount < 2 then
    begin
        writeln('Not enough parameters given. Usage: ' + ParamStr(0) + ' input.pas output.out');
        halt(1);
    end
    else begin
        scan( ParamStr(1), ParamStr(2) );
    end;

  END.

