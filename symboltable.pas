	Var stVar: String;
	Var stType: String;
	Var stRecord: String;
	Var stProcedure: String;

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
			fClass: String;
			fType: ptType;
			fPrev: ptObject;
			fNext: ptObject
		End;

	Procedure printSymbolTable(symbolTable: ptObject; prefix: String);forward;

	// The first symbol in the symbol table
	Var stSymbolTable: ptObject;
	// boolean marking if declaration is inside a Record declaration.
	Var stInContext: Longint;
	// If stInContext is cTrue stContextEntryPointer shows at the symbol being defined
	var stContextEntryPointer: ptObject;

	var stTypeLongint: ptType;
	var stTypeString: ptType;
	var stTypeInteger: ptType;
	var stTypeText: ptType;
	var stTypeChar: ptType;

	Procedure stSetType(symbol: ptObject; typeName: String; isPointer: Longint);forward;

	// stInsertSymbol(<name>, <SymbolType>, <isPointer>, <varType>)
	Procedure stInsertSymbol(name: String; symbolType: String; isPointer: Longint; varType: String);
	Var lastSymbol: ptObject;
	Var error: Longint;
	var UCFName : String;
	var UCName : String;
	Begin
		(infoMsg( 'Symboltable: Adding new symbol ' + name));
		error := cFalse;
		// If we're in a Context of Record or Procedure
		if(stInContext = cTrue) then begin 
			// write ('Insert record symbol ' + name + ': ');

			// stContextEntryPointer mustn't be Nil
			if(stContextEntryPointer = Nil) then begin
				error := cTrue;
				(errorMsg( 'Symboltable: in a Record declaration and stContextEntryPointer is Nil! This should not ever happen!'));
			End;
			if stContextEntryPointer^.fType = Nil then begin
				error := cTrue;
				(errorMsg( 'Symboltable: stContextEntryPointer^.fType must not be Nil! This should not ever happen!'));
			End else begin
				if stContextEntryPointer^.fType^.fFields = Nil then Begin
					New(stContextEntryPointer^.fType^.fFields);
					stContextEntryPointer^.fType^.fFields^.fName := '';
				End;
				lastSymbol := stContextEntryPointer^.fType^.fFields;
			End;
		// Global symbol
		End else begin
			// write ('Insert global symbol ' + name + ': ');

			// If this is the first global Symbol we instantiate it and set the name empty 
			// so we recognize the situation later
			lastSymbol := stSymbolTable;
		End;

		// find the last symbol in the linked list, 
		// making sure the new one doesn't exist yet!
		if error = cFalse then Begin
			UCFName := upCase(lastSymbol^.fName);
			UCName := upCase(Name);
			If UCFName = UCName then Begin
				(errorMsg( 'Symboltable: Duplicate Entry: ' + name));
				error := cTrue;
			end;
			While lastSymbol^.fNext <> Nil Do Begin
				lastSymbol := lastSymbol^.fNext;
				UCFName := upCase(lastSymbol^.fName);
				UCName := upCase(name);
				If UCFName = UCName then Begin
					(errorMsg( 'Symboltable: Duplicate Entry: ' + name));
					error := cTrue;
				end;
			End;
			if error = cFalse then begin
				If lastSymbol^.fName <> '' then begin
					New(lastSymbol^.fNext);
					lastSymbol^.fNext^.fPrev := lastSymbol;
					lastSymbol := lastSymbol^.fNext;
				End;
				// Fill out the Symbol object:
				lastSymbol^.fName := name;
				lastSymbol^.fClass := stVar;
				(stSetType(lastSymbol, varType, isPointer));
			end;
		End;
	End;

	Procedure stBeginContext(name: String; form: String);
	Var lastSymbol: ptObject;
	var error: Longint;
	var UCFName : String;
	var UCName : String;
	Begin
		lastSymbol := stSymbolTable;

		UCFName := upCase(lastSymbol^.fName);
		UCName := upCase(Name);
		If UCFName = UCName then Begin
		  if form <> stProcedure then begin
			  (errorMsg( 'Symboltable: Duplicate Entry: ' + name));
			  error := cTrue;
			end;
		end;
		While lastSymbol^.fNext <> Nil Do Begin
			lastSymbol := lastSymbol^.fNext;
			UCFName := upCase(lastSymbol^.fName);
			UCName := upCase(name);
			If UCFName = UCName then Begin
		    if form <> stProcedure then begin
			    (errorMsg( 'Symboltable: Duplicate Entry: ' + name));
			    error := cTrue;
			  end;
			end;
		End;
		if error = cFalse then begin
			If lastSymbol^.fName <> '' then begin
				// Create the actual Symbol for the Record
				New(lastSymbol^.fNext);
				lastSymbol^.fNext^.fPrev := lastSymbol;
				stContextEntryPointer := lastSymbol^.fNext;
				stContextEntryPointer^.fName := name;
				New(stContextEntryPointer^.fType);

				if form = stRecord then begin
					stContextEntryPointer^.fClass := stType;
					stContextEntryPointer^ .fType^ .fForm := stRecord;
				end else begin
					stContextEntryPointer^.fClass := stProcedure;
					stContextEntryPointer^ .fType^ .fForm := stProcedure;
				end;
				stInContext := cTrue;
			end;
		end;
	End;

	// Set the type on a symbol.
	Procedure stSetType(symbol: ptObject; typeName: String; isPointer: Longint);
	Var symbolIterator: ptObject;
	var found : Longint;
	var isWhile : Longint;
	var UCTypeName : string;
	var UCFName : String;
	Begin
		(infoMsg( 'Symboltable: Set type to ' + typeName));

		// Is it one of the predefined types (Longint, String, etc) then set fType to the constant pointer
		UCTypeName := upCase(typeName);
		if UCTypeName = 'LONGINT' then Begin
			symbol^ .fType := stTypeLongint;
		end else begin 
			UCTypeName := upCase(typeName);
			if UCTypeName = 'STRING' then Begin
				symbol^.fType := stTypeString;
		  end else begin 
			  UCTypeName := upCase(typeName);
			  if UCTypeName = 'INTEGER' then Begin
				  symbol^.fType := stTypeInteger;
		    end else begin 
			    UCTypeName := upCase(typeName);
			    if UCTypeName = 'TEXT' then Begin
				    symbol^.fType := stTypeText;
		      end else begin 
			      UCTypeName := upCase(typeName);
			      if UCTypeName = 'CHAR' then Begin
				      symbol^.fType := stTypeChar;
			      end Else Begin
				      // Find typeName among the Symbols
				      symbolIterator := stSymbolTable;
				      found := cFalse;

				      isWhile := cFalse;
				      If symbolIterator^.fNext <> Nil then Begin
					      if found = cFalse then begin
						      isWhile := cTrue;
					      end;
				      end;
				      While isWhile = cTrue Do Begin
					      symbolIterator := symbolIterator^.fNext;
					      UCTypeName := upCase(typeName);
					      UCFName := upCase(symbolIterator^.fName);
					      if UCFName = UCTypeName then Begin
						      found := cTrue;
					      End;

					      isWhile := cFalse;
					      If symbolIterator^.fNext <> Nil then Begin
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
						      (infoMsg(typeName + ' is not a TYPE!'));
					      end;
				      End else begin
					      // Type not defined, symbol has to be removed.
					      (errorMsg( 'Symboltable: Type not defined! ' + typeName));
					      symbol^.fPrev^.fNext := Nil;
					      // How to do this? Free(symbol);
				      End;
			      End;
		      End;
		    End;
		  End;
		End;
	End;

	Procedure stBeginProcedure(name: String);
	begin
		(infoMsg( 'Symboltable: Beginning new procedure ' + name));
		(stBeginContext(name, stProcedure));
	end;

	// Beginning of a record
	Procedure stBeginRecord(name: String);
	begin
		(infoMsg( 'Symboltable: Beginning new record ' + name));
		(stBeginContext(name, stRecord));
	end;

	// Ending a record
	Procedure stEndRecord;
	Begin
		stInContext := cFalse;
		(infoMsg( 'Symboltable: Ending record'));
	End;

	Procedure stEndProcedure;
	Begin
		stInContext := cFalse;
		(infoMsg( 'Symboltable: Ending procedure'));
	End;

	Procedure printType(typeObj: tType; prefix: String);forward;

	Procedure printSymbolTable(symbolTable: ptObject; prefix: String);
	Var curSym: ptObject;
	Begin
		if symbolTable = Nil then begin
			(writeln(prefix + 'Empty Symbol table.'));
		end else Begin
			curSym := symbolTable;
			While curSym <> Nil Do Begin
				(Write(prefix + 'Symbol Name: ' + curSym^.fName + ', Class: '));
				(Write(curSym^.fClass));
				(Write( ', Type object: '));
				if curSym^.fType = Nil then Begin
					(Writeln( 'Nil '));
				End else begin
					(Writeln);
					(printType(curSym^.fType^, prefix + '    '));
				end;
				curSym := curSym^.fNext;
			End;
		End;
	End;

	Procedure printType(typeObj: tType; prefix: String);
	Begin
		(Write(prefix + 'TypeObj Form: ' + typeObj.fForm + ', Base: '));
		if(typeObj.fBase = Nil) then begin
			(Write( 'Nil, '));
		end else begin
			(Write(typeObj.fBase^.fForm));
		end;
		If typeObj.fFields <> Nil then Begin
			(Writeln( 'Field objects:'));
			(printSymbolTable(typeObj.fFields, prefix + '    '));
		End else begin
			(Writeln( 'Fields: Empty.'));
		End;
	End;

	// Initialize the SymbolTable module
	procedure stInit;
	Begin
		(* Init constants *)
		stVar := 'VAR';
		stType := 'TYPE';
		stRecord := 'RECORD';
		stProcedure := 'PROCEDURE';

		// Init predefined types
		New(stTypeLongint);
		stTypeLongint^.fForm := 'LONGINT';

		New(stTypeInteger);
		stTypeInteger^.fForm := 'INTEGER';

		New(stTypeText);
		stTypeText^.fForm := 'TEXT';

		New(stTypeChar);
		stTypeChar^.fForm := 'CHAR';

		New(stTypeString);
		stTypeString^.fForm := 'STRING';

		New(stSymbolTable);
		stSymbolTable^.fName := '';

		stInContext := cFalse;
	End;

