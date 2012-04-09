PROGRAM SPC;

{$include 'scanner.pas';}
{$include 'parser.pas';}
{$include 'symboltable.pas';}


	BEGIN
	    scannerInit();
	    parserInit();
	    STInit();

  END.

