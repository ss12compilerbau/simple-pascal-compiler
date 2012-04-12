		(* größte Zahl, die im Source angegeben werden darf *)
	Var cMaxNumber: Longint;

		(* symbols *)
	Var cNull: Longint; // Unknown
	Var cTimes: Longint; // *
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
	Var cIf: Longint; // IF
	Var cWhile: Longint; // WHILE
	Var cRecord: Longint; // RECORD
	Var cType: Longint; // TYPE
	Var cVar: Longint; // VAR
	Var cProcedure: Longint; // PROCEDURE
	Var cBegin: Longint; // BEGIN
	Var cProgram: Longint; // PROGRAM
	Var cEof: Longint; // EOF
	Var cString: Longint; (* Strings beginnen und enden mit ' *)
	Var cForward: Longint;
	Var cPtrRef: LongInt;
	Var cTypeLongint: LongInt;
	Var cTypeString: LongInt; 
	Var cNil: LongInt; 

	(* Konstanten *)
	Var cTrue : longint;
	Var cFalse : longint;

	Var lineNr: Longint;
	Var colNr: Integer;

	Var sym: Longint; (* speichert das nächste Symbol des Scanners *)
	Var val: Longint; (* wenn sym = cNumber, dann speichert val den longint- Wert *)
	Var id: String; (* wenn sym = cIdent, dann speichert id den Identifier *)
	Var str: String; (* wenn sym = cString, dann speichert str den string- Wert *)
		(* error: BOOLEAN; *)

	Var lastSymWasPeek : longint; (* cTrue, falls sym durch Aufruf peekSymbol *)

	Var ch: String; (* UCase *)
		(*errpos: LONGINT;*) (* never used *)
	Var R: Text;

	(***************************************************
	* IO
	***************************************************)
	PROCEDURE NextChar();
	var c: Char;
	BEGIN
		Read(R, c);
		ch := c;
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
	Procedure isDigit( ch: String);
	BEGIN
		If (ch >= '0') AND ( ch <= '9') then begin
			isDigitRet := cTrue;
		end else begin
			isDigitRet := cFalse;
		end;
	END;

	(* true, falls ch ein Buchstabe *)
	Var isLetterRet: Longint;
	Procedure isLetter( ch: String);
	BEGIN
		If ((ch >= 'a') AND (ch <= 'z')) OR ((ch >= 'A') AND (ch <= 'Z')) then begin
			isLetterRet := cTrue;
		end else begin
			isLetterRet := cFalse;
		end;
	END;

	(* true, falls ch letter oder digit *)
	Var isLetterOrDigitRet: Longint;
	Procedure isLetterOrDigit( ch: String);
	BEGIN
		isLetter(ch);
		isDigit(ch);
		If (isLetterRet = cTrue) or (isDigitRet = cTrue) then Begin
			isLetterOrDigitRet := cTrue;
		end else begin
			isLetterOrDigitRet := cFalse;
		end;
	END;

	Var UCaseRet: String;
	Procedure UCase(str: String);
	BEGIN
		uCaseRet := upcase(str);
	END;

	Procedure setSymToKeywordOrIdent;
	var idUC: String;
	Begin
		sym := cIdent;
		(UCase(id));
		idUC := UCaseRet;
		if idUC = 'DO' then begin sym := cDo end;
		if idUC = 'IF' then begin sym := cIf end;
		if idUC = 'TypeLongint' then begin sym := cTypeLongint end;
		if idUC = 'TypeString' then begin sym := cTypeString end;
		if idUC = 'OR' then begin sym := cOr end;
		if idUC = 'END' then begin sym := cEnd end;
//		if idUC = cNil, 'NIL' then begin sym :=  end;
		if idUC = 'VAR' then begin sym := cVar end;
		if idUC = 'ELSE' then begin sym := cElse end;
		if idUC = 'THEN' then begin sym := cThen end;
		if idUC = 'TYPE' then begin sym := cType end;
		if idUC = 'BEGIN' then begin sym := cBegin end;
		if idUC = 'FORWARD' then begin sym := cForward end;
		if idUC = 'WHILE' then begin sym := cWhile end;
		if idUC = 'RECORD' then begin sym := cRecord end;
		if idUC = 'PROCEDURE' then begin sym := cProcedure end;
		if idUC = 'PROGRAM' then begin sym := cProgram end;

	End;

	(* Liefert das nächste Symbol aus der Input- Datei *)
	(* PROCEDURE getSym(VAR sym: Longint); *)
	PROCEDURE getSymSub();forward;

	(* falls beim Lesen erkannt wurde, dass es sich um ein Symbol handelt *)
	(* z.B. Keyword oder Variable *)
	PROCEDURE Ident;
	BEGIN
		id := '';
		isLetterOrDigit( ch);
		While(isLetterOrDigitRet = cTrue) Do begin
			id := id + ch;
			NextChar;
			isLetterOrDigit( ch);
		End;

		(setSymToKeywordOrIdent);
	END;

	(* falls beim Lesen erkannt wurde, dass es sich um ein String handelt *)
	PROCEDURE getString;
	BEGIN
		str := '';
		(* komsumiere "'" am Anfang *)
		NextChar;
		While ( (ch <> '''') AND (not eof(R))) do begin
			str := str + ch;
			if ch = '''' then begin
				NextChar;
			end;
			NextChar;
		End;
		if eof(R) then begin
			infoMsg('String not closed!');
		end;
		sym := cString;
		NextChar;
	END;

	var chToNumberRet : LongInt;
	procedure chToNumber( ch : String);
	begin
		if ch = '0' then begin chToNumberRet := 0; end;
		if ch = '1' then begin chToNumberRet := 1; end;
		if ch = '2' then begin chToNumberRet := 2; end;
		if ch = '3' then begin chToNumberRet := 3; end;
		if ch = '4' then begin chToNumberRet := 4; end;
		if ch = '5' then begin chToNumberRet := 5; end;
		if ch = '6' then begin chToNumberRet := 6; end;
		if ch = '7' then begin chToNumberRet := 7; end;
		if ch = '8' then begin chToNumberRet := 8; end;
		if ch = '9' then begin chToNumberRet := 9; end;
	end;

	(* falls beim Lesen erkannt wurde, dass es sich um eine Zahl handelt *)
	PROCEDURE Number;
		var val1 : longint;
	BEGIN
		val := 0;
		sym := cNumber;
		IsDigit(ch);
		While  ( IsDigitRet = cTrue) do begin
			(chToNumber( ch));
			val1 := 10 * val + chToNumberRet; 
			if val1 < cMaxNumber then begin
				val := val1;
			end
			ELSE BEGIN
				infoMsg( 'number too large');
				val := 0
			END;
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
		// cChr0 := #0;

		(* symbols *)
		cNull := 0; // Unknown
		cTimes := 1; // *
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
		cIf := 44; // IF
		cWhile := 46; // WHILE
		cRecord := 55; // RECORD
		cType := 58; // TYPE
		cVar := 59; // VAR
		cProcedure := 60; // PROCEDURE
		cBegin := 61; // BEGIN
		cProgram := 62; // PROGRAM
		cEof := 64; // EOF
		cString := 98; (* Strings beginnen und enden mit ' *)
		cForward := 92;
		cPtrRef := 91; // ^
		cTypeLongint := 90;
		cTypeString := 89;
		cNil := 88;
	End;

