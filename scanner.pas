PROGRAM SPC;

	CONST
		debug = true;
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
		cDiv = 3; 
		cMod = 4;
		cAnd = 5; 
		cPlus = 6; 
		cMinus = 7;
		cOr = 8;	
		cEql = 9; 
		cNeq = 10;
		cLss = 11; 
		cGeq = 12; 
		cLeq = 13; 
		cGtr = 14;
		cPeriod = 18; 
		cComma = 19; 
		cColon = 20;
		cRparen = 22; 
		cRbrak = 23; 
		cOf = 25;
		cThen = 26;
		cDo = 27;
		cLparen = 29;		
		cLbrak = 30;
		cNot = 32;
		cBecomes = 33;
		cNumber = 34;
		cIdent = 37;
		cSemicolon = 38;
		cEnd = 40;		
		cElse = 41; 
		cElsif = 42;
		cIf = 44; 
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


	VAR
		debugmode: boolean;
		sym: tInt;
		lineNr: tInt;
		colNr: Integer;
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
	    Write('Hey! Error at Pos ');
	    Write(lineNr);
	    Write(':');
	    Write(colNr);
	    Write(', ');
	    Writeln(msg);
	END;

	PROCEDURE Next;
	BEGIN
	    Read( R, ch);
	    colNr := colNr + 1;
	    IF ch = '' THEN BEGIN lineNr := lineNr + 1; colNr := 1; END;
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


	(* druckt ID aus *)
	PROCEDURE printId(str: tStrId);
	VAR i: tInt;
	BEGIN
		i := 0;
		(* WHILE isLetterOrDigit( str[i]) DO *)
		WHILE NOT ( str[i] = cChr0 ) DO
		BEGIN
			WRITE( W, str[i]);
			IF debugmode then
			BEGIN
				WRITE( str[i]);
			END;
			i := i + 1;
		END;
		writeln( W);
		IF debugmode then writeln;
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
			Next;

		(* ??? UNTIL (ch < '0') OR (ch > '9') AND (CAP(ch) < 'A') OR (CAP(ch) > 'Z'); *)
		UNTIL ( NOT isLetterOrDigit( ch));
			id[i] := cChr0;
			k := 0;

		WHILE (k < nKW) AND (NOT isEquStrId(id, KWs[k].id)) DO
		BEGIN
			k := k + 1; (* INC(k); *)
		END;

		IF k < nKW THEN sym := KWs[k].sym
		ELSE BEGIN sym := cIdent; END
		END;

	(* falls beim Lesen erkannt wurde, dass es sich um ein String handelt *)
    PROCEDURE getString;
    VAR	i : tInt;
    BEGIN
		(* komsumiere "'" am Anfang *)
		Next;
		i := 0;
		REPEAT
			IF i < cStrLen THEN
			BEGIN
				id[i] := ch;
				i := i + 1; (* INC(i); *)
				IF ch = '''' then
				BEGIN
					Next;
				END;
			END;
			Next;

		(* ??? UNTIL (ch < '0') OR (ch > '9') AND (CAP(ch) < 'A') OR (CAP(ch) > 'Z'); *)
		UNTIL ( ch = '''' );
			id[i] := cChr0;
			sym := cString;
			Next;
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
			Next;
		UNTIL ( NOT IsDigit(ch))
	END;

	(* falls beim Lesen erkannt wurde, dass es sich um einen Kommentar handelt *)
	PROCEDURE comment;
	BEGIN
		Next;
		WHILE true DO
		BEGIN
			WHILE true DO
			BEGIN
			IF ch = '(' THEN
				BEGIN
				Next;
				IF ch = '*' THEN comment;
				END;
				IF ch = '*' THEN BEGIN Next; EXIT END ;

				IF eof( R) THEN EXIT;
				Next;
			END;

			IF ch = ')' THEN BEGIN Next; EXIT END ;

			IF eof( R) THEN
			BEGIN
				Mark('comment not terminated');
				EXIT
			END
		END;
	END;


	BEGIN
		(* WHILE ~R.eof & (ch <= " ") DO Texts.Read(R, ch) END; *)
		WHILE NOT EOF( R) AND ( ch <= ' ') DO BEGIN Next; END;

		(* IF R.eof THEN sym := eof *)
		IF EOF( R) THEN sym := cEof
		ELSE IF ch = '&' THEN BEGIN Next; sym := cAnd END
		ELSE IF ch = '*' THEN BEGIN Next; sym := cTimes END
		ELSE IF ch = '+' THEN BEGIN Next; sym := cPlus END
		ELSE IF ch = '-' THEN BEGIN Next; sym := cMinus END
		ELSE IF ch = '=' THEN BEGIN Next; sym := cEql END
		ELSE IF ch = '#' THEN BEGIN Next; sym := cNeq END
		ELSE IF ch = '<' THEN 
						BEGIN
							Next;
							IF ch = '=' THEN
							BEGIN
								Next;
								sym := cLeq
							END
							ELSE sym := cLss;
						END
		ELSE IF ch = '>' THEN 
						BEGIN
							Next;
							IF ch = '=' THEN
							BEGIN
								Next;
								sym := cGeq
							END
							ELSE sym := cGtr
						END

		ELSE IF ch = ';' THEN BEGIN Next; sym := cSemicolon END
		ELSE IF ch = ',' THEN BEGIN Next; sym := cComma END
		ELSE IF ch = ':' THEN 
						BEGIN
							Next;
							IF ch = '=' THEN
							BEGIN
								Next;
								sym := cBecomes
							END
							ELSE sym := cColon
						END
		ELSE IF ch = '.' THEN BEGIN Next; sym := cPeriod END
		ELSE IF ch = '(' THEN BEGIN
									Next;
									IF ch = '*' THEN
									BEGIN
										comment;
										getSymbol(sym);
									END
									ELSE sym := cLparen
									END
		ELSE IF ch = ')' THEN BEGIN Next; sym := cRparen END
		ELSE IF ch = '[' THEN BEGIN Next; sym := cLbrak END
		ELSE IF ch = ']' THEN BEGIN Next; sym := cRbrak END
		ELSE IF ch = '''' THEN getString (* es war mal.. Next; sym := cQuote END*)
		ELSE IF isDigit( ch) THEN Number
		ELSE IF isLetter( ch) THEN Ident
		ELSE IF ch = '~' THEN BEGIN Next; sym := cNot END

		ELSE BEGIN
				Next;	
				sym := cNull
		END;


	END;

	(*PROCEDURE Init*(T: Texts.Text; pos: LONGINT);
	BEGIN error := FALSE; errpos := pos; Texts.OpenReader(R, T, pos); Texts.Read(R, ch)
	END Init;* *)

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

		lineNr := 1;
		colNr := 1;
		Assign( R, inputFile);
		Reset( R); Next;

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
		EnterKW( cProgram, 'PROGRAM');
		EnterKW( cDiv, 'DIV');
		EnterKW( cNull, 'LOOP');
		EnterKW( cModule, 'MODULE');

		getSymbol( sym);
		WHILE( sym <> cEOF) DO
		BEGIN
			IF sym = cIdent THEN
			BEGIN
				write( W, sym);
				IF debugmode THEN
					write(sym);
					write( W, ' ident = ');
					IF debugmode THEN
						write( ' ident = ');
						printId( id);
			END
			ELSE IF sym = cNumber then
			BEGIN
				write( W, sym);
				IF debugmode THEN
					write( sym);
					write( W, ' ident = ');
					IF debugmode THEN
						write( ' ident = ');
						writeln( W, val); 
						writeln( val);
			END

			ELSE IF sym = cString THEN
			BEGIN
				write( W, sym);
				IF debugmode THEN
					write( sym);
					write( W, ' ident = ');
					IF debugmode THEN
						write( ' ident = ');
						printId( id);
			END

			ELSE BEGIN
				writeln( W, sym);
				IF debugmode THEN
					writeln( sym);
			END;
			getSymbol( sym);
		END;
		writeln( W, sym);
		IF debugmode THEN
			writeln( sym);
			close( R); 
			close( W);
	END;

	BEGIN
	    debugmode := debug;
		IF ParamCount < 2 THEN
			BEGIN
				writeln('Not enough parameters given. Usage: ' + ParamStr(0) + ' input.pas output.out');
				halt(1);
			END
		ELSE BEGIN
			scan( ParamStr(1), ParamStr(2) );
		END;

  END.
