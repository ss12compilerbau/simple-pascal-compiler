PROGRAM SPC;

{$include 'scanner.pas';}
{$include 'symboltable.pas';}
{$include 'parser.pas';}


BEGIN
    scannerInit();
//    parserInit();
    STInit();

	// Examples:
	Writeln('var i: Longint;');
	stInsertSymbol('I', stVar, cFalse, 'Longint');

	Writeln('var i: Longint;');
	stInsertSymbol('I', stVar, cFalse, 'Longint');

	Writeln('var j: ^longint;');
	stInsertSymbol('J', stVar, cTrue, 'longint');

	Writeln('var j: ^longint;');
	stInsertSymbol('J', stVar, cTrue, 'longint');

	Writeln('var j: ^longint;');
	stInsertSymbol('J', stVar, cTrue, 'longint');
(*
	Writeln('Type tKWs = record');
	stBeginRecord('tKWs');
	Writeln('	sym: Longint;');
		stInsertSymbol('SYM', stVar, cFalse, 'Longint');
	Writeln('	id: String;');
		stInsertSymbol('ID', stVar, cFalse, 'String');
	Writeln('END;');
	stEndRecord();
	Writeln;

	Writeln('Procedure isEquStrId( id1: String);forward;');
	stBeginProcedure('isEquStrId');
	stInsertSymbol('id1', stVar, cFalse, 'String');
	stEndProcedure();

	Writeln('Var xy: tKWs;');
	stInsertSymbol('XY', stVar, cFalse, 'tKWs');

	Writeln('Var asdf: NichtdefinierterTyp;');
	stInsertSymbol('ASDF', stVar, cFalse, 'NichtdefinierterTyp');

	Writeln('Type qwer: ^Longint;');
	stInsertSymbol('ptLongint', stType, cTrue, 'Longint');

	Writeln('Procedure isEquStrId( id1: String);');
	stBeginProcedure('isEquStrId');
	stInsertSymbol('id1', stVar, cFalse, 'String');

	Writeln('    VAR i: Longint;');
		stInsertSymbol('i', stVar, cFalse, 'Longint');

	Writeln('.. END;');
	stEndProcedure();

*)
	Writeln;
	printSymbolTable(stSymbolTable, '');
END.

