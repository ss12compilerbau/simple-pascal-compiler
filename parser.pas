// Program safdas;
    

    
    (* SCANNER: Aufruf (P); geht nicht, (P1); schon.
        liegt daran, da nur 1 Zeichen
        ging auch bei Variablen nicht
    *)
    
    (* SCANNER: "type t = ^xx" geht nicht. Es geht "type t = ^ xx"
        nach ^ MUSS Leerzeichen stehen ??
    *)
    
    (* PARSER
        Der Scanner erkennt cOr  nicht richtig, d.h. Scanner glaubt,
        cOr ist das Schlüsselwort OR.
        ToDo: 8 durch cOr ersetzen
        if sym = 8 then begin ret := cTrue; end;
    *)
    
    
    
    
    
    
    
    
    (***************************************************************)
    (* Beginn Parser *)
    var gRetLongInt : longint;
    var parserErrorCount : longint;

    procedure parseCodeBlock; forward;
    procedure parseDeclaration; forward;
    procedure parseExpression; forward;

    procedure parserErrorStr( errMsg : String);
    begin
        parserErrorCount := parserErrorCount +1 ;
        (writeln( '*** Error ', lineNr, '/', colNr, ': ', errMsg));
    end;
    
    procedure parserErrorSymbol( isSym : longint; shouldSym : longint);
    begin
        parserErrorCount := parserErrorCount +1 ;
        (writeln( '*** Error ', lineNr, '/', colNr, ': ', 
            'wrong Symbol ', isSym, ' should be ', shouldSym));
    end;
    
    
    procedure parserInfoStr( infoMsg : String);
    begin
        (writeln( 'Info ', lineNr, '/', colNr, ': ', infoMsg));
    end;
    
    procedure parserInfoCRLF;
    begin
        (parserInfoStr( ' '));
    end;
    
    

    procedure parserDebugStr( msg: String);
    begin
        // (writeln( msg));
    end;
    procedure parserDebugInt( code: longint);
    begin
        // (writeln( code));
    end;
    procedure parserDebugStrInt( msg : String; code: longint);
    begin
        (*
        (write( msg));
        (write( ' '));
        (write( code));
        (writeln);
        *)
    end;
    
    
    
    
    
    procedure PeekIsSymbol( sb : longint);
    var ret : longint;
    begin
        (peekSymbol);
        ret := cFalse;
        if sym = sb then begin
            ret := cTrue;
        end;
        gRetLongInt := ret;
    end;
    
    procedure parseSymbol( sb : longint);
        var ret : longint;
    begin
        (getSymbol);
        if sym = sb then begin
            ret := cTrue;
        end
        else begin
            ret := cFalse;
            (parserErrorSymbol( sym, sb));
        end;
        gRetLongInt := ret;
    end;
    
    
    procedure PeekIsRelOperator;
    var ret : longint;
    begin
        (peekSymbol);
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
        (peekSymbol);
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
        (peekSymbol);
        ret := cFalse;
        if sym = cTimes then begin ret := cTrue; end;
        if sym = cColon then begin ret := cTrue; end;
        if sym = cAnd then begin ret := cTrue; end;
        gRetLongInt := ret;
    end;
    
    procedure PeekIsSign;
    var ret : longint;
    begin
        (parserDebugStr( 'PeekIsSign'));
        (peekSymbol);
        ret := cFalse;
        if sym = cPlus then begin ret := cTrue; end;
        if sym = cMinus then begin ret := cTrue; end;
        
        (parserDebugStrInt( 'PeekIsSign', ret));
        gRetLongInt := ret;
    end;
    
    procedure PeekIsVarModifier;
    var ret : longint;
    begin
        (parserDebugStr( 'PeekIsVarModifier'));
        (peekSymbol);
        ret := cFalse;
        if sym = cPeriod then begin ret := cTrue; end;
        if sym = cPtrRef then begin ret := cTrue; end;
        
        (parserDebugStrInt( 'PeekIsVarModifier', ret));
        gRetLongInt := ret;
    end;
    
    procedure PeekIsIdentifier;
    var ret : longint;
    begin
        (peekSymbol);
        ret := cFalse;
        if sym = cIdent then begin
            ret := cTrue;
        end;
        gRetLongInt := ret;
    end;

    procedure parseIdentifier;
        var ret : longint;
    begin
        (getSymbol);
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
        (parseIdentifier);
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            (parserErrorStr( '91 101 PgmIdentifier missing'));
        end;
        gRetLongInt := ret;
    end;
    
    procedure parseUseIdentifier;
        var ret : longint;
    begin
        (parseIdentifier);
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            (parserErrorStr( '91 103 UseIdentifier missing'));
        end;
        gRetLongInt := ret;
    end;
    
    procedure parseUnitIdentifier;
        var ret : longint;
    begin
        (parseIdentifier);
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            (parserErrorStr( '91 103 UseIdentifier missing'));
        end;
        gRetLongInt := ret;
    end;
    
    procedure parseVarIdentifierTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseVarIdentifierTry'));
        (PeekIsIdentifier);
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseVarIdentifierTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseVarIdentifier;
        var ret : longint;
    begin
        (parseIdentifier);
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            (parserErrorStr( '91 105 VarIdentifier missing'));
        end;
        gRetLongInt := ret;

    end;
    
    procedure parseTypeIdentifierTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseTypeIdentifierTry'));
        (PeekIsIdentifier);
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseTypeIdentifierTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseTypeIdentifier;
        var ret : longint;
    begin
        (parserDebugStr( 'parseTypeIdentifier'));
        (parseIdentifier);
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            (parserErrorStr( '91 107 TypeIdentifier missing'));
        end;
        
        (parserDebugStrInt( 'parseTypeIdentifier', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseProcIdentifier;
        var ret : longint;
    begin
        (parseIdentifier);
        // writeln( '*** ProcIdentifier ', sym, ' ', id);
        ret :=  gRetLongInt;
        if ret = cFalse then begin
            (parserErrorStr( '91 109 ProcIdentifier missing'));
        end;
        gRetLongInt := ret;
    end;
    
    
    procedure parseSimpleTypeTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseSimpleTypeTry'));
        (peekSymbol);
        ret := cFalse;
        
        if sym = cTypeLongint then begin
            ret :=  cTrue;
        end;
        if sym = cTypeString then begin
            ret :=  cTrue;
        end;
        
        (parserDebugStrInt( 'parseSimpleTypeTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseSimpleType;
        var ret : longint;
    begin
        (parserDebugStr( 'parseSimpleType'));
        
        (parseSimpleTypeTry);
        ret :=  gRetLongInt;
        
        (getSymbol);
        
        (parserDebugStrInt( 'parseSimpleType', ret));
        gRetLongInt := ret;
    end;
    
    
    
    
    procedure parseVarExtIdentifier;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        (parserDebugStr( 'parseVarExtIdentifier'));
        
        (parseVarIdentifier);
        ret :=  gRetLongInt;
        if ret = cTrue then begin
            (peekIsSymbol( cLBrak)); 
            bTry :=  gRetLongInt;
            again := bTry;
            while (again = cTrue) do begin
                if bTry = cTrue then begin
                    (getSymbol); // "["
                    (parseExpression);
                    bParse :=  gRetLongInt;
                    if bParse = cTrue then begin
                        (parseSymbol( cRBrak));
                        bParse :=  gRetLongInt;
                    end;
                end;
                if bParse = cTrue then begin
                    (PeekIsSymbol( cLBrak));
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
        
        (parserDebugStrInt( 'parseVarExtIdentifier', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseVarModifier;
    var ret : longint;
    begin
        (parserDebugStr( 'parseVarModifier'));
        
        (peekSymbol);
        if sym = cPtrRef then begin
            (getSymbol); // '^'
        end;
        
        (parseSymbol( cPeriod));
        ret := gRetLongInt;
        
        if ret = cTrue then begin
            (parseVarExtIdentifier);
            ret := gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parseVarModifier', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseVariableTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseVariableTry'));
        (parseVarIdentifierTry);
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseVariableTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseVariable;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
        (*
        var ret : longint;
        *)
    begin
        (parserDebugStr( 'parseVariable'));
        
        (parseVarExtIdentifier);
        ret :=  gRetLongInt;
        if ret = cTrue then begin
            (PeekIsVarModifier); 
            bTry :=  gRetLongInt;
            again := bTry;
            while again = cTrue do begin
                if bTry = cTrue then begin
                    (parseVarModifier);
                    bParse :=  gRetLongInt;
                end;
                if bParse = cTrue then begin
                    (PeekIsVarModifier);
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
        
        (parserDebugStrInt( 'parseVariable', ret));
        gRetLongInt := ret;
    
    end;
    
    
    procedure parseFactor;
        var ret : longint;
        var bTry: longint;
    begin
        (parserDebugStr( 'parseFactor'));
        ret := cFalse;
        
        (peekIsSign);
        bTry :=  gRetLongInt;
        if bTry = cTrue then begin
            (getSymbol); // sign
            
            (getSymbol); // sollte Nummer sein
            if sym = cNumber then begin
                ret := cTrue;
            end
            else begin
                ret := cFalse;
            end;
        end
        
        else begin // expression ?
            (peekIsSymbol( cLParen));
            bTry :=  gRetLongInt;
            if bTry = cTrue then begin
                (getSymbol); // LParen
                (parseExpression);
                ret := gRetLongInt;
                if ret = cTrue then begin
                    (parseSymbol( cRParen));
                    ret := gRetLongInt;
                end;
            end
            else begin // string
                (peekSymbol);
                if sym = cString then begin
                    (getSymbol);
                    ret := cTrue;
                end
                else begin // longint
                    (peekSymbol);
                    if sym = cNumber then begin
                        (getSymbol);
                        ret := cTrue;
                    end
                    else begin // not factor
                        (peekSymbol);
                        if sym = cNot then begin
                            (getSymbol); // not
                            (parseFactor);
                            ret := gRetLongInt;
                        end
                        else begin // Variable
                            (parseVariableTry);
                            bTry :=  gRetLongInt;
                            if bTry = cTrue then begin
                                (parseVariable);
                                ret :=  gRetLongInt;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        
        (parserDebugStrInt( 'parseFactor', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseTerm;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        (parserDebugStr( 'parseTerm'));
        
        (parseFactor);
        ret :=  gRetLongInt;
        
        (peekIsMultOperator);
        bTry :=  gRetLongInt;
        again := bTry;
        while again = cTrue do begin
            if bTry = cTrue then begin
                (getSymbol); // multOperator
                (parseFactor);
                bParse :=  gRetLongInt;
            end;
            if bParse = cTrue then begin
                (PeekIsMultOperator);
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
        
        (parserDebugStrInt( 'parseTerm', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseSimpleExpression;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        (parserDebugStr( 'parseSimpleExpression'));
        
        (parseTerm);
        ret :=  gRetLongInt;
        
        (peekIsAddOperator);
        bTry :=  gRetLongInt;
        again := bTry;
        while again = cTrue do begin
            if bTry = cTrue then begin
                (getSymbol); // addOperator
                (parseTerm);
                bParse :=  gRetLongInt;
            end;
            if bParse = cTrue then begin
                (PeekIsAddOperator);
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
        
        (parserDebugStrInt( 'parseSimpleExpression', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseExpression;
        var ret : longint;
        var bTry : longint;
    begin
        (parserDebugStr( 'parseExpression'));
        (parseSimpleExpression);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (peekIsRelOperator);
            bTry :=  gRetLongInt;
            
            if bTry = cTrue then begin
                (getSymbol); // relOperator 
                (parseSimpleExpression);
                ret :=  gRetLongInt;
            end;
        end;
        
        (parserDebugStrInt( 'parseExpression', ret));
        gRetLongInt := ret;
    end;
    
    



    





        
    procedure parseCallParameters;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        (parserDebugStr( 'parseCallParameters'));
        (PeekIsSymbol( cLParen));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (getSymbol); // ist '('
            
            (parseExpression);
            ret :=  gRetLongInt;
            if ret = cTrue then begin
                (PeekIsSymbol( cComma)); 
                bTry :=  gRetLongInt;
                again := bTry;
                while again = cTrue do begin
                    if bTry = cTrue then begin
                        (getSymbol); // ","
                        (parseExpression);
                        bParse :=  gRetLongInt;
                    end;
                    if bParse = cTrue then begin
                        (PeekIsSymbol( cComma));
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
                    (parseSymbol( cRParen)); 
                    ret :=  gRetLongInt;
                end;    
            end;
        end
        
        else begin
            ret := cTrue;
        end;
        
        (parserDebugStrInt( 'parseCallParameters', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseDefParameters;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        (parserDebugStr( 'parseDefParameters'));
        (PeekIsSymbol( cLParen));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (getSymbol); // ist '('
            
            (parseDeclaration);
            ret :=  gRetLongInt;
            if ret = cTrue then begin
                (PeekIsSymbol( cSemicolon)); 
                bTry :=  gRetLongInt;
                again := bTry;
                while again = cTrue do begin
                    if bTry = cTrue then begin
                        (getSymbol); // ";"
                        (parseDeclaration);
                        bParse :=  gRetLongInt;
                    end;
                    if bParse = cTrue then begin
                        (PeekIsSymbol( cSemicolon));
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
                    (parseSymbol( cRParen)); 
                    ret :=  gRetLongInt;
                end;    
            end;
        end
        
        else begin
            ret := cTrue;
        end;
        
        (parserDebugStrInt( 'parseDefParameters', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseType;
        var ret : longint;
        var bTry : longint;
    begin
        (parserDebugStr( 'parseType'));
        
        (peekSymbol);
        if sym = cPtrRef then begin
            (getSymbol);
        end;
        
        ret := cTrue;
        (parseSimpleTypeTry);
        bTry := gRetLongInt;
        if bTry = cTrue then begin // string oder longint
            (parseSimpleType);
            ret :=  gRetLongInt;
        end
        else begin // typeIdentifier
            (parseTypeIdentifier);
            ret :=  gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parseType', ret));
        gRetLongInt := ret;
    end;
    
    
    
    
    procedure parseDeclaration;
        var ret : longint;
        var name: String;
        var typeId: String;
        var str : string;
    begin
        (parserDebugStr( 'parseDeclaration'));
        (parseVarIdentifier);
        ret :=  gRetLongInt;
        str := 'Declaration ' + id;
        name := id;
        
        if ret = cTrue then begin
            (parseSymbol( cColon));
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseType);
            ret :=  gRetLongInt;
        end;

        if ret = cTrue then begin
            str := str + ' ' + id;
            typeId := id;
            (parserInfoStr( str));
            stInsertSymbol(name, stVar, cFalse, typeId);
        end;
        
        (parserDebugStrInt( 'parseDeclaration', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseRecordTypeTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseRecordTypeTry'));
        (PeekIsSymbol( cRecord));
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseRecordTypeTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseRecordType;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        (parserDebugStr( 'parseRecordType'));
        (parseSymbol( cRecord));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseDeclaration);
            ret :=  gRetLongInt;
        end;

        (PeekIsSymbol( cSemicolon)); 
        bTry :=  gRetLongInt;
        again := bTry;
        while again = cTrue do begin
            if bTry = cTrue then begin
                (parseSymbol( cSemicolon));
                bParse :=  gRetLongInt;
                
                if bParse = cTrue then begin
                    (parseDeclaration);
                    bParse :=  gRetLongInt;
                end;
            end;
            if bParse = cTrue then begin
                (PeekIsSymbol( cSemicolon));
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
            (parseSymbol( cEnd)); 
            ret :=  gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parseRecordType', ret));
        gRetLongInt := ret;
    end;





    
    
    
    
    procedure parseProcCallTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseProcCallTry'));
        (PeekIsSymbol( cLParen));
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseProcCallTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseProcCall;
        var ret : longint;
    begin
        (parserDebugStr( 'parseProcCall'));
        (parseSymbol( cLParen));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseProcIdentifier);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseCallParameters);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cRParen));
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon));
            ret :=  gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parseProcCall', ret));
        gRetLongInt := ret;
    end;


    procedure parseWhileStatementTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseWhileStatementTry'));
        (PeekIsSymbol( cWhile));
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseWhileStatementTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseWhileStatement;
        var ret : longint;
    begin
        (parseSymbol( cWhile));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseExpression);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cDo));
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseCodeBlock);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon));
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
    end;
    

    procedure parseIfStatementTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseIfStatementTry'));
        (PeekIsSymbol( cIf));
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseIfStatementTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseIfStatement;
        var ret : longint;
    begin
        (parseSymbol( cIf));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseExpression);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cThen));
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseCodeBlock);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin // else
            (peekSymbol);
            if sym = cElse then begin
                (getSymbol); // else
                (parseCodeBlock);
                ret :=  gRetLongInt;
            end;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon));
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
    end;


    procedure parseSimpleStatementTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseSimpleStatementTry'));
        (parseVariableTry);
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseSimpleStatementTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseSimpleStatement;
        var ret : longint;
    begin
        (parseVariable);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseSymbol( cBecomes));
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseExpression);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon));
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
    end;


    procedure parseStatementTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseStatementTry'));
        (parseSimpleStatementTry);
        ret :=  gRetLongInt;
        
        if ret = cFalse then begin
            (parseIfStatementTry);
            ret :=  gRetLongInt;
        end;
        
        if ret = cFalse then begin
            (parseWhileStatementTry);
            ret :=  gRetLongInt;
        end;
        
        if ret = cFalse then begin
            (parseProcCallTry);
            ret :=  gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parseStatementTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseStatement;
        var ret : longint;
        var bTry : longint;
    begin
        (parserDebugStr( 'parseStatement'));
        ret := cTrue;
        (parseSimpleStatementTry);
        bTry :=  gRetLongInt;
        if bTry = cTrue then begin
            (parseSimpleStatement);
            ret :=  gRetLongInt;
        end
        else begin
            (parseIfStatementTry);
            bTry :=  gRetLongInt;
            if bTry = cTrue then begin
                (parseIfStatement);
                ret :=  gRetLongInt;
            end
            else begin
                (parseWhileStatementTry);
                bTry :=  gRetLongInt;
                if bTry = cTrue then begin
                    (parseWhileStatement);
                    ret :=  gRetLongInt;
                end
                else begin
                    (parseProcCallTry);
                    bTry :=  gRetLongInt;
                    if bTry = cTrue then begin
                        (parseProcCall);
                        ret :=  gRetLongInt;
                    end
                    else begin
                        (parserErrorStr( 'parseStatement'));
                        ret := cFalse;
                    end;
                end;
            end;
        end;
        
        (parserDebugStrInt( 'parseStatement', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseStatements;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        (parserDebugStr( 'parseStatements'));
        (parseStatementTry); 
        bTry :=  gRetLongInt;
        again := bTry;
        while again = cTrue do begin
            if bTry = cTrue then begin
                (parseStatement);
                bParse :=  gRetLongInt;
            end;
            if bParse = cTrue then begin
                (parseStatementTry);
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
        
        (parserDebugStrInt( 'parseStatements', ret));
        gRetLongInt := ret;
    end;

    
    procedure parseCodeBlock;
        var ret : longint;
    begin
        (parserDebugStr( 'parseCodeBlock'));
        (parseSymbol( cBegin));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseStatements);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cEnd)); 
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
        (parserDebugStrInt( 'parseCodeBlock', ret));
    end;
    
        
    procedure parseOneTypeDeclarationTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseOneTypeDeclarationTry'));
        (parseTypeIdentifierTry);
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseOneTypeDeclarationTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseOneTypeDeclaration;
        var ret : longint;
    begin
        (parserDebugStr( 'parseOneTypeDeclaration'));
        (parseTypeIdentifier);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseSymbol( cEql));
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseRecordTypeTry);
            ret :=  gRetLongInt;
            if ret = cTrue then begin
                (parseRecordType);
                ret :=  gRetLongInt;
            end
            else begin
                parseSymbol( cPtrRef);
                ret :=  gRetLongInt;
                if ret = cTrue then begin
                    (parseTypeIdentifier);
                    ret :=  gRetLongInt;
                end;
            end;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon)); 
            ret :=  gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parseOneTypeDeclaration', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseTypeDeclarationTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseTypeDeclarationTry'));
        (PeekIsSymbol( cType));
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseTypeDeclarationTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseTypeDeclaration;
        var ret : longint;
        var again : longint;
        var bTry : longint;
        var bParse : longint;
    begin
        (parserDebugStr( 'parseTypeDeclaration'));
        
        (parseSymbol( cType));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseOneTypeDeclaration);
            ret :=  gRetLongInt;
            
            if ret = cTrue then begin
                (parseOneTypeDeclarationTry); 
                bTry :=  gRetLongInt;
                again := bTry;
                while (again = cTrue) do begin
                    if bTry = cTrue then begin
                        (parseOneTypeDeclaration);
                        bParse :=  gRetLongInt;
                    end;
                    if bParse = cTrue then begin
                        (parseOneTypeDeclarationTry); 
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
        
        (parserDebugStrInt( 'parseTypeDeclaration', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseVarDeclarationTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseVarDeclarationTry'));
        (PeekIsSymbol( cVar));
        ret :=  gRetLongInt;
        
        (parserDebugStrInt( 'parseVarDeclarationTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseVarDeclaration;
        var ret : longint;
    begin
        (parseSymbol( cVar));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseDeclaration);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon));
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
        (parseVarDeclarationTry); 
        bTry :=  gRetLongInt;
        again := bTry;
        while (again = cTrue) do begin
            if bTry = cTrue then begin
                (parseVarDeclaration);
                bParse :=  gRetLongInt;
            end;
            if bParse = cTrue then begin
                (parseVarDeclarationTry); 
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
        (parserDebugStr( 'parseProcHeading'));
        (parseSymbol( cProcedure));
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (parseProcIdentifier);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parserInfoCRLF);
            (parserInfoStr( '---------- Parse Prozedur ' + id));
            (parseDefParameters); 
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon)); 
            ret :=  gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parseProcHeading', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseProcDeclarationTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parseProcDeclarationTry'));
        (PeekIsSymbol( cProcedure));
        ret := gRetLongInt;
        
        (parserDebugStrInt( 'parseProcDeclarationTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parseProcDeclaration;
        var ret : longint;
        var fwd : longint;
    begin
        (parserDebugStr( 'parseProcDeclaration'));
        (parseProcHeading);
        ret :=  gRetLongInt;
        
        if ret = cTrue then begin
            (PeekIsSymbol( cForward));
            fwd := gRetLongInt;
            if fwd = cTrue then begin
                (parseSymbol( cForward));
            end
            else begin
                (parseVarDeclarations);
                ret :=  gRetLongInt;
        
                if ret = cTrue then begin
                    (parseCodeBlock);
                    ret := gRetLongInt;
                end;
            end
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon));
            ret :=  gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parseProcDeclaration', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parsePgmDeclarationTry;
        var ret : longint;
    begin
        (parserDebugStr( 'parsePgmDeclarationTry'));
        (parseVarDeclarationTry);
        ret :=  gRetLongInt;
        
        if ret = cFalse then begin
            (parseTypeDeclarationTry);
            ret :=  gRetLongInt;
        end;
        
        if ret = cFalse then begin
            (parseProcDeclarationTry);
            ret :=  gRetLongInt;
        end;
        
        (parserDebugStrInt( 'parsePgmDeclarationTry', ret));
        gRetLongInt := ret;
    end;
    
    procedure parsePgmDeclaration;
        var ret : longint;
        var bTry : longint;
    begin
        (parserDebugStr( 'parsePgmDeclaration'));
        ret := cTrue;
        (parseVarDeclarationTry);
        bTry := gRetLongInt;
        if bTry = cTrue then begin
            (parseVarDeclaration);
            ret :=  gRetLongInt;
        end
        else begin
            (parseTypeDeclarationTry);
            bTry :=  gRetLongInt;
            if bTry = cTrue then begin
                (parseTypeDeclaration);
                ret :=  gRetLongInt;
            end
            else begin
                (parseProcDeclarationTry);
                bTry :=  gRetLongInt;
                if bTry = cTrue then begin
                    (parseProcDeclaration);
                    ret :=  gRetLongInt;
                end
                else begin
                    (parserErrorStr( 'parsePgmDeclaration'));
                    ret := cFalse;
                end;
            end;
        end;
        
        (parserDebugStrInt( 'parsePgmDeclaration', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parseNextSymbol( sb : longint);
        // search next symbol sym
        // gReteLongInt = cTrue, if sym was founded
        // gRetLongInt = cFalse, if eof founded
        var again : longint;
    begin
        (peekSymbol);
        again := cTrue;
        if sym = sb then begin again := cFalse; end;
        if sym = cEOF then begin again := cFalse; end;
        while again = cTrue do begin
            (getSymbol);
            
            (peekSymbol);
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
        (parserDebugStr( 'parsePgmDeclarations'));
        (parsePgmDeclarationTry);
        bTry := gRetLongInt; 
        again := bTry;
        while (again = cTrue) do begin
            if bTry = cTrue then begin
                (parsePgmDeclaration);
                bParse := gRetLongInt;
            end;
            if bParse = cTrue then begin
                (* procDeclaration is parsable *)
                (parsePgmDeclarationTry);
                bTry := gRetLongInt;
                again := bTry;
            end
            else begin
                // Fehler bei PgmDeclaration
                again := cFalse;
                
                // Versuch, cProcedure zu finden
                (parseNextSymbol( cProcedure));
                if gRetLongInt = cTrue then begin
                    again := cTrue
                end;
            end;
        end;
        if bTry = cFalse then begin
            ret := cTrue;
        end
        else begin
            ret := bParse;
        end;
        
        (parserDebugStrInt( 'parsePgmDeclarations', ret));
        gRetLongInt := ret;
    end;
    
    
    procedure parsePgmHeading;
        var ret : longint;
    begin
        (parserDebugStr( 'parsePgmHeading'));
        (parseSymbol( cProgram));
        ret := gRetLongInt;
        
        if ret = cTrue then begin
            (parsePgmIdentifier);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseSymbol( cSemicolon)); 
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
        (parserDebugStrInt( 'parsePgmHeading', ret));
    end;
    
    
    procedure parsePgm;
        var ret : longint;
    begin
        (parsePgmHeading);
        ret := gRetLongInt;
        
        if ret = cTrue then begin
            (parsePgmDeclarations);
            ret :=  gRetLongInt;
        end;
        
        if ret = cTrue then begin
            (parseCodeBlock);
            ret :=  gRetLongInt;
        end;
        
        gRetLongInt := ret;
    end;
    
    
    PROCEDURE Parse( inputFile: String );
    BEGIN
        (Assign( R, inputFile));
        (Reset( R)); (NextChar);

        // (Assign( W, outputFile));
        // (Rewrite( W));
        
        (parsePgm);
        (parserInfoCRLF);
        (parserInfoStr( '-------------------------------------'));
        if parserErrorCount = 0 then begin
            (parserInfoStr( '+++ Compilierung erfolgreich +++'));
        end
        else begin
            (parserInfoStr( '+++ Compilierung fehlgeschlagen +++'));
        end;
        
        (close( R)); 
        // (close( W));
    end;

    (* end Parser *)
    (***************************************************************)
    Procedure ParserInit();
    Begin
        parserErrorCount := 0;
        (* 
        All die Initialisierung, die auf jeden Fall ausgeführt werden muss am Anfang,
        damit der Parser benutzt werden kann. Egal ob für Testing oder Compiling.
        *)
    End;

// begin
// end.
