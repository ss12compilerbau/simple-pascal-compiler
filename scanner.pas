PROGRAM SPC;
(*
The scanner goes through a source code file, finds the elementar parts of the 
language and converts them into tokens.
The parts to scan are
 * Reserved words
 * identifiers
 * operators
 * separators
 * constants

• the scanner maintains a global variable
    ∘ currenntCharacter which is initialized to the first character of the input program by invoking a library procedure: readCharacter(); which reads the next character from the input program.
    ∘ the scanner is invoked by the parser through a procedure: getSymbol(); which returns the token that represents the next symbol (in anotherglobal variable). For each invocation of getSymbol() the scanner checks if currentCharacter already constitutes a valid symbol.
        ‣ if yes: the scanner invokes readCharacter() (to prepare for the next invocation of getSymbol()) and returns the appropriate token.
        ‣ if no: the scanner keeps invoking readCharacter() until it recognizes a valid symbol or returns an error.
• Define the set of valid symbols
    ∘ identifiers are sequences of letters and digits that start with a letter; numbers are sequences of digits; strings are sequences of printable characters.
    ∘ define the set of keywords
    ∘ define what a comment is //, /* */
    ∘ define symbol-to-token mapping
    ∘ implement in your language
*)

	CONST
		(* größte Zahl, die im Source angegeben werden darf *)
		cMaxNumber = 1000000;
		(* weder letter noch digit, um Ende eines Keywords zu kennzeichnen *)
		cChr0 = #0;
	
		cIdLen = 16; (* maximale Länge von Schlüsselwörter und Variablen etc. *)
		cKWMaxNumber = 34; (* Anzahl der Key- Wörter *)

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
		cModule = 63;
		cEof = 64;
		(* ??? wie behandeln wir Strings. einfaches oder doppeltes Hochkomma ? *)
		(* TODO implement String handling *)
		cString = 98;
		cQuote = 99;


	TYPE 
		tInt = LONGINT;
		tStrId = ARRAY [0..cIdLen - 1] OF CHAR;


	VAR
		sym: tInt;
		val: tInt;
		id: tStrId;
		error: BOOLEAN;

		ch: CHAR;
		nKW: tInt;
		(*errpos: LONGINT;*) (* never used *)
		R: Text;
		W: Text;
		KWs: ARRAY [1..cKWMaxNumber] OF
			RECORD
				sym: tInt;
				id: tStrId;
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
		isLetter := ((ch >= 'a') AND (ch <= 'z')) OR	((ch >= 'A') AND (ch <= 'Z'));
	END;
	
	(* true, falls ch letter oder digit *)
	FUNCTION isLetterOrDigit( ch: CHAR): BOOLEAN;
	BEGIN
		isLetterOrDigit := isLetter( ch) or isDigit( ch);
	END;
	
	
	
	(* druckt ID aus *)
	PROCEDURE printId(str: tStrId);
		VAR i: tInt;
	BEGIN
		i := 0;
		WHILE isLetterOrDigit( str[i]) DO
		BEGIN
			WRITE( W, str[i]);
			i := i + 1;
		END;
		writeln( W);
	END;

	(* true, falls beide ID's gleich sind *)
	FUNCTION isEquStrId( id1: tStrId; id2: tStrId): BOOLEAN;
		VAR i: tInt;
		equal: BOOLEAN;
	BEGIN
		equal := TRUE; i := 1;
		WHILE isLetterOrDigit( id1[i]) AND equal DO
		BEGIN
			equal := ( id1[i] = id2[i]);
			i := i + 1;
		END;

		equal := equal AND ( NOT isLetterOrDigit(id2[i]));
		isEquStrId := equal;
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
				Read(R, ch);

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
					Read(R, ch);
				UNTIL ( NOT IsDigit(ch))
			END;

		(* falls beim Lesen erkannt wurde, dass es sich um einen Kommentar handelt *)
		PROCEDURE comment;
		BEGIN
			Read( R, ch);
			WHILE true DO
			BEGIN
				WHILE true DO
				BEGIN
					WHILE ch = '(' DO
					BEGIN
						Read( R, ch);
						IF ch = '*' THEN comment;
					END;
					IF ch = '*' THEN BEGIN Read( R, ch); EXIT END ;

					IF eof( R) THEN EXIT;
					Read( R, ch)
				END ;

				IF ch = ')' THEN BEGIN Read( R, ch);	EXIT END ;

				IF eof( R) THEN
				BEGIN
					Mark('comment not terminated');
					EXIT
				END
			END;
		END;

	BEGIN
		(*W HILE ~R.eot & (ch <= " ") DO Texts.Read(R, ch) END; *)
		WHILE NOT EOF( R) AND ( ch <= ' ') DO BEGIN Read( R, ch) END;

		(* IF R.eot THEN sym := eof *)
		IF EOF( R) THEN sym := cEof

		ELSE IF ch = '&' THEN BEGIN Read( R, ch); sym := cAnd END
		ELSE IF ch = '*' THEN BEGIN Read( R, ch); sym := cTimes END
		ELSE IF ch = '+' THEN BEGIN Read( R, ch); sym := cPlus END
		ELSE IF ch = '-' THEN BEGIN Read( R, ch); sym := cMinus END
		ELSE IF ch = '=' THEN BEGIN Read( R, ch); sym := cEql END
		ELSE IF ch = '#' THEN BEGIN Read( R, ch); sym := cNeq END
		ELSE IF ch = '<' THEN BEGIN
							Read( R, ch);
							IF ch = '=' THEN
							BEGIN
								Read( R, ch);
								sym := cLeq
							END
							ELSE sym := cLss;
						END
		ELSE IF ch = '>' THEN BEGIN
							Read( R, ch);
							IF ch = '=' THEN
							BEGIN
								Read( R, ch);
								sym := cGeq
							END
							ELSE sym := cGtr
						END

		ELSE IF ch = ';' THEN BEGIN Read( R, ch); sym := cSemicolon END
		ELSE IF ch = ',' THEN BEGIN Read( R, ch); sym := cComma END
		ELSE IF ch = ':' THEN BEGIN
							Read( R, ch);
							IF ch = '=' THEN
							BEGIN
								Read( R, ch);
								sym := cBecomes
							END
							ELSE sym := cColon
						END
		ELSE IF ch = '.' THEN BEGIN Read(R, ch); sym := cPeriod END
		ELSE IF ch = '(' THEN BEGIN
							Read( R, ch);
							IF ch = '*' THEN
							BEGIN
								comment;
								getSymbol(sym)
							END
							ELSE sym := cLparen
						END
		ELSE IF ch = ')' THEN BEGIN Read( R, ch); sym := cRparen END
		ELSE IF ch = '[' THEN BEGIN Read( R, ch); sym := cLbrak END
		ELSE IF ch = ']' THEN BEGIN Read( R, ch); sym := cRbrak END
		ELSE IF ch = '''' THEN BEGIN Read( R, ch); sym := cQuote END
		ELSE IF isDigit(  ch) THEN Number
		ELSE IF isLetter( ch) THEN Ident
		ELSE IF ch = '~' THEN BEGIN Read( R, ch); sym := cNot END

		ELSE BEGIN
			Read( R, ch);
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
		Reset( R); Read(R, ch);

		Assign( W, outputFile);
		Rewrite( W);

		Error := TRUE;
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
		EnterKW( cDiv, 'DIV');
		EnterKW( cNull, 'LOOP');
		EnterKW( cModule, 'MODULE');

		getSymbol( sym);
		while( sym <> cEOF) DO
		BEGIN
			if sym = cIdent then
			BEGIN
				write( W, sym);
				write( W, '  ident = ');
				printId( id);
			END
			ELSE IF sym = cNumber then
			BEGIN
				write( W, sym);
				write( W, '  ident = ');
				writeln( W, val);
			END

			ELSE writeln( W, sym);
			getSymbol( sym);
		END;
		writeln( W, sym);

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

