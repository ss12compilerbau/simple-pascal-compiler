PROGRAM SPC;

{$include 'scanner.pas';}
{$include 'symboltable.pas';}
{$include 'parser.pas';}


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
	stBeginRecord('tKWs');
	//	sym: Longint;
		stInsertSymbol('SYM', stVar, cFalse, 'LONGINT');
	//	id: tStrId;
		stInsertSymbol('ID', stVar, cFalse, 'STRING');
	// END;
	stEndRecord();

	// Var xy: tKWs;
	stInsertSymbol('XY', stVar, cFalse, 'tKWs');

	// Var asdf: NichtdefinierterTyp;
	stInsertSymbol('ASDF', stVar, cFalse, 'NichtdefinierterTyp');

	// Type qwer: ^Longint;
	stInsertSymbol('ptLongint', stType, cTrue, 'LONGINT');


	// Procedure isEquStrId( id1: String);
	stBeginProcedure('isEquStrId');
	stInsertSymbol('id1', stVar, cFalse, 'String');

	//	VAR i: Longint;
		stInsertSymbol('i', stVar, cFalse, 'Longint');

	// BEGIN END;
	stEndProcedure();

	Writeln;
	printSymbolTable(stSymbolTable, '');

END.

