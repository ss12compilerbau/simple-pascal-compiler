    
 
	
    
    
    (***************************************************************)
    (* Beginn Parser *)
    var gRetLongInt : longint;
    var parserErrorCount : longint;
    
    var parserDeclName : string; // name von parseDeclaration gesetzt
    var parserDeclType : string; // type, von parseDeclaration gesetzt
    var parserDeclIsPtrType : longInt; // von parseType gesetzt
    var parserUseSymTab : longint;
    var parserPrintSymTab : longint;

    

    procedure parseCodeBlock; forward;
    procedure parseDeclaration; forward;
    procedure parseExpression(item: ptItem); forward;

    procedure parserErrorStr( errMsg : String);
    begin
        parserErrorCount := parserErrorCount +1 ;
        errorMsg( 'Parser: ' + errMsg);
    end;
    
    procedure parserErrorSymbol( isSym : longint; shouldSym : longint);
    begin
        parserErrorCount := parserErrorCount +1 ;
        errorMsg( 'Parser: wrong Symbol: ');
        Writeln(isSym, ' should be ', shouldSym);
    end;
    
    procedure parserInfoStr( msg : String);
    begin
        infoMsg( 'Parser: ' + msg);
    end;
    
    procedure parserInfoCRLF;
    begin
        parserInfoStr( ' ');
    end;
    
    

    procedure parserDebugStr( msg: String);
    begin
        // writeln( msg);
    end;
    procedure parserDebugInt( code: longint);
    begin
        // writeln( code);
    end;
    procedure parserDebugStrInt( msg : String; code: longint);
    begin
        (*
        write( msg);
        write( ' ');
        write( code);
        writeln;
        *)
    end;
    
    procedure parserPrintStInsertSymbol( name: String;
		symbolType: String;	isPointer: Longint; varType: String);
	begin
		if isPointer = cTrue then begin
			parserInfoStr( 'stInsertSymbol(' + name + 
				', ' + symbolType + ', cTrue, ' + varType + ')');
		end
		else begin
			parserInfoStr( 'stInsertSymbol(' + name + 
				', ' + symbolType + ', cFalse, ' + varType + ')');
		end;
	end;
	
	procedure parserDebugSyms( c: longint);
	begin	
		//writeln( c, ' ', peekCallFlag, sym, id, ' ', peek2CallFlag, sym2, id2);
	end;
    
    
    
    
    procedure PeekIsSymbol( sb : longint);
    var ret : longint;
    begin
        peekSymbol;
        ret := cFalse;
        if sym = sb then begin
            ret := cTrue;
        end;
        gRetLongInt := ret;
    end;
    
    procedure parseSymbol( sb : longint);
        var ret : longint;
    begin
        getSymbol;
        if sym = sb then begin
            ret := cTrue;
        end
        else begin
            ret := cFalse;
            parserErrorSymbol( sym, sb);
        end;
        gRetLongInt := ret;
    end;
    
    
    procedure PeekIsRelOperator;
    var ret : longint;
    begin
        peekSymbol;
        ret := cFalse;
        if sym = cEql then begin ret := cTrue; end;
        if sym = cNeq then begin ret := cTrue; end;
        if sym = cLss then begin ret := cTrue; end;
        if sym = cLeq then begin ret := cTrue; end;
        if sym = cGtr then begin ret := cTrue; end;
        if sym = cGeq then begin ret := cTrue; end;
        gRetLongInt := ret;
    end;
    
    procedure PeekIsAddOperator;
    var ret : longint;
    begin
        peekSymbol;
        ret := cFalse;
        if sym = cPlus then begin ret := cTrue; end;
        if sym = cMinus then begin ret := cTrue; end;
        // ToDo: 8 durch cOr ersetzen
        if sym = 8 then begin ret := cTrue; end;
        gRetLongInt := ret;
    end;
    
    procedure PeekIsMultOperator;
    var ret : longint;
    begin
        peekSymbol;
        ret := cFalse;
        if sym = cTimes then begin ret := cTrue; end;
        if sym = cColon then begin ret := cTrue; end;
        if sym = cAnd then begin ret := cTrue; end;
        gRetLongInt := ret;
    end;
    
    procedure PeekIsSign;
    var ret : longint;
    begin
        parserDebugStr( 'PeekIsSign');
        peekSymbol;
        ret := cFalse;
        if sym = cPlus then begin ret := cTrue; end;
        if sym = cMinus then begin ret := cTrue; end;
        
        parserDebugStrInt( 'PeekIsSign', ret);
        gRetLongInt := ret;
    end;
    
    procedure PeekIsVarModifier;
    var ret : longint;
    begin
        parserDebugStr( 'PeekIsVarModifier');
        peekSymbol;
        ret := cFalse;
        if sym = cPeriod then begin ret := cTrue; end;
        if sym = cPtrRef then begin ret := cTrue; end;
        
        parserDebugStrInt( 'PeekIsVarModifier', ret);
        gRetLongInt := ret;
    end;
    
    procedure PeekIsIdentifier;
    var ret : longint;
    begin
        peekSymbol;
        ret := cFalse;
        if sym = cIdent then begin
            ret := cTrue;
        end;
        gRetLongInt := ret;
    end;

    procedure parseIdentifier;
        var ret : longint;
    begin
        getSymbol;
        if sym = cIdent then begin
            ret := cTrue;
        end
        else begin
            ret := cFalse;
        end;
        
        gRetLongInt := ret;
    end;
    
    procedure parsePgmIdentifier;
        var ret : longint;
    begin
        parseIdentifier;
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            parserErrorStr( '91 101 PgmIdentifier missing');
        end;
        gRetLongInt := ret;
    end;
    
    procedure parseUseIdentifier;
        var ret : longint;
    begin
        parseIdentifier;
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            parserErrorStr( '91 103 UseIdentifier missing');
        end;
        gRetLongInt := ret;
    end;
    
    procedure parseUnitIdentifier;
        var ret : longint;
    begin
        parseIdentifier;
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            parserErrorStr( '91 103 UseIdentifier missing');
        end;
        gRetLongInt := ret;
    end;
    
    procedure parseVarIdentifierTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseVarIdentifierTry');
        PeekIsIdentifier;
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseVarIdentifierTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseVarIdentifier;
        var ret : longint;
    begin
        parseIdentifier;
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            parserErrorStr( '91 105 VarIdentifier missing');
        end;
        gRetLongInt := ret;

    end;
    
    procedure parseTypeIdentifierTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseTypeIdentifierTry');
        PeekIsIdentifier;
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseTypeIdentifierTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseTypeIdentifier;
        var ret : longint;
    begin
        parserDebugStr( 'parseTypeIdentifier');
        parseIdentifier;
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            parserErrorStr( '91 107 TypeIdentifier missing');
        end;
        
        parserDebugStrInt( 'parseTypeIdentifier', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseProcIdentifierTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseProcIdentifierTry');
        PeekIsIdentifier;
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseProcIdentifierTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseProcIdentifier;
        var ret : longint;
    begin
		parserDebugStr( 'parseProcIdentifier');
        parseIdentifier;
        // writeln( '*** ProcIdentifier ', sym, ' ', id);
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            parserErrorStr( '91 109 ProcIdentifier missing');
        end;
        
        parserDebugStrInt( 'parseProcIdentifier', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseSimpleTypeTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseSimpleTypeTry');
        peekSymbol;
        ret := cFalse;
        
        if sym = cTypeLongint then begin
            ret :=  cTrue;
        end;
        if sym = cTypeString then begin
            ret :=  cTrue;
        end;
        if sym = cTypeChar then begin
            ret :=  cTrue;
        end;
        if sym = cTypeText then begin
            ret :=  cTrue;
        end;
        
        parserDebugStrInt( 'parseSimpleTypeTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseSimpleType;
        var ret : longint;
    begin
        parserDebugStr( 'parseSimpleType');
        
        parseSimpleTypeTry;
        ret :=  gRetLongInt;
        
        getSymbol;
        
        parserDebugStrInt( 'parseSimpleType', ret);
        gRetLongInt := ret;
    end;
    
    
    
    
    procedure parseVarExtIdentifier(item: ptItem);
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        parserDebugStr( 'parseVarExtIdentifier');
        parseVarIdentifier;
        ret :=  gRetLongInt;
        if ret = cTrue then begin
            stFindSymbol(stCurrentScope, id);
            if stFindSymbolRet <> Nil then begin
                item^.fMode := mVar;
                item^.fType := stFindSymbolRet^.fType;
                if stCurrentScope^.fParent = Nil then begin // Global scope
                    item^.fReg := 28;
                end else begin
                    item^.fReg := 27;
                end;
                item^.fOffset := stFindSymbolRet^.fOffset;
            end else begin
                errorMsg('parseVarExtIdentifier: Variable not found');
            end;

            peekIsSymbol( cLBrak); 
            bTry :=  gRetLongInt;
            again := bTry;
            while (again = cTrue) do begin
                if bTry = cTrue then begin
                    getSymbol; // "["
                    parseExpression(item);
                    bParse :=  gRetLongInt;
                    if bParse = cTrue then begin
                        parseSymbol( cRBrak);
                        bParse :=  gRetLongInt;
                    end;
                end;
                if bParse = cTrue then begin
                    PeekIsSymbol( cLBrak);
                    bTry :=  gRetLongInt;
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
        end;
        
        parserDebugStrInt( 'parseVarExtIdentifier', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseVarModifier;
    var ret : longint;
    begin
        parserDebugStr( 'parseVarModifier');
        
        peekSymbol;
        if sym = cPtrRef then begin
            getSymbol; // '^'
        end;
        
        parseSymbol( cPeriod);
        ret := gRetLongInt;
        
        if ret = cTrue then begin
            parseVarExtIdentifier(Nil);
            ret := gRetLongInt;
        end;
        
        parserDebugStrInt( 'parseVarModifier', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseVariableTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseVariableTry');
        parseVarIdentifierTry;
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseVariableTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseVariable(item: ptItem);
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
        (*
        var ret : longint;
        *)
    begin
        parserDebugStr( 'parseVariable');
        parseVarExtIdentifier(item);
        ret :=  gRetLongInt;
        if ret = cTrue then begin
            PeekIsVarModifier; 
            bTry :=  gRetLongInt;
            again := bTry;
            while again = cTrue do begin
                if bTry = cTrue then begin
                    parseVarModifier;
                    bParse :=  gRetLongInt;
                end;
                if bParse = cTrue then begin
                    PeekIsVarModifier;
                    bTry :=  gRetLongInt;
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
        end;
        
        parserDebugStrInt( 'parseVariable', ret);
        gRetLongInt := ret;
    
    end;
    
    
    procedure parseFactor(item: ptItem);
        var ret : longint;
        var bTry: longint;
    begin
        parserDebugStr( 'parseFactor');
        ret := cFalse;
        
        peekIsSign;
        bTry :=  gRetLongInt;
        if bTry = cTrue then begin
            getSymbol; // sign
            
            getSymbol; // sollte Nummer sein
            if sym = cNumber then begin
                ret := cTrue;
            end
            else begin
                ret := cFalse;
            end;
        end
        
        else begin // expression ?
            peekIsSymbol( cLParen);
            bTry :=  gRetLongInt;
            if bTry = cTrue then begin
                getSymbol; // LParen
                parseExpression(item);
                ret := gRetLongInt;
                if ret = cTrue then begin
                    parseSymbol( cRParen);
                    ret := gRetLongInt;
                end;
            end
            else begin // string
                peekSymbol;
                if sym = cString then begin
                    getSymbol;
                    ret := cTrue;
                end
                else begin // longint
                    peekSymbol;
                    if sym = cNumber then begin
                        item^.fMode := mConst;
                        item^.fType := stLongintType;
                        item^.fValue := val;
                        getSymbol;
                        ret := cTrue;
                    end
                    else begin // not factor
                        peekSymbol;
                        if sym = cNot then begin
                            getSymbol; // not
                            parseFactor(item);
                            ret := gRetLongInt;
                            if ret = cTrue then begin
								if item^.fType = stBooleanType then begin
									if item^.fValue = cTrue then begin
										item^.fValue := cFalse;
									end
									else begin
										item^.fValue := cTrue;
									end;
								end
								else begin
									errorMsg( 'parseFactor - Not: boolean expressions expected');
									ret := cFalse;
								end;
                            end;
                        end
                        else begin
							if sym = cNil then begin
								getSymbol; // nil
								ret := gRetLongInt;
							end
							else begin // Variable
								parseVariableTry;
								bTry :=  gRetLongInt;
								if bTry = cTrue then begin
									parseVariable(item);
									ret :=  gRetLongInt;
								end;
							end;
                        end;
                    end;
                end;
            end;
        end;
        
        (parserDebugStrInt( 'parseFactor', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseTerm(item: ptItem);
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
        var rightItem: ptItem;
        var multOperator: longint;
    begin
        parserDebugStr( 'parseTerm');
        parseFactor(item);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
			peekIsMultOperator;
			bTry :=  gRetLongInt;
			again := bTry;
			while again = cTrue do begin
				if bTry = cTrue then begin
					getSymbol; // multOperator
					multOperator := Sym;
					new( rightItem);
					parseFactor(rightItem);
					bParse :=  gRetLongInt;
				end;
				if bParse = cTrue then begin
					cgTerm(item, rightItem, multOperator);
					if cgTermRet = cTrue then begin
						PeekIsMultOperator; // weiteres * ?
						bTry :=  gRetLongInt;
						again := bTry;
					end
					else begin
						bTry := cTrue;
						again := cFalse;
					end;
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
		end;
        
        parserDebugStrInt( 'parseTerm', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseSimpleExpression(item: ptItem);
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
        var rightItem: ptItem;
        var addOperator: longint;
    begin
        parserDebugStr( 'parseSimpleExpression');
        parseTerm(item);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
			peekIsAddOperator;
			bTry :=  gRetLongInt;
			again := bTry;
			while again = cTrue do begin
				if bTry = cTrue then begin
					getSymbol; // addOperator
					addOperator := Sym;
					new( rightItem);
					parseTerm(rightItem);
					bParse :=  gRetLongInt;
				end;
				if bParse = cTrue then begin
					cgSimpleExpression( item, rightItem, addOperator);
					if cgSimpleExpressionRet = cTrue then begin
						PeekIsAddOperator;
						bTry :=  gRetLongInt;
						again := bTry;
					end
					else begin
						bTry := cTrue;
						again := cFalse;
					end;
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
		end;
        
        parserDebugStrInt( 'parseSimpleExpression', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseExpression(item: ptItem);
        var ret : longint;
        var bTry : longint;
        var rightItem: ptItem;
        var relOperator: longint;
    begin
        parserDebugStr( 'parseExpression');
        parseSimpleExpression(item);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            peekIsRelOperator;
            bTry :=  gRetLongInt;
            
            if bTry = cTrue then begin
                getSymbol; // relOperator 
                relOperator := Sym;
				new( rightItem);
                parseSimpleExpression(rightItem);
                ret :=  gRetLongInt;
                
                if ret = cTrue then begin
					cgExpression( item, rightItem, relOperator);
					ret := cgExpressionRet;
                end;
            end;
        end;
        
        parserDebugStrInt( 'parseExpression', ret);
        gRetLongInt := ret;
    end;
    

        
    procedure parseCallParameters;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
        var item: ptItem;
    begin
        parserDebugStr( 'parseCallParameters');
        PeekIsSymbol( cLParen);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            getSymbol; // ist '('
            New(item);
            parseExpression(item);
            ret :=  gRetLongInt;
            if ret = cTrue then begin
                PeekIsSymbol( cComma); 
                bTry :=  gRetLongInt;
                again := bTry;
                while again = cTrue do begin
                    if bTry = cTrue then begin
                        getSymbol; // ","
                        parseExpression(item);		
                        bParse :=  gRetLongInt;
                    end;
                    if bParse = cTrue then begin
                        PeekIsSymbol( cComma);
                        bTry :=  gRetLongInt;
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
                    parseSymbol( cRParen); 
                    ret :=  gRetLongInt;
                end;    
            end;
        end
        
        else begin
            ret := cTrue;
        end;
        
        parserDebugStrInt( 'parseCallParameters', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseDefParameters;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        parserDebugStr( 'parseDefParameters');
        PeekIsSymbol( cLParen);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            getSymbol; // ist '('
            
            parseDeclaration;
            ret :=  gRetLongInt;
            if ret = cTrue then begin
                PeekIsSymbol( cSemicolon); 
                bTry :=  gRetLongInt;
                again := bTry;
                while again = cTrue do begin
                    if bTry = cTrue then begin
                        getSymbol; // ";"
                        parseDeclaration;
                        bParse :=  gRetLongInt;
                    end;
                    if bParse = cTrue then begin
                        PeekIsSymbol( cSemicolon);
                        bTry :=  gRetLongInt;
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
                    parseSymbol( cRParen); 
                    ret :=  gRetLongInt;
                end;    
            end;
        end
        
        else begin
            ret := cTrue;
        end;
        
        parserDebugStrInt( 'parseDefParameters', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseType;
        var ret : longint;
        var bTry : longint;
    begin
        parserDebugStr( 'parseType');
        
        parserDeclIsPtrType := cFalse;
        peekSymbol;
        if sym = cPtrRef then begin
			parserDeclIsPtrType := cTrue;
            getSymbol;
        end;
        
        ret := cTrue;
        parseSimpleTypeTry;
        bTry := gRetLongInt;
        if bTry = cTrue then begin // string oder longint
            parseSimpleType;
            ret :=  gRetLongInt;
        end
        else begin // typeIdentifier
            parseTypeIdentifier;
            ret :=  gRetLongInt;
        end;
        
        parserDebugStrInt( 'parseType', ret);
        gRetLongInt := ret;
    end;
    
    
    
    
    procedure parseDeclaration;
        var ret : longint;
        var str : string;
    begin
        parserDebugStr( 'parseDeclaration');
        parseVarIdentifier;
        ret :=  gRetLongInt;
        
        parserDeclName := '';
        if ret = cTrue then begin
			str := 'Declaration ' + id;
			parserDeclName := id;
        end;
        
        
        if ret = cTrue then begin
            parseSymbol( cColon);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseType;
            ret :=  gRetLongInt;
        end;

		parserDeclType := '';
        if ret = cTrue then begin
            str := str + ' ' + id;
            parserDeclType := id;
            parserInfoStr( str);
            
            if parserUseSymTab = cTrue then begin
				stInsertSymbol( parserDeclName, stVar, 
					parserDeclIsPtrType, parserDeclType);
			end;
			if parserPrintSymTab = cTrue then begin
				parserPrintStInsertSymbol( parserDeclName, stVar, 
					parserDeclIsPtrType, parserDeclType);
			end;

			
			
        end;
        
        parserDebugStrInt( 'parseDeclaration', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseRecordTypeTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseRecordTypeTry');
        PeekIsSymbol( cRecord);
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseRecordTypeTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseRecordType;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        parserDebugStr( 'parseRecordType');
        parseSymbol( cRecord);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            parseDeclaration;
            ret :=  gRetLongInt;
        end;

        peekIsSymbol( cSemicolon); 
        bTry :=  gRetLongInt;
        again := bTry;
        while again = cTrue do begin
            if bTry = cTrue then begin
                parseSymbol( cSemicolon);
                bParse :=  gRetLongInt;
                
                if bParse = cTrue then begin
                    parseDeclaration;
                    bParse :=  gRetLongInt;
                end;
            end;
            if bParse = cTrue then begin
                PeekIsSymbol( cSemicolon);
                bTry :=  gRetLongInt;
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
            parseSymbol( cEnd); 
            ret :=  gRetLongInt;
        end;
        
        parserDebugStrInt( 'parseRecordType', ret);
        gRetLongInt := ret;
    end;


procedure parseArrayTypeTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseArrayTypeTry');
        PeekIsSymbol( cArray);
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseArrayTypeTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseArrayType;
        var ret : longint;
    begin
        parserDebugStr( 'parseArrayType');
        parseSymbol( cArray);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            parseSymbol( cOf);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseTypeIdentifier;
			ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
			writeln('############## array of ', id);
        end;
        
        parserDebugStrInt( 'parseArrayType', ret);
        gRetLongInt := ret;
    end;



    procedure parseProcCallTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseProcCallTry');

		ret := cFalse;
		parseProcIdentifierTry;
		if gRetLongInt = cTrue then begin
			peek2Symbol;
			if sym2 = cLParen then begin ret := cTrue; end;
			if sym2 = cSemicolon then begin ret := cTrue; end;
		end;

        parserDebugSyms(111);
        parserDebugStrInt( 'parseProcCallTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseProcCall;
        var ret : longint;
    begin
        parserDebugStr( 'parseProcCall');
       
        parseProcIdentifier;
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            parseCallParameters;
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cSemicolon);
            ret :=  gRetLongInt;
        end;
        
        parserDebugStrInt( 'parseProcCall', ret);
        gRetLongInt := ret;
    end;


    procedure parseWhileStatementTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseWhileStatementTry');
        PeekIsSymbol( cWhile);
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseWhileStatementTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseWhileStatement;
        var ret : longint;
        Var item: ptItem;
        Var bJumpAddress: Longint;
    begin
        parseSymbol( cWhile);
        ret :=  gRetLongInt;
        if ret = cTrue then begin
            New(item);
            bJumpAddress := PC;
            parseExpression(item);
            ret :=  gRetLongInt;
            if ret = cTrue then begin
                if item^.fType = stBooleanType then begin
                    cgLoadBool(item);
                    cJump(item);
                    cgFixLink(item^.fTru);
                end else begin
					errorMsg( 'parseWhileStatement: boolean expressions expected');
					ret := cFalse;
                end;
            end;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cDo);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseCodeBlock;
            ret :=  gRetLongInt;
            bJump(bJumpAddress);
            cgFixLink(item^.fFls);
        end;
        
        if ret = cTrue then begin
            parseSymbol( cSemicolon);
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
    end;
    

    procedure parseIfStatementTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseIfStatementTry');
        PeekIsSymbol( cIf);
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseIfStatementTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseIfStatement;
        var ret : longint;
        var item: ptItem;
        var fJumpAddress: Longint;
    begin
        parseSymbol( cIf);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            New(item);
            parseExpression(item);
            ret :=  gRetLongInt;
            if ret = cTrue then begin
                if item^.fType = stBooleanType then begin
                    cgLoadBool(item);
                    cJump(item);
                    cgFixLink(item^.fTru);
                end else begin
					errorMsg( 'parseIfStatement: boolean expressions expected');
					ret := cFalse;
                end;
            end;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cThen);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseCodeBlock;
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin // else
            peekSymbol;
            if sym = cElse then begin
                getSymbol; // else
                fJump();
                fJumpAddress := fJumpRet;
                cgFixLink(item^.fFls);
                parseCodeBlock;
                ret :=  gRetLongInt;
                cgFixUp(fJumpAddress);
            end else begin
                cgFixLink(item^.fFls);
            end;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cSemicolon);
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
    end;


    procedure parseSimpleStatementTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseSimpleStatementTry');
        parseVariableTry;
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseSimpleStatementTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseSimpleStatement;
        var ret : longint;
        var leftItem: ptItem;
        var rightItem: ptItem;
    begin
        New(leftItem);
        New(rightItem);
        parseVariable(leftItem);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            parseSymbol( cBecomes);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseProcCallTry;
            ret :=  gRetLongInt;
            if ret = cTrue then begin
				parseProcCall;
				ret :=  gRetLongInt;
            end
            else begin
				parseExpression(rightItem);
				ret :=  gRetLongInt;
				if rightItem^.fType = stBooleanType then begin
				    writeln('Rel- Expression DLX = ', rightitem^.fValue, ' (1...True, 0...False)');
				end;
				if ret = cTrue then begin
					parseSymbol( cSemicolon);
					ret :=  gRetLongInt;
				end;
            end;
        end;
        if ret = cTrue then begin
            cgAssignmentOperator(leftItem, rightItem);
        End;
    end;


    procedure parseStatementTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseStatementTry');
        
        parseIfStatementTry;
        ret :=  gRetLongInt;
        
        if ret = cFalse then begin
            parseWhileStatementTry;
            ret :=  gRetLongInt;
        end;
        
        if ret = cFalse then begin
            parseProcCallTry;
            ret :=  gRetLongInt;
        end;
        
        if ret = cFalse then begin
            parseSimpleStatementTry;
			ret :=  gRetLongInt;
        end;
        
        parserDebugStrInt( 'parseStatementTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseStatement;
        var ret : longint;
        var bTry : longint;
    begin
        parserDebugStr( 'parseStatement');
        ret := cTrue;
        
        parseProcCallTry;
        bTry :=  gRetLongInt;
        if bTry = cTrue then begin
			(parseProcCall);
			ret :=  gRetLongInt;
        end
        else begin
            parseIfStatementTry;
            bTry :=  gRetLongInt;
            if bTry = cTrue then begin
                parseIfStatement;
                ret :=  gRetLongInt;
            end
            else begin
                parseWhileStatementTry;
                bTry :=  gRetLongInt;
                if bTry = cTrue then begin
                    parseWhileStatement;
                    ret :=  gRetLongInt;
                end
                else begin
					parseSimpleStatementTry;
					bTry :=  gRetLongInt;
					if bTry = cTrue then begin
						parseSimpleStatement;
						ret :=  gRetLongInt;
					end
                
                    
                    else begin
                        parserErrorStr( 'parseStatement');
                        ret := cFalse;
                    end;
                end;
            end;
        end;
        
        parserDebugStrInt( 'parseStatement', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseStatements;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        parserDebugStr( 'parseStatements');
        parseStatementTry; 
        bTry :=  gRetLongInt;
        again := bTry;
        while again = cTrue do begin
            if bTry = cTrue then begin
                parseStatement;
                bParse :=  gRetLongInt;
            end;
            if bParse = cTrue then begin
                parseStatementTry;
                bTry :=  gRetLongInt;
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
        gRetLongInt := ret;
    end;

    
    procedure parseCodeBlock;
        var ret : longint;
    begin
        parserDebugStr( 'parseCodeBlock');
        parseSymbol( cBegin);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            parseStatements;
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cEnd); 
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
        parserDebugStrInt( 'parseCodeBlock', ret);
    end;
    
        
    procedure parseOneTypeDeclarationTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseOneTypeDeclarationTry');
        parseTypeIdentifierTry;
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseOneTypeDeclarationTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseOneTypeDeclaration;
        var ret : longint;
        var typeId : string;
    begin
        parserDebugStr( 'parseOneTypeDeclaration');
        parseTypeIdentifier;
        ret :=  gRetLongInt;
        
        typeId := '';
        if ret = cTrue then begin
			typeId := id;
            parseSymbol( cEql);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseRecordTypeTry;
            ret :=  gRetLongInt;
            if ret = cTrue then begin
				
				if parserUseSymTab = cTrue then begin
					stBeginRecord( typeID);
				end;
				if parserPrintSymTab = cTrue then begin
					parserInfoStr( 'stBeginRecord( ' + typeID + ') ');
				end;
				
                parseRecordType;
                ret :=  gRetLongInt;
                
                if parserUseSymTab = cTrue then begin
					stEndRecord;
				end;
				if parserPrintSymTab = cTrue then begin
					parserInfoStr( 'stEndRecord');
				end;
            end
            else begin
				parseArrayTypeTry;
				ret :=  gRetLongInt;
				if ret = cTrue then begin
					// TODO, Call symtable for array of ...
					parseArrayType;
					ret :=  gRetLongInt;
				end
				else begin
					parseSymbol( cPtrRef);
					ret :=  gRetLongInt;
					if ret = cTrue then begin
						parseTypeIdentifier;
						ret :=  gRetLongInt;
						
						if parserUseSymTab = cTrue then begin
							stInsertSymbol(typeId, stType, 
								cTrue, id); // type = ... nur ^ typeName
						end;
						if parserPrintSymTab = cTrue then begin
							parserPrintStInsertSymbol(typeId, stType, 
								cTrue, id);
						end;
						
					end;
				end;
			end;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cSemicolon); 
            ret :=  gRetLongInt;
        end;
        
        parserDebugStrInt( 'parseOneTypeDeclaration', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseTypeDeclarationTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseTypeDeclarationTry');
        PeekIsSymbol( cType);
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseTypeDeclarationTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseTypeDeclaration;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        parserDebugStr( 'parseTypeDeclaration');
        
        parseSymbol( cType);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            parseOneTypeDeclaration;
            ret :=  gRetLongInt;
            
            if ret = cTrue then begin
                parseOneTypeDeclarationTry; 
                bTry :=  gRetLongInt;
                again := bTry;
                while (again = cTrue) do begin
                    if bTry = cTrue then begin
                        parseOneTypeDeclaration;
                        bParse :=  gRetLongInt;
                    end;
                    if bParse = cTrue then begin
                        parseOneTypeDeclarationTry; 
                        bTry :=  gRetLongInt;
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
            end;
        end;
        
        parserDebugStrInt( 'parseTypeDeclaration', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseVarDeclarationTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseVarDeclarationTry');
        PeekIsSymbol( cVar);
        ret :=  gRetLongInt;
        
        parserDebugStrInt( 'parseVarDeclarationTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseVarDeclaration;
        var ret : longint;
    begin
        parseSymbol( cVar);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            parseDeclaration;
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cSemicolon);
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
    end;
    
    
    procedure parseVarDeclarations;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        parseVarDeclarationTry; 
        bTry :=  gRetLongInt;
        again := bTry;
        while (again = cTrue) do begin
            if bTry = cTrue then begin
                parseVarDeclaration;
                bParse :=  gRetLongInt;
            end;
            if bParse = cTrue then begin
                parseVarDeclarationTry; 
                bTry :=  gRetLongInt;
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
        
        gRetLongInt := ret;
    end;
    
    
    procedure parseProcHeading;
        var ret : longint;
    begin
        parserDebugStr( 'parseProcHeading');
        parseSymbol( cProcedure);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            parseProcIdentifier;
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parserInfoCRLF;
            parserInfoStr( '---------- Parse Prozedur ' + id);
            
            if parserUseSymTab = cTrue then begin
				stBeginProcedure( id);
			end;
			if parserPrintSymTab = cTrue then begin
				parserInfoStr( 'stBeginProcedure( ' + id + ') ');
			end;
            
            parseDefParameters; 
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cSemicolon); 
            ret :=  gRetLongInt;
        end;
        
        parserDebugStrInt( 'parseProcHeading', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseProcDeclarationTry;
        var ret : longint;
    begin
        parserDebugStr( 'parseProcDeclarationTry');
        PeekIsSymbol( cProcedure);
        ret := gRetLongInt;
        
        parserDebugStrInt( 'parseProcDeclarationTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parseProcDeclaration;
        var ret : longint;
        var fwd : longint;
    begin
        parserDebugStr( 'parseProcDeclaration');
        parseProcHeading;
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            PeekIsSymbol( cForward);
            fwd := gRetLongInt;
            if fwd = cTrue then begin
                (parseSymbol( cForward));
            end
            else begin
                parseVarDeclarations;
                ret :=  gRetLongInt;
        
                if ret = cTrue then begin
                    parseCodeBlock;
                    ret := gRetLongInt;
                end;
            end;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cSemicolon);
            ret :=  gRetLongInt;
        end;
        
        if parserUseSymTab = cTrue then begin
			stEndProcedure;
		end;
		if parserPrintSymTab = cTrue then begin
			parserInfoStr( 'stEndProcedure');
		end;
        
        parserDebugStrInt( 'parseProcDeclaration', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parsePgmDeclarationTry;
        var ret : longint;
    begin
        parserDebugStr( 'parsePgmDeclarationTry');
        parseVarDeclarationTry;
        ret :=  gRetLongInt;
        
        if ret = cFalse then begin
            parseTypeDeclarationTry;
            ret :=  gRetLongInt;
        end;
        
        if ret = cFalse then begin
            parseProcDeclarationTry;
            ret :=  gRetLongInt;
        end;
        
        parserDebugStrInt( 'parsePgmDeclarationTry', ret);
        gRetLongInt := ret;
    end;
    
    procedure parsePgmDeclaration;
        var ret : longint;
        var bTry : longint;
    begin
        parserDebugStr( 'parsePgmDeclaration');
        ret := cTrue;
        parseVarDeclarationTry;
        bTry := gRetLongInt;
        if bTry = cTrue then begin
            parseVarDeclaration;
            ret :=  gRetLongInt;
        end
        else begin
            parseTypeDeclarationTry;
            bTry :=  gRetLongInt;
            if bTry = cTrue then begin
                parseTypeDeclaration;
                ret :=  gRetLongInt;
            end
            else begin
                parseProcDeclarationTry;
                bTry :=  gRetLongInt;
                if bTry = cTrue then begin
                    parseProcDeclaration;
                    ret :=  gRetLongInt;
                end
                else begin
                    parserErrorStr( 'parsePgmDeclaration');
                    ret := cFalse;
                end;
            end;
        end;
        
        parserDebugStrInt( 'parsePgmDeclaration', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parseNextSymbol( sb : longint);
        // search next symbol sym
        // gReteLongInt = cTrue, if sym was founded
        // gRetLongInt = cFalse, if eof founded
        var again : longint;
    begin
        peekSymbol;
        again := cTrue;
        if sym = sb then begin again := cFalse; end;
        if sym = cEOF then begin again := cFalse; end;
        while again = cTrue do begin
            getSymbol;
            
            peekSymbol;
            again := cTrue;
            if sym = sb then begin again := cFalse; end;
            if sym = cEOF then begin again := cFalse; end;
        end;
        
        gRetLongInt := cTrue;
        if sym <> sb then begin gRetLongInt := cFalse; end;
    end;
    
    procedure parsePgmDeclarations;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        parserDebugStr( 'parsePgmDeclarations');
        parsePgmDeclarationTry;
        bTry := gRetLongInt; 
        again := bTry;
        while (again = cTrue) do begin
            if bTry = cTrue then begin
                parsePgmDeclaration;
                bParse := gRetLongInt;
            end;
            if bParse = cTrue then begin
                (* procDeclaration is parsable *)
                parsePgmDeclarationTry;
                bTry := gRetLongInt;
                again := bTry;
            end
            else begin
                // Fehler bei PgmDeclaration
                again := cFalse;
                
                // Versuch, cProcedure zu finden
                parseNextSymbol( cProcedure);
                if gRetLongInt = cTrue then begin
                    again := cTrue;
                end;
            end;
        end;
        if bTry = cFalse then begin
            ret := cTrue;
        end
        else begin
            ret := bParse;
        end;
        
        parserDebugStrInt( 'parsePgmDeclarations', ret);
        gRetLongInt := ret;
    end;
    
    
    procedure parsePgmHeading;
        var ret : longint;
    begin
        parserDebugStr( 'parsePgmHeading');
        parseSymbol( cProgram);
        ret := gRetLongInt;
        
        if ret = cTrue then begin
            parsePgmIdentifier;
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseSymbol( cSemicolon); 
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
        parserDebugStrInt( 'parsePgmHeading', ret);
    end;
    
    
    procedure parsePgm;
        var ret : longint;
    begin
        parsePgmHeading;
        ret := gRetLongInt;
        
        if ret = cTrue then begin
            parsePgmDeclarations;
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            parseCodeBlock;
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
    end;
    
    
    PROCEDURE Parse( inputFile: String );
    BEGIN
        Assign( R, inputFile);
        Reset( R); NextChar;
        filename := inputFile;

        // Assign( W, outputFile);
        // Rewrite( W);
        
        parsePgm;
        parserInfoCRLF;
        parserInfoStr( '-------------------------------------');
        if parserErrorCount = 0 then begin
            parserInfoStr( '+++ parsing o.k. +++');
        end
        else begin
            parserInfoStr( '+++ parsing failed +++');
        end;
        
        close( R); 
        // close( W);
    end;

    (* end Parser *)
    Procedure ParserInit;
    Begin
        parserErrorCount := 0;
        
    End;
