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
    Procedure ParserInit();
    Begin
        (* 
        All die Initialisierung, die auf jeden Fall ausgeführt werden muss am Anfang,
        damit der Parser benutzt werden kann. Egal ob für Testing oder Compiling.
        *)
    End;
