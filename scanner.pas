		(* größte Zahl, die im Source angegeben werden darf *)
	Var cMaxNumber: Longint;
		(* weder letter noch digit, um Ende eines Keywords zu kennzeichnen *)
	Var cChr0: Char;
	Var cIdLen: Longint; (* maximale Länge von Schlüsselwörter und Variablen etc. *)
	// Var cKWMaxNumber: Longint; (* Anzahl der Key- Wörter *)
	Var cStrLen: Longint; (* maximale Länge von Strings *)

		(* symbols *)
	Var cNull: Longint; // Unknown
	Var cTimes: Longint; // *
	Var cDiv: Longint; // DIV
	Var cMod: Longint;// MOD
	Var cAnd: Longint; // &
	Var cPlus: Longint; // +
	Var cMinus: Longint; // -
	Var cOr: Longint; // OR
	Var cEql: Longint; // =
	Var cNeq: Longint; // #
	Var cLss: Longint; // <
	Var cGeq: Longint; // >=
	Var cLeq: Longint; // <=
	Var cGtr: Longint; // >
	Var cPeriod: Longint; // .
	Var cComma: Longint; // ,
	Var cColon: Longint; // :
	Var cRparen: Longint; // )
	Var cRbrak: Longint; // ]
	Var cOf: Longint; // OF
	Var cThen: Longint; // THEN
	Var cDo: Longint; // DO
	Var cLparen: Longint; // (
	Var cLbrak: Longint; // [
	Var cNot: Longint; // ~
	Var cBecomes: Longint; // :=
	Var cNumber: Longint; // decimal number
	Var cIdent: Longint; // some identifier
	Var cSemicolon: Longint;
	Var cEnd: Longint; // END
	Var cElse: Longint; // ELSE
	Var cElsif: Longint; // ELSIF
	Var cIf: Longint; // IF
	Var cWhile: Longint; // WHILE
	Var cArray: Longint; // ARRAY
	Var cRecord: Longint; // RECORD
	Var cConst: Longint; // CONST
	Var cType: Longint; // TYPE
	Var cVar: Longint; // VAR
	Var cProcedure: Longint; // PROCEDURE
	Var cBegin: Longint; // BEGIN
	Var cProgram: Longint; // PROGRAM
	Var cModule: Longint; // MODULE
	Var cEof: Longint; // EOF
	Var cFunction: Longint;
	Var cString: Longint; (* Strings beginnen und enden mit ' *)
	Var cUses: Longint;
	Var cUnit: Longint;
	Var cInterface: Longint;
	Var cImplementation: Longint;
	Var cForward: Longint;
	Var cPtrRef: LongInt;
	Var cTypeLongint: LongInt;
	Var cTypeString: LongInt; 
	Var cNil: LongInt; 

	TYPE tStrId = ARRAY [0..32 (* cIdLen *) - 1] OF CHAR;
	TYPE tStr = ARRAY [0..1024 (* cStrLen *) - 1] OF CHAR;

	(* Konstanten *)
	Var cTrue : longint;
	Var cFalse : longint;

	Var lineNr: Longint;
	Var colNr: Integer;

	Var sym: Longint; (* speichert das nächste Symbol des Scanners *)
	Var val: Longint; (* wenn sym = cNumber, dann speichert val den longint- Wert *)
	Var id: tStrId; (* wenn sym = cIdent, dann speichert id den Identifier *)
	Var str: tStr; (* wenn sym = cString, dann speichert str den string- Wert *)
		(* error: BOOLEAN; *)

	Var lastSymWasPeek : longint; (* cTrue, falls sym durch Aufruf peekSymbol *)

	Var ch: CHAR; (* UCase *)
	Var nKW: Longint;
		(*errpos: LONGINT;*) (* never used *)
	Var R: Text;
	Var KWs: ARRAY [1..100 (* cKWMaxNumber *)] OF
			RECORD
				sym: Longint;
				id: tStrId;
			END;

	(***************************************************
	* IO
	***************************************************)
	PROCEDURE NextChar();
	BEGIN
		Read(R, ch);
		colNr := colNr + 1;
		IF ch = chr(10) THEN BEGIN lineNr := lineNr + 1; colNr := 1; END;
	END;

	PROCEDURE Mark(msgType: String; msg: STRING);
	BEGIN
		(Write(msgType, ' at Pos ', lineNr, ':', colNr, ', ', msg));
	END;

	PROCEDURE MarkLn(msgType: String; msg: STRING);
	BEGIN
		(Mark(msgType, msg));
		(Writeln);
	END;


	Procedure errorMsg(msg: STRING);
	Begin
		(Markln('Error', msg));
	End;

	Procedure infoMsg(msg: STRING);
	Begin
		(Markln('Info', msg));
	End;

	(* true, falls ch eine Ziffer *)
	Var isDigitRet: Longint;
	Procedure isDigit( ch: CHAR);
	BEGIN
		If (ch >= '0') AND ( ch <= '9') then begin
			isDigitRet := cTrue;
		end else begin
			isDigitRet := cFalse;
		end;
	END;

	(* true, falls ch ein Buchstabe *)
	Var isLetterRet: Longint;
	Procedure isLetter( ch: CHAR);
	BEGIN
		If ((ch >= 'a') AND (ch <= 'z')) OR ((ch >= 'A') AND (ch <= 'Z')) then begin
			isLetterRet := cTrue;
		end else begin
			isLetterRet := cFalse;
		end;
	END;

	(* true, falls ch letter oder digit *)
	Var isLetterOrDigitRet: Longint;
	Procedure isLetterOrDigit( ch: CHAR);
	BEGIN
		isLetter(ch);
		isDigit(ch);
		If (isLetterRet = cTrue) or (isDigitRet = cTrue) then Begin
			isLetterOrDigitRet := cTrue;
		end else begin
			isLetterOrDigitRet := cFalse;
		end;
	END;

	Var UCaseRet: Char;
	Procedure UCase(c: CHAR);
	BEGIN
		IF( (c >= 'a') AND ( c <= 'z')) THEN begin
			UCaseRet := chr( ord('A') + ord(c) - ord('a'))
		end ELSE begin
			UCaseRet := c;
		end;
	END;

	(* true, falls beide ID's gleich sind *)
	(* nicht case sensitiv *)
	Var isEquStrIdRet: Longint;
	Procedure isEquStrId( id1: tStrId; id2: tStrId);
		VAR i: Longint;
		Var equal: Longint;
		var t: Char;
	BEGIN
		equal := cTrue; i := 1;
		isLetterOrDigit( id1[i]);
		WHILE (isLetterOrDigitRet = cTrue) AND (equal = cTrue) DO
		BEGIN
			UCase(id1[i]);
			t := UCaseRet;
			UCASE(id2[i]);
			If (t = UCaseRet) then begin
				equal := cTrue;
			end else begin
				equal := cFalse;
			End;
			i := i + 1;
			isLetterOrDigit( id1[i]);
		END;
		isLetterOrDigit(id2[i]);
		If (equal = cTrue) AND (isLetterOrDigitRet = cFalse) then begin
			equal := cTrue;
		end else begin
			equal := cFalse;
		End;
		isEquStrIdRet := equal;
	END;

	(* Liefert das nächste Symbol aus der Input- Datei *)
	(* PROCEDURE getSym(VAR sym: Longint); *)
	PROCEDURE getSymSub();forward;

	(* falls beim Lesen erkannt wurde, dass es sich um ein Symbol handelt *)
	(* z.B. Keyword oder Variable *)
	PROCEDURE Ident;
		VAR i: Longint;
		Var k: Longint;
	BEGIN
		i := 0;
		isLetterOrDigit( ch);
		While(isLetterOrDigitRet = cTrue) Do begin
			IF i < cIdLen THEN
			BEGIN
				id[i] := ch;
				i := i + 1; (* INC(i); *)
			END;
			NextChar;
			isLetterOrDigit( ch);
		End;

		id[i] := cChr0;
		k := 0;

		isEquStrId(id, KWs[k].id);
		WHILE (k < nKW) AND (isEquStrIdRet = cFalse) DO
		BEGIN
			k := k + 1; (* INC(k); *)
			isEquStrId(id, KWs[k].id);
		END;

		IF k < nKW THEN Begin	sym := KWs[k].sym
		end ELSE BEGIN sym := cIdent; END
	END;

	(* falls beim Lesen erkannt wurde, dass es sich um ein String handelt *)
	PROCEDURE getString;
		var i: Longint;
	BEGIN
		(* komsumiere "'" am Anfang *)
		NextChar;
		i := 0;
		While ( (ch <> '''') AND (not eof(R))) do begin
			IF i < cStrLen THEN
			BEGIN
				str[i] := ch;
				i := i + 1; (* INC(i); *)
				if ch = '''' then begin
					NextChar;
				end;
			END;
			NextChar;
		End;
		if eof(R) then begin
			infoMsg('String not closed!');
		end;
		str[i] := cChr0;
		sym := cString;
		NextChar;
	END;

	(* falls beim Lesen erkannt wurde, dass es sich um eine Zahl handelt *)
	PROCEDURE Number;
	BEGIN
		val := 0;
		sym := cNumber;

		While  ( IsDigitRet <> cFalse) do begin
			IF val <= (cMaxNumber - ORD( ch) + ORD( '0')) DIV 10 THEN begin
				val := 10 * val + ( ORD( ch) - ORD( '0'))
			end ELSE BEGIN
				infoMsg( 'number too large');
				val := 0
			END ;
			NextChar;
			IsDigit(ch);
		End;
	END;

	(* falls beim Lesen erkannt wurde, dass es sich um einen Kommentar handelt *)
	Procedure comment;
		var inComment: Longint;
	BEGIN
		inComment := cTrue;
		NextChar;
		WHILE inComment = cTrue DO
		BEGIN
			if eof( R) THEN
			BEGIN
				infoMsg('ERROR: comment not terminated');
				EXIT
			END;
			IF( ch = '*') THEN
			BEGIN
				nextChar;
				if eof( R) THEN
				BEGIN
					infoMsg('ERROR: comment not terminated');
					EXIT
				END;
				if ch <> ')' then begin
					inComment := cTrue;
				end else begin
					inComment := cFalse;
				End;
			END;
			nextChar;
		END;
	END;

	procedure getSymbol; forward;

	(* Liefert das nächste Symbol aus der Input- Datei *)
	(* PROCEDURE getSym(VAR sym: Longint); *)
	PROCEDURE getSymSub;
	BEGIN
		(* WHILE ~R.eof & (ch <= " ") DO Texts.Read(R, ch) END; *)
		WHILE NOT EOF( R) AND ( ch <= ' ') DO BEGIN NextChar; END;

		isDigit(ch);
		isLetter(ch);
		(* IF R.eot THEN sym := eof *)
		IF EOF( R) THEN begin sym := cEof end

		ELSE IF ch = '&' THEN BEGIN NextChar; sym := cAnd END
		ELSE IF ch = '^' THEN BEGIN NextChar; sym := cPtrRef END
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
				else begin
					if ch = '>' then begin
						nextchar;
						sym := cNeq;
					end
					ELSE begin 
						sym := cLss;
					end;
				end;
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
		ELSE IF isDigitRet = cTrue THEN Begin Number; END
		ELSE IF isLetterRet = cTrue THEN Begin Ident; END
		ELSE IF ch = '~' THEN BEGIN NextChar; sym := cNot END
		ELSE IF ch = '/' THEN
		BEGIN
			NextChar;
			IF ch = '/' THEN BEGIN
				While (ch <> chr(10)) Do Begin
					NextChar;
				End;
				getSymbol;
			END
			ELSE
				infoMsg('Unrecognized "/"');
			END
		ELSE Begin
			infoMsg('Unrecognized Symbol "' + ch + '"');
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
			// writeln(sym);
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
		VAR i : Longint;
	BEGIN
		i := 0;
		isLetterOrDigit(fromString[i]);
		WHILE isLetterOrDigitRet = cTrue DO
		BEGIN
			id[i] := fromString[i];
			i := i + 1;
			isLetterOrDigit(fromString[i]);
		END;
	END;

	PROCEDURE EnterKW( sym: Longint; name: tStrID);
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

		(* größte Zahl, die im Source angegeben werden darf *)
		cMaxNumber := 1000000;
		(* weder letter noch digit, um Ende eines Keywords zu kennzeichnen *)
		cChr0 := #0;
		cIdLen := 32; (* maximale Länge von Schlüsselwörter und Variablen etc. *)
		// cKWMaxNumber := 100; (* Anzahl der Key- Wörter *)
		cStrLen := 1024; (* maximale Länge von Strings *)

		(* symbols *)
		cNull := 0; // Unknown
		cTimes := 1; // *
		cDiv := 3; // DIV
		cMod := 4;// MOD
		cAnd := 5; // &
		cPlus := 6; // +
		cMinus := 7; // -
		cOr := 8; // OR
		cEql := 9; // =
		cNeq := 10; // #
		cLss := 11; // <
		cGeq := 12; // >=
		cLeq := 13; // <=
		cGtr := 14; // >
		cPeriod := 18; // .
		cComma := 19; // ,
		cColon := 20; // :
		cRparen := 22; // )
		cRbrak := 23; // ]
		cOf := 25; // OF
		cThen := 26; // THEN
		cDo := 27; // DO
		cLparen := 29; // (
		cLbrak := 30; // [
		cNot := 32; // ~
		cBecomes := 33; // :=
		cNumber := 34; // decimal number
		cIdent := 37; // some identifier
		cSemicolon := 38; // ;
		cEnd := 40; // END
		cElse := 41; // ELSE
		cElsif := 42; // ELSIF
		cIf := 44; // IF
		cWhile := 46; // WHILE
		cArray := 54; // ARRAY
		cRecord := 55; // RECORD
		cConst := 57; // CONST
		cType := 58; // TYPE
		cVar := 59; // VAR
		cProcedure := 60; // PROCEDURE
		cBegin := 61; // BEGIN
		cProgram := 62; // PROGRAM
		cModule := 63; // MODULE
		cEof := 64; // EOF
		cFunction := 97;
		cString := 98; (* Strings beginnen und enden mit ' *)
		cUses := 96;
		cUnit := 95;
		cInterface := 94;
		cImplementation := 93;
		cForward := 92;
		cPtrRef := 91; // ^
		cTypeLongint := 90;
		cTypeString := 89;
		cNil := 88;
		


		// Counter für KeyWords
		nKW := 0;
		EnterKW( cNull, 'BY');
		EnterKW( cDo, 'DO');
		EnterKW( cIf, 'IF');
		EnterKW( cTypeLongint, 'TypeLongint');
		EnterKW( cTypeString, 'TypeString');
		EnterKW( cOf, 'OF');
		EnterKW( cOr, 'OR');
		EnterKW( cNull, 'TO');
		EnterKW( cEnd, 'END');
		EnterKW( cNull, 'FOR');
		EnterKW( cMod, 'MOD');
//		EnterKW( cNil, 'NIL');
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

		EnterKW( cUses, 'USES');
		EnterKW( cUnit, 'UNIT');
		EnterKW( cInterface, 'INTERFACE');
		EnterKW( cImplementation, 'IMPLEMENTATION');
	End;

