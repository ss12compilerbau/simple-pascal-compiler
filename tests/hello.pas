PROGRAM hello;

Var i: Longint;

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


BEGIN
	(Writeln('Hello World!'));
END.

