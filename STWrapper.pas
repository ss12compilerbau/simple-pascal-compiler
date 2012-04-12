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

