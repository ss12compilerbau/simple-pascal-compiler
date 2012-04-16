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
	var filename: String;

	Var sym: Longint; (* speichert das nächste Symbol des Scanners *)
	Var sym2: Longint; (* drauffolgendes Symbol falls peek2CallFlag *)
	Var val: Longint; (* wenn sym = cNumber, dann speichert val den longint- Wert *)
	Var val2: Longint;
	Var id: String; (* wenn sym = cIdent, dann speichert id den Identifier *)
	Var id2: String;
	Var str: String; (* wenn sym = cString, dann speichert str den string- Wert *)
	Var str2: String;
		(* error: BOOLEAN; *)

	Var peekCallFlag : longint; (* cTrue, falls sym durch Aufruf peekSymbol *)
	Var peek2CallFlag : longint; (* cTrue, 2 Peeks in Zukunft *)

	Var ch: String; (* UCase *)
	Var chOrig: String; (* UCase *)
		(*errpos: LONGINT;*) (* never used *)
	Var R: Text;
	
	var chr10 : char;
	var chrQuote : char;

	// for {$include...} implementation
	Var lineNrTemp: Longint;
	Var colNrTemp: Integer;
	Var RTemp: Text;
	var filenameTemp: String;
	Var includeMode: Longint;

	(***************************************************
	* IO
	***************************************************)
	Var UCaseChrRet: String;
	Procedure UCaseChr(c: String);
	BEGIN
		uCaseChrRet := c;
		if c = 'a' then begin uCaseChrRet := 'A'; end;
		if c = 'b' then begin uCaseChrRet := 'B'; end;
		if c = 'c' then begin uCaseChrRet := 'C'; end;
		if c = 'd' then begin uCaseChrRet := 'D'; end;
		if c = 'e' then begin uCaseChrRet := 'E'; end;
		if c = 'f' then begin uCaseChrRet := 'F'; end;
		if c = 'g' then begin uCaseChrRet := 'G'; end;
		if c = 'h' then begin uCaseChrRet := 'H'; end;
		if c = 'i' then begin uCaseChrRet := 'I'; end;
		if c = 'j' then begin uCaseChrRet := 'J'; end;
		if c = 'k' then begin uCaseChrRet := 'K'; end;
		if c = 'l' then begin uCaseChrRet := 'L'; end;
		if c = 'm' then begin uCaseChrRet := 'M'; end;
		if c = 'n' then begin uCaseChrRet := 'N'; end;
		if c = 'o' then begin uCaseChrRet := 'O'; end;
		if c = 'p' then begin uCaseChrRet := 'P'; end;
		if c = 'q' then begin uCaseChrRet := 'Q'; end;
		if c = 'r' then begin uCaseChrRet := 'R'; end;
		if c = 's' then begin uCaseChrRet := 'S'; end;
		if c = 't' then begin uCaseChrRet := 'T'; end;
		if c = 'u' then begin uCaseChrRet := 'U'; end;
		if c = 'v' then begin uCaseChrRet := 'V'; end;
		if c = 'w' then begin uCaseChrRet := 'W'; end;
		if c = 'x' then begin uCaseChrRet := 'X'; end;
		if c = 'y' then begin uCaseChrRet := 'Y'; end;
		if c = 'z' then begin uCaseChrRet := 'Z'; end;
	END;
	
	var isEofRet : longint;
	procedure isEof;
		var b : boolean;
	begin
		b := eof(R);
		if b = true then begin isEofRet := cTrue; end
		else begin isEofRet := cFalse; end;
	end;

	PROCEDURE NextChar;
	var c: Char;
	//var c10: Char;
	BEGIN
		(Read(R, c));
		chOrig := c;
		(UCaseChr(c));
		ch := UCaseChrRet;
		colNr := colNr + 1;
		//c10 := chr10;
		IF ch = chr10 THEN BEGIN lineNr := lineNr + 1; colNr := 1; END;
		
		isEof;
		If isEofRet = cTrue then begin
			if includeMode = cTrue then begin
				R := RTemp;
				colNr := colNrTemp;
				lineNr := lineNrTemp;
				filename := filenameTemp;
				includeMode := cFalse;
				NextChar;
			end;
		end;
	END;

	PROCEDURE Mark(msgType: String; msg: STRING);
	BEGIN
		(Write(msgType, ' at Pos ', lineNr, ':', colNr, ' in ' + filename + ', ', msg));
	END;

	PROCEDURE MarkLn(msgType: String; msg: STRING);
	BEGIN
		(Mark(msgType, msg));
		(Writeln);
	END;


	Procedure errorMsg(msg: STRING);
		var s : string;
	Begin
		s := '*** Error';
		Markln(s, msg);
	End;

	Procedure infoMsg(msg: STRING);
		var s : string;
	Begin	
		s := 'Info';
		Markln(s, msg);
	End;

	(* true, falls ch eine Ziffer *)
	Var isDigitRet: Longint;
	Procedure isDigit( ch: String);
	BEGIN
		isDigitRet := cFalse;
		if ch >= '0' then begin
			if ch <= '9' then begin
				isDigitRet := cTrue;
			end;
		end;
	END;

	(* true, falls ch ein Buchstabe *)
	Var isLetterRet: Longint;
	Procedure isLetter( ch: String);
	BEGIN
		isLetterRet := cFalse;
		if ch >= 'a' then begin
			if ch <= 'z' then begin
				isLetterRet := cTrue;
			end;
		end;
		if ch >= 'A' then begin
			if ch <= 'Z' then begin
				isLetterRet := cTrue;
			end;
		end;
	END;

	(* true, falls ch letter oder digit *)
	Var isLetterOrDigitRet: Longint;
	Procedure isLetterOrDigit( ch: String);
	BEGIN
		isLetterOrDigitRet := cFalse;
		(isLetter(ch));
		if isLetterRet = cTrue then begin
			isLetterOrDigitRet := cTrue;
		end;
		(isDigit(ch));
		if isDigitRet = cTrue then begin
			isLetterOrDigitRet := cTrue;
		end;
	END;

	Procedure setSymToKeywordOrIdent;
	Begin
		sym := cIdent;
		if id = 'DO' then begin sym := cDo; end;
		if id = 'IF' then begin sym := cIf; end;
		if id = 'TypeLongint' then begin sym := cTypeLongint; end;
		if id = 'TypeString' then begin sym := cTypeString; end;
		if id = 'OR' then begin sym := cOr; end;
		if id = 'END' then begin sym := cEnd; end;
		if id = 'NIL' then begin sym := cNil; end;
		if id = 'VAR' then begin sym := cVar; end;
		if id = 'ELSE' then begin sym := cElse; end;
		if id = 'THEN' then begin sym := cThen; end;
		if id = 'TYPE' then begin sym := cType; end;
		if id = 'BEGIN' then begin sym := cBegin; end;
		if id = 'FORWARD' then begin sym := cForward; end;
		if id = 'WHILE' then begin sym := cWhile; end;
		if id = 'RECORD' then begin sym := cRecord; end;
		if id = 'PROCEDURE' then begin sym := cProcedure; end;
		if id = 'PROGRAM' then begin sym := cProgram; end;

	End;

	(* Liefert das nächste Symbol aus der Input- Datei *)
	(* PROCEDURE getSym(VAR sym: Longint); *)
	PROCEDURE getSymHard;forward;

	(* falls beim Lesen erkannt wurde, dass es sich um ein Symbol handelt *)
	(* z.B. Keyword oder Variable *)
	PROCEDURE Ident;
	BEGIN
		id := '';
		(isLetterOrDigit(ch));
		While(isLetterOrDigitRet = cTrue) Do begin
			id := id + ch;
			(NextChar);
			(isLetterOrDigit( ch));
		End;

		(setSymToKeywordOrIdent);
	END;

	(* falls beim Lesen erkannt wurde, dass es sich um ein String handelt *)
	PROCEDURE getString;
	var nextWhile: Longint;
	BEGIN
		str := '';
		(* komsumiere "'" am Anfang *)
		(NextChar);
		nextWhile := cFalse;

		if chOrig <> chrQuote then begin
			isEof;
			if isEofRet = cFalse then begin
				nextWhile := cTrue;
			end;
		end;

		While nextWhile = cTrue do begin
			str := str + chOrig;
			(NextChar);
			if chOrig = chrQuote then begin
				nextWhile := cFalse;
			end;
			
			isEof;
			if isEofRet = cTrue then begin
				nextWhile := cFalse;
			end;
		End;
		
		isEof;
		if isEofRet = cTrue then begin
			infoMsg( 'String not closed!');
		end;
		sym := cString;
		(NextChar);
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
		(IsDigit(ch));
		While  ( IsDigitRet = cTrue) do begin
			(chToNumber( ch));
			val1 := 10 * val + chToNumberRet; 
			if val1 <= cMaxNumber then begin
				val := val1;
			end
			ELSE BEGIN
				(infoMsg( 'number too large'));
				val := 0;
			END;
			(NextChar);
			(IsDigit(ch));
		End;
	END;

	(* falls beim Lesen erkannt wurde, dass es sich um einen Kommentar handelt *)
	Procedure comment;
		var inComment: Longint;
	BEGIN
		inComment := cTrue;
		(NextChar);
		WHILE inComment = cTrue DO
		BEGIN
			isEof;
			if isEofRet = cTrue THEN
			BEGIN
				(infoMsg( 'ERROR: comment not terminated'));
				EXIT;
			END;
			IF ch = '*' THEN
			BEGIN
				(nextChar);
				isEof;
				if isEofRet = cTrue THEN
				BEGIN
					infoMsg(  'ERROR: comment not terminated');
					EXIT;
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

	// Include instructions look like {$include 'filename';}
	Procedure include;
	Begin
		(NextChar);
		// consume the 'include' identifier, the next one has to be the string
		// with the file name (in str)
		(getSymbol);
		//(writeln('cur sym: ', sym));
		// consume ';}'
		(NextChar);
		(NextChar);
		// Initialize file swap
		RTemp := R;
		lineNrTemp := lineNr;
		colNrTemp := colNr;
		includeMode := cTrue;
		filenameTemp := filename;
		lineNr := 0;
		colNr := 0;
		filename := str;
		(Assign( R, str));
		(Reset( R));
		// recall getSymbol
		(getSymbol);
	END;

	(* Liefert das nächste Symbol aus der Input- Datei *)
	(* PROCEDURE getSym(VAR sym: Longint); *)
	PROCEDURE getSymHard;
		Var nextWhile : longInt;
		var symFound: longInt;
	BEGIN
		nextWhile := cFalse;
		isEof;
		if isEofRet = cFalse then begin	
			if ch <= ' ' then begin nextWhile := cTrue; end;
		end;
		
		WHILE nextWhile = cTrue DO 
		BEGIN 
			NextChar;
			
			nextWhile := cFalse;
			isEof;
			if isEofRet = cFalse then begin	
				if ch <= ' ' then begin nextWhile := cTrue; end;
			end;
		END;

		(isDigit(ch));
		(isLetter(ch));
		(* IF R.eot THEN sym := eof *)
		symFound := cFalse;
		
		isEof;
		IF isEofRet = cTrue THEN begin
			sym := cEof; 
		end
		ELSE BEGIN 
			IF ch = '&' THEN BEGIN NextChar; sym := cAnd; symFound := cTrue; END;
			IF ch = '^' THEN BEGIN NextChar; sym := cPtrRef; symFound := cTrue; END;
			IF ch = '*' THEN BEGIN NextChar; sym := cTimes; symFound := cTrue; END;
			IF ch = '+' THEN BEGIN NextChar; sym := cPlus; symFound := cTrue; END;
			IF ch = '-' THEN BEGIN NextChar; sym := cMinus; symFound := cTrue; END;
			IF ch = '=' THEN BEGIN NextChar; sym := cEql; symFound := cTrue; END;
			IF ch = '#' THEN BEGIN NextChar; sym := cNeq; symFound := cTrue; END;
			
			IF ch = '<' THEN BEGIN
				NextChar;
				IF ch = '=' THEN BEGIN
					NextChar;
					sym := cLeq;
				END
				else begin
					if ch = '>' then begin
						nextchar;
						sym := cNeq;
					end
					ELSE begin sym := cLss;	end;
				end;
				symFound := cTrue;
			END;	
			
			IF ch = '>' THEN BEGIN
				NextChar;
				IF ch = '=' THEN BEGIN
					NextChar;
					sym := cGeq;
				END
				ELSE begin sym := cGtr; END;
				symFound := cTrue;
			end;
				
			IF ch = ';' THEN BEGIN NextChar; sym := cSemicolon; symFound := cTrue; END;
			IF ch = ',' THEN BEGIN NextChar; sym := cComma; symFound := cTrue; END;
			
			IF ch = ':' THEN BEGIN
				NextChar;
				IF ch = '=' THEN
				BEGIN
					NextChar;
					sym := cBecomes;
				END
				ELSE begin sym := cColon; end;
				symFound := cTrue;
			END;
			
			IF ch = '.' THEN BEGIN NextChar; sym := cPeriod; symFound := cTrue; END;
			
			IF ch = '(' THEN BEGIN
				NextChar;
				IF ch = '*' THEN
				BEGIN
					comment;
					getSymHard;
				END
				ELSE begin sym := cLparen; end;
				symFound := cTrue;
			END;
			
			IF ch = ')' THEN BEGIN NextChar; sym := cRparen; symFound := cTrue; END;
			IF ch = '[' THEN BEGIN NextChar; sym := cLbrak; symFound := cTrue; END;
			IF ch = ']' THEN BEGIN NextChar; sym := cRbrak; symFound := cTrue; END;
			IF ch = chrQuote THEN Begin getString; symFound := cTrue; END;
			IF isDigitRet = cTrue THEN Begin Number; symFound := cTrue; END;
			IF isLetterRet = cTrue THEN Begin Ident; symFound := cTrue; END;
			IF ch = '~' THEN BEGIN NextChar; sym := cNot; symFound := cTrue; END;
			
			IF ch = '{' THEN BEGIN
				NextChar;
				If ch = '$' then begin
					NextChar;
					getSymbol;
					if id = 'INCLUDE' then begin
						include;
					end;
				end;
				symFound := cTrue;
			end;
		
			IF ch = '/' THEN
			BEGIN
				NextChar;
				IF ch = '/' THEN BEGIN
					While ch <> chr10 Do Begin
						NextChar;
					End;
					getSymbol;
				END
				ELSE begin
					errorMsg( 'Unrecognized "/"');
				END;
				symFound := cTrue;
			End;
		end;
			
		if symFound = cFalse then begin
			errorMsg( 'Unrecognized Symbol "' + ch + '"');
			NextChar;
			sym := cNull;
			// halt(1);
		END;
	end;

	procedure getSymbol;
	begin
		if peekCallFlag = cTrue then begin
			(* Symbol steht schon in sym, da letzter Aufruf peekSymbol *)
			peekCallFlag := cFalse; (* nächster Aufruf wieder holt neues Symbol *)
		end
		else begin
			if peek2CallFlag = cTrue then begin
				sym := sym2;
				id := id2;
				val := val2;
				str := str2;
				peek2CallFlag := cFalse;
				peekCallFlag := cTrue;
			end
			else begin
				(getSymHard);
				// writeln(sym);
			end;
		end;
	end;

	procedure peekSymbol;
	// holt nächstes Symbol setzt aber peekCallFlag auf cTrue
	// damit nächstes GetSymbol erkennt, dass getSymHard bereits aufger.
	begin
		if peekCallFlag = cFalse then begin
			(getSymbol);
			peekCallFlag := cTrue;
		end;
	end;
	
	procedure peek2Symbol;
		var saveSym : longint;
		var saveId : string;
		var saveVal : longint;
		var saveStr : string;
	begin
		if peek2CallFlag = cFalse then begin
			(peekSymbol);
			
			saveSym := sym; // Peek Symbol zwischenspeichern
			saveId := id;
			saveVal := val;
			saveStr := str;
			
			(getSymHard);
			
			sym2 := sym; // 2. Peek Symbol
			id2 := id;
			val2 := val;
			str2 := str;
			
			sym := saveSym;
			id := saveId;
			val := saveVal;
			str := saveStr;
			
			peek2CallFlag := cTrue;
		end;
	end;


	Procedure scanInitFile(inputFile: String);
	Begin
		(Assign( R, inputFile));
		(Reset( R)); 
		filename := inputFile;
		(NextChar);
	End;

	Procedure ScannerInit;
	Begin

		lineNr := 1;
		colNr := 1;
		includeMode := cFalse;

		cTrue := 1;
		cFalse := 0;
		
		chr10 := chr(10);
		chrQuote := chr(39); // singel Quote

		peekCallFlag := cFalse;
		peek2CallFlag := cFalse;

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

