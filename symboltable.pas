	Var stVar: String; // Longint;
	Var stType: String; // Longint;
	Var stRecord: String; // Longint;

	Type // forward type declatation, has to be in the same Type block!
		ptObject = ^tObject;
		ptType = ^tType;

		// We create a type descriptor record for each type (Longint, String, tType, ...)
		tType = Record
			fForm: String;
			fFields: ptObject;
			fBase: ptType
		End;

		tObject = Record
			fName: String;
			fClass: String; // Longint;
			fType: ptType;
			fNext: ptObject
		End;

	// The first symbol in the symbol table
	Var stSymbolTable: ptObject;
	// boolean marking if declaration is inside a Record declaration.
	Var stInRecord: Longint;
	// If stInRecord is cTrue stRecordPointer shows at the symbol being defined
	var stRecordPointer: ptObject;

	var stTypeLongint: ptType;
	var stTypeString: ptType;

	Procedure stSetType(symbol: ptObject; typeName: String);forward;

	// stInsertSymbol(<name>, <SymbolType>, <isPointer>, <varType>)
	Procedure stInsertSymbol(name: String; symbolType: String; isPointer: Longint; varType: String);
	Var lastSymbol: ptObject;
	Var error: Longint;
	Begin
		error := cFalse;
		if(stInRecord = cTrue) then begin 
			// write ('Insert record symbol ' + name + ': ');

			// stRecordPointer mustn't be Nil
			if(stRecordPointer = Nil) then begin
				error := cTrue;
				(Mark('Error: in a Record declaration and stRecordPointer is Nil! This should not ever happen!'));
			End;
			if stRecordPointer^.fType = Nil then begin
				error := cTrue;
				(Mark('Error: stRecordPointer^.fType mus not be Nil! This should not ever happen!'));
			End else begin
				if stRecordPointer^.fType^.fFields = Nil then Begin
					New(stRecordPointer^.fType^.fFields);
					stRecordPointer^.fType^.fFields^.fName := '';
				End;
				lastSymbol := stRecordPointer^.fType^.fFields;
			End;
		End else begin
			// write ('Insert global symbol ' + name + ': ');

			// If this is the first global Symbol we instantiate it and set the name empty 
			// so we recognize the situation later
			if(stSymbolTable = Nil) then begin
				New(stSymbolTable);
				stSymbolTable^.fName := '';
			End;
			lastSymbol := stSymbolTable;
		End;

		// find the last symbol in the linked list, 
		// making sure the new one doesn't exist yet!
		if error = cFalse then Begin
			// write(lastSymbol^.fName);

			While (lastSymbol^.fNext <> Nil) Do Begin
				If(lastSymbol^.fName = name) then Begin
					(Mark('Symboltable Error: Duplicate Entry: ' + name));
				end Else Begin
					lastSymbol := lastSymbol^.fNext;
					// write(' -> ' + lastSymbol^.fName);
				End;
			End;
			If(lastSymbol^.fName <> '') then begin
				New(lastSymbol^.fNext);
				lastSymbol := lastSymbol^.fNext;
			End;
			// Fill out the Symbol object:
			lastSymbol^.fName := name;
			lastSymbol^.fClass := stVar;
			(stSetType(lastSymbol, varType));
			// writeln(' -> ' + lastSymbol^.fName);
		End;
	End;

	// Set the type on a symbol.
	Procedure stSetType(symbol: ptObject; typeName: String);
	Var symbolIterator: ptObject;
	var found : Longint;
	var isWhile : Longint;
	Begin
		// Is it one of the predefined types (Longint, String, etc) then set fType to the constant pointer
		if typeName = 'LONGINT' then Begin
			symbol^ .fType := stTypeLongint;
		end else begin 
			if typeName = 'STRING' then Begin
				symbol^.fType := stTypeString;
			end Else Begin
				// Find typeName among the Symbols
				symbolIterator := stSymbolTable;
				found := cFalse;

				isWhile := cFalse;
				If symbolIterator^.fNext = Nil then Begin 
					if found = cFalse then begin
						isWhile := cTrue;
					end;
				end;
				While isWhile = cTrue Do Begin
					symbolIterator := symbolIterator^.fNext;
					if symbolIterator^.fName = typeName then Begin
						found := cTrue;
					End;

					isWhile := cFalse;
					If symbolIterator^.fNext = Nil then Begin 
						if found = cFalse then begin
							isWhile := cTrue;
						end;
					end;

				End;
				if found = cTrue then Begin
					if symbolIterator^.fClass = stType then Begin
						symbol^.fType := symbolIterator^.fType;
					end else begin
						// If it's not a Type, error!
						(Mark(typeName + ' is not a TYPE!'));
					end;
				End else begin
					// Type not defined
					(Mark('Error: Type not defined! ' + typeName));
				End;
			End;
		End;
	End;

	// Beginning of a record
	Procedure stBeginRecord(name: String);
	Var lastSymbol: ptObject;
	Begin
		lastSymbol := stSymbolTable;
		While (lastSymbol^.fNext <> Nil) Do Begin
			If(lastSymbol^.fName = name) then Begin
				(Mark('Symboltable Error: Duplicate Entry: ' + name));
			end Else Begin
				lastSymbol := lastSymbol^.fNext;
			End;
		End;
		// Create the actual Symbol for the Record
		New(lastSymbol^.fNext);
		stRecordPointer := lastSymbol^.fNext;
		stRecordPointer^.fName := name;
		New(stRecordPointer^.fType);
		stRecordPointer^ .fType^ .fForm := 'RECORD';
		stRecordPointer^.fClass := stType;
		stInRecord := cTrue;
	End;

	// Ending a record
	Procedure stEndRecord;
	Begin
		stInRecord := cFalse;
	End;

	Procedure printType(typeObj: tType; prefix: String);forward;

	Procedure printSymbolTable(symbolTable: ptObject; prefix: String);
	Var curSym: ptObject;
	Begin
		if symbolTable = Nil then begin
			writeln(prefix + 'Empty Symbol table.');
		end else Begin
			curSym := symbolTable;
			While(curSym <> Nil) Do Begin
				Write(prefix + 'Symbol Name: ' + curSym^.fName + ', Class: ');
				Write(curSym^.fClass);
				Write(', Type object: ');
				if curSym^.fType = Nil then Begin
					Writeln('Nil');
				End else begin
					Writeln();
					printType(curSym^.fType^, prefix + '    ');
				end;
				curSym := curSym^.fNext;
			End;
		End;
	End;

	Procedure printType(typeObj: tType; prefix: String);
	Begin
		Write(prefix + 'TypeObj Form: ' + typeObj.fForm + ', ');
		If typeObj.fForm = 'RECORD' then Begin
			Writeln('Field objects:');
			printSymbolTable(typeObj.fFields, prefix + '    ');
		End else begin
			Writeln('Fields: Empty.');
		End;
	End;


	// Initialize the SymbolTable module
	procedure stInit;
	Begin
		(* Init constants *)
		stVar := 'VAR'; // 1;
		stType := 'TYPE'; // 2;
		stRecord := 'RECORD'; // 3;

		// Init stTypeLongint
		New(stTypeLongint);
		stTypeLongint^.fForm := 'LONGINT';

		// Init stTypeString
		New(stTypeString);
		stTypeString^.fForm := 'STRING';

		stInRecord := cFalse;
	End;

