PROGRAM SPC;

{$include 'scanner.pas';}
{$include 'parser.pas';}
{$include 'symboltable.pas';}

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

BEGIN
    scannerInit();
//    parserInit();
    STInit();

	// Examples:

	// var i: Longint;
	stInsertSymbol('I', stVar, cFalse, 'LONGINT');

	// var j: ^longint;
	stInsertSymbol('J', stVar, cTrue, 'LONGINT');

	// Type tKWs = record 
	stBeginRecord('TKWS');
	//	sym: Longint;
		stInsertSymbol('SYM', stVar, cFalse, 'LONGINT');
	//	id: tStrId;
		stInsertSymbol('ID', stVar, cFalse, 'STRING');
	// END;
	stEndRecord();

	// Var xy: tKWs;
	stInsertSymbol('XY', stVar, cFalse, 'TKWS');

	// Var asdf: Notdefined;
	stInsertSymbol('ASDF', stVar, cFalse, 'NOTDEFINED');

	Writeln;
	printSymbolTable(stSymbolTable, '');

END.

