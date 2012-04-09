	CONST
		(* größte Zahl, die im Source angegeben werden darf *)
		cMaxNumber = 1000000;
		(* weder letter noch digit, um Ende eines Keywords zu kennzeichnen *)
		cChr0 = #0;
		cIdLen = 32; (* maximale Länge von Schlüsselwörter und Variablen etc. *)
		cKWMaxNumber = 34; (* Anzahl der Key- Wörter *)
		cStrLen = 1024; (* maximale Länge von Strings *)

		(* symbols *)
		cNull = 0; // Unknown
		cTimes = 1; // *
		cDiv = 3; // DIV
		cMod = 4;// MOD
		cAnd = 5; // &
		cPlus = 6; // +
		cMinus = 7; // -
		cOr = 8; // OR
		cEql = 9; // =
		cNeq = 10; // #
		cLss = 11; // <
		cGeq = 12; // >=
		cLeq = 13; // <=
		cGtr = 14; // >
		cPeriod = 18; // .
		cComma = 19; // ,
		cColon = 20; // :
		cRparen = 22; // )
		cRbrak = 23; // ]
		cOf = 25; // OF
		cThen = 26; // THEN
		cDo = 27; // DO
		cLparen = 29; // (
		cLbrak = 30; // [
		cNot = 32; // ~
		cBecomes = 33; // :=
		cNumber = 34; // decimal number
		cIdent = 37; // some identifier
		cSemicolon = 38; // ;
		cEnd = 40; // END
		cElse = 41; // ELSE
		cElsif = 42; // ELSIF
		cIf = 44; // IF
		cWhile = 46; // WHILE
		cArray = 54; // ARRAY
		cRecord = 55; // RECORD
		cConst = 57; // CONST
		cType = 58; // TYPE
		cVar = 59; // VAR
		cProcedure = 60; // PROCEDURE
		cBegin = 61; // BEGIN
		cProgram = 62; // PROGRAM
		cModule = 63; // MODULE
		cEof = 64; // EOF
		cFunction = 97;
		cString = 98; (* Strings beginnen und enden mit ' *)
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

		lineNr: tInt;
		colNr: Integer;

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
		KWs: ARRAY [1..cKWMaxNumber] OF
			RECORD
				sym: tInt;
				id: tStrId;
			END;

	(***************************************************
	* IO
	***************************************************)
	PROCEDURE NextChar();
	BEGIN
		Read(R, ch);
		colNr := colNr + 1;
		IF ch = '' THEN BEGIN lineNr := lineNr + 1; colNr := 1; END;
	END;

	PROCEDURE Mark(msg: STRING);
	BEGIN
		Write('Hey! Error at Pos ');
		Write(lineNr);
		Write(':');
		Write(colNr);
		Write(', ');
		Writeln(msg);
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

	(* Liefert das nächste Symbol aus der Input- Datei *)
	(* PROCEDURE getSym(VAR sym: tInt); *)
	PROCEDURE getSymSub();forward;

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

	procedure getSymbol; forward;

	(* Liefert das nächste Symbol aus der Input- Datei *)
	(* PROCEDURE getSym(VAR sym: tInt); *)
	PROCEDURE getSymSub;
	BEGIN
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
					sym := cGeq;
				END
				ELSE sym := cGtr;
			END
		ELSE IF ch = ';' THEN BEGIN NextChar; sym := cSemicolon; END
		ELSE IF ch = ',' THEN BEGIN NextChar; sym := cComma; END
		ELSE IF ch = ':' THEN BEGIN
				NextChar;
				IF ch = '=' THEN
				BEGIN
					NextChar;
					sym := cBecomes;
				END
				ELSE sym := cColon;
			END
		ELSE IF ch = '.' THEN BEGIN NextChar; sym := cPeriod; END
		ELSE IF ch = '(' THEN BEGIN
				NextChar;
				IF ch = '*' THEN
				BEGIN
					comment;
					getSymSub;
				END
				ELSE sym := cLparen
			END
		ELSE IF ch = ')' THEN BEGIN NextChar; sym := cRparen; END
		ELSE IF ch = '[' THEN BEGIN NextChar; sym := cLbrak; END
		ELSE IF ch = ']' THEN BEGIN NextChar; sym := cRbrak; END
		ELSE IF ch = '''' THEN Begin getString; END
		ELSE IF isDigit(  ch) THEN Begin Number; END
		ELSE IF isLetter( ch) THEN Begin Ident; END
		ELSE IF ch = '~' THEN BEGIN NextChar; sym := cNot END
		ELSE IF ch = '/' THEN
		BEGIN
			NextChar;
			IF ch = '/' THEN BEGIN
				REPEAT
					NextChar;
				UNTIL (ch = #10);
				getSymbol;
			END
			ELSE
				Mark('Unrecognized "/"');
			END
		ELSE Begin
			Mark('Unrecognized Symbol "' + ch + '"');
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

	Procedure scanInitFile(inputFile: String);
	Begin
		Assign( R, inputFile);
		Reset( R); 
		NextChar;
	End;

	Procedure ScannerInit();
	Begin

		lineNr := 1;
		colNr := 1;

		cTrue := 1;
		cFalse := 0;

		lastSymWasPeek := cFalse;
		// Counter für KeyWords
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
	End;

