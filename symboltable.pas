    // Possible symbol classes
    Var stVar: String;
    Var stType: String;
    Var stProcedure: String;
    Var stProgram: String;
    Var stField: String;

    // Possible type forms
    var stLongint: String;
    var stString: String;
    Var stPointer: String;
    Var stRecord: String;
    var stChar: String;
    var stText: String;

    Type // forward type declatation, has to be in the same Type block!
        ptSymbolTable = ^tSymbolTable;
        ptSymbol = ^tSymbol;
        ptType = ^tType;

        // a linked list of symbols, defined by the first and last symbol
        tSymbolTable = Record
            fFirst: ptSymbol;
            fLast: ptSymbol; // The last is only there for convenience reasons.
            fParent: ptSymbolTable; // to allow scopes
            fParams: ptSymbol;
            fSP: Longint // Next symbol pointer
        End;

        // an entry like Var i: Longint;
        tSymbol = Record
            fName: String; // obligatory for a valid Symbol. If not set, it's not yet filled (new)
            fClass: String; // can be VAR, TYPE, FIELD, PARAMETER
            fType: ptType; // the type object defines details
            fValue: Longint; // Number of parameters (only for Procedures)
            // fIsForward is 1 if there was a forward declaration already, but no definition. 
            // Relevant for PROCEDURE and RECORD entries.
            fIsForward: Longint;
            fIsParameter: Longint;
            fPrev: ptSymbol; // link to the previous symbol. for conveninence
            fNext: ptSymbol; // link to the next symbol
            fOffset: Longint; // To be set when a variable is declared
            fScope: ptSymbolTable; //Pointer to the symbol table
            fParams: ptSymbol
        End;

        // type descriptor record for each type (Longint, String, tType, ...)
        tType = Record
            fForm: String; // can be predefined and simple type (Longint, String, Pointer) or user defined and complex (Record)
            fFields: ptSymbolTable; // link to a field list in form of a ptSymbolTable
            fBase: ptType // base type, only used for pointers
        End;

    Var stCurrentScope: ptSymbolTable;
    var stGlobalScope: ptSymbolTable;
    Var stCurrentContext: ptSymbol;
    Var stProcedureParameters: Longint;

    var stLongintType: ptType;
    var stStringType: ptType;
    var stBooleanType: ptType;
    var stPointerType: ptType;
    var stCharType: ptType;
    var stTextType: ptType;

    var stGP: Longint;

    Procedure printSymbolTable(symbolTable: ptSymbolTable; prefix: String);forward;

    Var stCreateSymbolRet: ptSymbol;
    Procedure stCreateSymbol;
    Begin
        New(stCreateSymbolRet);
        stCreateSymbolRet^.fName := '';
        stCreateSymbolRet^.fIsForward := cFalse;
        stCreateSymbolRet^.fIsParameter := cFalse;
    End;

    Var stCreateSymbolTableRet: ptSymbolTable;
    Procedure stCreateSymbolTable(parentSymbolTable: ptSymbolTable);
    Begin
        New(stCreateSymbolTableRet);
        stCreateSymbolTableRet^.fFirst := Nil;
        stCreateSymbolTableRet^.fLast := Nil;
        stCreateSymbolTableRet^.fParent := parentSymbolTable;
        stCreateSymbolTableRet^.fSP := -4;
    End;

    var stCreateTypeRet: ptType;
    Procedure stCreateType(form: String);
    Var isSimple: Longint;
    Begin
        New(stCreateTypeRet);
        isSimple := -1; // we don't know yet
        if form = 'LONGINT' then begin isSimple := 1; end;
        if form = 'STRING' then begin isSimple := 1; end;
        if form = 'CHAR' then begin isSimple := 1; end;
        if form = 'TEXT' then begin isSimple := 1; end;
        if form = 'POINTER' then begin isSimple := 1; end;
        if form = 'BOOLEAN' then begin isSimple := 1; end;
        if form = 'RECORD' then begin isSimple := 0; end;
        if isSimple = -1 then begin
            errorMsg('Symboltable: Unrecognized Type form: ' + form);
        end else begin
            stCreateTypeRet^.fForm := form;
            If isSimple = 0 then begin
                // is a record
                stCreateSymbolTable(stCurrentScope);
                stCurrentScope := stCreateSymbolTableRet;
                stCreateTypeRet^.fFields := stCreateSymbolTableRet;
            End;
        end;
    End;

    Var stFindSymbolRet: ptSymbol;
    Procedure stFindSymbol(symbolTable: ptSymbolTable; name: String);
    Var iterator: ptSymbol;
    Var whileBool: Longint;
    var UCFName : String;
    var UCName : String;
    Begin
        // stFindSymbolRet := Nil; // should be done before calling!
        iterator := symbolTable^.fParams;
        whileBool := cFalse;
        UCName := upCase(name);

        // if not yet found
        if iterator <> Nil then begin
            Writeln('stFindSymbol - symboltable: ', symboltable^.fParams = stCurrentContext^.fParams);
            Writeln('stFindSymbol - symboltable: ', stCurrentContext^.fValue);
            Writeln('stFindSymbol - symboltable: ', symbolTable^.fParams^.fName);
            UCFName := upCase(iterator^.fName);
            Writeln(UCName, ' ', UCFName);
            if UCFName <> UCName then begin
                // AND there's more to look at
                if iterator^.fNext <> Nil then begin
                    whileBool := cTrue;
                End;
            end;
            while whileBool = cTrue do begin
                // next
                iterator := iterator^.fNext;
                // prepare whileBool
                // if not yet found
                whileBool := cFalse;
                UCFName := upCase(iterator^.fName);
                if UCFName <> UCName then begin
                    // AND there's more to look at
                    if iterator^.fNext <> Nil then begin
                        // writeln('dFS4');
                        whileBool := cTrue;
                    End;
                end;
            end;
            if UCFName = UCName then begin
                stFindSymbolRet := iterator;
            end;
        end;

        if UCFName <> UCName then begin
            if symbolTable^.fFirst <> Nil then begin
                iterator := symbolTable^.fFirst;
                whileBool := cFalse;
                // if not yet found
                UCFName := upCase(iterator^.fName);
                if UCFName <> UCName then begin
                    // AND there's more to look at
                    if iterator <> symbolTable^.fLast then begin
                        whileBool := cTrue;
                    End;
                end;
                while whileBool = cTrue do begin
                    // next
                    iterator := iterator^.fNext;
                    // prepare whileBool
                    // if not yet found
                    whileBool := cFalse;
                    UCFName := upCase(iterator^.fName);
                    if UCFName <> UCName then begin
                        // AND there's more to look at
                        if iterator <> symbolTable^.fLast then begin
                            // writeln('dFS4');
                            whileBool := cTrue;
                        End;
                    end;
                end;
                if UCFName = UCName then begin
                    stFindSymbolRet := iterator;
                end else begin
                    if symbolTable^.fParent <> Nil then begin
                        stFindSymbol(symbolTable^.fParent, name);
                    end;
                end;
            end else begin
                if symbolTable^.fParent <> Nil then begin
                    stFindSymbol(symbolTable^.fParent, name);
                end;
            end;
        end;
    End;

    Var stFindTypeRet: ptType;
    Procedure stFindType(name: String);
    var n1 : String;
    var n2 : String;
    Begin
        // writeln('dFindType start');
        stFindSymbolRet := Nil;
        stFindSymbol(stCurrentScope, name);
        if stFindSymbolRet = Nil then begin
            // writeln('dFindType 0');
            stFindTypeRet := Nil;
        end else begin
            // writeln('dFindType 1 ', stFindSymbolRet^.fName);
            n1 := upCase(stFindSymbolRet^.fName);
            n2 := upCase(name);
            if n1 = n2 then begin
                stFindTypeRet := stFindSymbolRet^.fType;
            end else begin
                errorMsg(name + ' is not a TYPE!');
            end;
        end;
        // writeln('dFindType end');
    End;

    {
    Var stSizeRet: Longint;
    Procedure stSize(typ: ptType);
    Begin
        if (typ^.fForm = stArray) then begin
            
        end else begin
            stSizeRet := 4;
        end;
    End;
    }

    // adds the symbol as the last element of the symboltable
    Procedure stSymbolTableInsert(symbol: ptSymbol; symbolTable: ptSymbolTable);
    Begin
        // writeln('d1.3.1');
        if symbolTable^.fFirst = Nil then begin
            // writeln('d1.3.2');
            symbolTable^.fFirst := symbol;
        end else begin
            // writeln('d1.3.3');
            // Writeln(symbolTable^.fFirst^.fName);
            symbolTable^.fLast^.fNext := symbol;
        end;
        // writeln('d1.3.4');
        symbolTable^.fLast := symbol;
        // Fill offset and shift SP 
        if symbol^.fClass = stVar then begin
            symbol^.fOffset := symbolTable^.fSP;
            symbolTable^.fSP := symbolTable^.fSP - 4;
        end;
        symbol^.fScope := stCurrentScope;
    End;

    Procedure createPredefinedType(typeName: String);
    Begin
        // writeln('d1.1');
        stCreateSymbol;
        stCreateSymbolRet^.fName := typeName;
        stCreateSymbolRet^.fClass := stType;
        stCreateType(typeName);
        // writeln('d1.3');
        stCreateSymbolRet^.fType := stCreateTypeRet;
        stSymbolTableInsert(stCreateSymbolRet, stCurrentScope);
        // writeln('d1.4');
    End;

    // Initialize the SymbolTable module
    procedure stInit;
    Begin
        (* Init constants *)
        stVar := 'VAR';
        stType := 'TYPE';
        stProgram := 'PROGRAM';
        stProcedure := 'PROCEDURE';
        stField := 'FIELD';

        stPointer := 'POINTER';
        stRecord := 'RECORD';

        // Create global symbol table. The only one that's parent is Nil
        stCreateSymbolTable(Nil);
        stCurrentScope := stCreateSymbolTableRet;
        stGlobalScope := stCurrentScope;

        // writeln('d1');
        // Create predefined symbols LONGINT, String
        createPredefinedType('LONGINT');
        stLongintType := stCreateSymbolRet^.fType;
        // writeln('d2');
        createPredefinedType('STRING');
        stStringType := stCreateSymbolRet^.fType;
        
        createPredefinedType('BOOLEAN');
        stBooleanType := stCreateSymbolRet^.fType;

        createPredefinedType('POINTER');
        stPointerType := stCreateSymbolRet^.fType;
        
        createPredefinedType('CHAR');
        stCharType := stCreateSymbolRet^.fType;
        
        createPredefinedType('TEXT');
        stTextType := stCreateSymbolRet^.fType;
        
        // writeln('d3');
    End;

    // erzeugt einen Eintrag für eine Procedure oder Record in der aktuellen symboltabelle
    Procedure stInsertSymbol(name: String; symbolType: String; isPointer: Longint; varType: String);
    Begin
        infoMsg( 'Symboltable: Adding new symbol ' + name);
        // Make sure the symbol doesn't exist yet.
        // writeln('dIS start');
        stFindSymbolRet := Nil;
        stFindSymbol(stCurrentScope, name);
        if stFindSymbolRet <> Nil then begin
            errorMsg( 'Symboltable - stInsertSymbol: Duplicate Entry: ' + name);
        end else begin
            // writeln('dIS1');
            stFindType(varType);
            // writeln('dIS1.1');
            if stFindTypeRet = Nil then begin
                errorMsg( 'Symboltable - stInsertSymbol: Type not defined! ' + varType);
            end else begin
                // writeln('dIS2');
                stCreateSymbol;
                stCreateSymbolRet^.fName := name;
                stCreateSymbolRet^.fClass := symbolType;
                stSymbolTableInsert(stCreateSymbolRet, stCurrentScope);
                // writeln('dIS3');
                if isPointer = cTrue then begin
                    stCreateType(stPointer);
                    stCreateTypeRet^.fBase := stFindTypeRet;
                    stCreateSymbolRet^.fType := stCreateTypeRet;
                end else begin
                    stCreateSymbolRet^.fType := stFindTypeRet;
                end;
                // writeln('dIS4');
                if stProcedureParameters = cTrue then begin
                    stCreateSymbolRet^.fIsParameter := cTrue;
                end else begin
                    stCreateSymbolRet^.fIsParameter := cFalse;
                end;

                // TODO: set fIsForward and fIsParameter fields
            end;
        end;
        // writeln('dIS end');
    End;

    // erzeugt einen Eintrag für eine Procedure oder Record in der aktuellen symboltabelle
    Procedure stInsertSymbolWithTypeObj(symbol: ptSymbol; name: String; symbolType: String; isPointer: Longint; varType: ptType);
    Begin
        infoMsg( 'Symboltable: Adding new symbol ' + name);
        // Make sure the symbol doesn't exist yet.
        // writeln('dIS start');
        stFindSymbolRet := Nil;
        stFindSymbol(stCurrentScope, name);
        if stFindSymbolRet <> Nil then begin
            errorMsg( 'Symboltable - stInsertSymbolWithTypeObj: Duplicate Entry: ' + name);
        end else begin
            // writeln('dIS1');
            if varType = Nil then begin
                errorMsg( 'Symboltable - stInsertSymbolWithTypeObj: Type not defined! ' + varType^.fForm);
            end else begin
                // writeln('dIS2');
                symbol^.fName := name;
                symbol^.fClass := symbolType;
                // stSymbolTableInsert(symbol, stCurrentScope);
                // writeln('dIS3');
                if isPointer = cTrue then begin
                    stCreateType(stPointer);
                    stCreateTypeRet^.fBase := varType;
                    symbol^.fType := stCreateTypeRet;
                end else begin
                    symbol^.fType := varType;
                end;
                // writeln('dIS4');
                if stProcedureParameters = cTrue then begin
                    symbol^.fIsParameter := cTrue;
                end else begin
                    symbol^.fIsParameter := cFalse;
                end;

                // TODO: set fIsForward and fIsParameter fields
            end;
        end;
    End;

    procedure stCreateFormalParameter(parameter: ptSymbol; paramType: ptType; paramName: String);
    begin
        stInsertSymbolWithTypeObj(parameter, paramName, stVar, cFalse, paramType);
    end;

    Procedure stBeginContext(name: String; form: String);
    Begin
        // writeln('dBC start');
        // Make sure the symbol doesn't exist yet.
        stFindSymbolRet := Nil;
        stFindSymbol(stCurrentScope, name);
        if stFindSymbolRet <> Nil then begin
            // already exists (forward or duplicate)
            // two possibilities: forward declared Type/Procedure or duplicate entry
            if stFindSymbolRet^.fIsForward = cTrue then begin
                Writeln('forward defined symbol ' + name);
                stCurrentContext := stFindSymbolRet;
                stCurrentScope := stFindSymbolRet^.fType^.fFields;
            end else begin
                // writeln('dBC 1');
                errorMsg( 'Symboltable - stBeginContext: Duplicate Entry: ' + name);
                printSymbolTable(stCurrentScope, '');
            end;
        end else begin
            // writeln('dBC 2');
            stCreateSymbol;
            stSymbolTableInsert(stCreateSymbolRet, stCurrentScope);

            stCurrentContext := stCreateSymbolRet;
            if form = stRecord then begin
                // New record symbol
                stCurrentContext^.fClass := stType;
                stCurrentContext^.fName := name;
                stCreateType(stRecord);
                stCurrentContext^.fType := stCreateTypeRet;
                stCurrentContext^ .fType^ .fForm := stRecord;
            end else begin
                // New Procedure Symbol
                stCurrentContext^.fClass := stProcedure;
                stCurrentContext^.fName := name;
                // stCurrentContext^.fType := item^.fType; // in pascal this should be after the parameter list and return type def
                New(stCurrentContext^.fParams);
                stCreateSymbolTable(stCurrentScope);
                stCurrentScope := stCreateSymbolTableRet;
                stCurrentScope^.fParams := stCurrentContext^.fParams;
            end;
        end;
        // writeln('dBC end');
    End;

    Procedure stBeginProgram(name: String);
    begin
		infoMsg( 'Symboltable: Beginning program ' + name);
        stBeginContext(name, stProgram);
    end;    

    Procedure stBeginProcedure(name: String);
    begin
        (*
        infoMsg( 'Symboltable: Beginning new procedure ' + name);
        stBeginContext(name, stProcedure);
        New(stCreateSymbolRet^.fParams);
        stCurrentContext^.fParams := stCreateSymbolRet^.fParams;
        Writeln('test stBeginProcedure: ', stCurrentContext^.fName);
        printSymbolTable(stGlobalScope, '');
        stProcedureParameters := cTrue;
        *)
    end;

    Procedure stEndProcedureParameters;
    begin
        infoMsg( 'Symboltable: End of procedure parameters');
        stProcedureParameters := cFalse;
    end;

    Procedure stProcedureForward;
    begin
        infoMsg( 'Symboltable: Procedure forward declaration');
        stProcedureParameters := cFalse;
        stCurrentContext^.fIsForward := cTrue;
    end;

    // Beginning of a record
    Procedure stBeginRecord(name: String);
    begin
        infoMsg( 'Symboltable: Beginning new record ' + name);
        stBeginContext(name, stRecord);
    end;

    // Ending a record
    Procedure stEndRecord;
    Begin
        infoMsg( 'Symboltable: Ending record');
        stCurrentScope := stCurrentScope^.fParent;
    End;

    Procedure stEndProcedure;
    Begin
        infoMsg( 'Symboltable: Ending procedure');
        if stCurrentScope^.fParent <> Nil then begin
            stCurrentScope := stCurrentScope^.fParent;
        end;
    End;





    Procedure printType(typeObj: ptType; prefix: String);forward;

    Procedure printSymbolList(first: ptSymbol; prefix: String);
    Var curSym: ptSymbol;
    Begin
        // writeln('dPST start');
        if first = Nil then begin
            writeln(prefix + 'Empty list.');
        end else Begin
            curSym := first;
            While curSym <> Nil Do Begin
                Write(prefix, 'Symbol Name: ', curSym^.fName, ', Class: ');
                Write(curSym^.fClass, ', IsParameter: ', curSym^.fIsParameter);
                Write( ', Offset: ', curSym^.fOffset);
                Write( ', Type object: ');
                if curSym^.fType = Nil then Begin
                    (Writeln( 'Nil '));
                End else begin
                    Writeln;
                    printType(curSym^.fType, prefix + '    ');
                end;
                if curSym^.fClass = stProcedure then begin
                    Writeln(prefix, '  Param List:');
                    printSymbolList(curSym^.fParams, prefix + '    ');
                end;
                curSym := curSym^.fNext;
            End;
        End;
    End;

    Procedure printSymbolTable(symbolTable: ptSymbolTable; prefix: String);
    begin
        printSymbolList(symbolTable^.fFirst, prefix);
    end;

    Procedure printType(typeObj: ptType; prefix: String);
    Begin
        Write(prefix + 'TypeObj Form: ' + typeObj^.fForm + ', Base: ');
        if(typeObj^.fBase = Nil) then begin
            Write( 'Nil, ');
        end else begin
            Write('[', typeObj^.fBase^.fForm, ']');
        end;
        If typeObj^.fFields <> Nil then Begin
            Writeln( ' Field objects:');
            printSymbolTable(typeObj^.fFields, prefix + '    ');
        End else begin
            Writeln( ' Fields: Empty.');
        End;
    End;


