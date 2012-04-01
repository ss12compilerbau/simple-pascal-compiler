PROGRAM hello;

	procedure aComment;
	begin
		writeln('This is a sample comment');
		(*This should not be written*)
		(*This should*)(*also not be written*)
		write('only this ');
		
		(* Comments are cut and
		continued in the next line *)
		writeln('should be written');
		writeln('(*is this a comment?*)');
	end;


	procedure aString;
	begin
		writeln('Hi, there!');
		writeln('It''s Friday!');
	end;

	procedure aSymbol;
	var i, j : integer;
		sum, times : integer; 
		isLessThan : boolean;

	begin
		i := 2;
	    j := 3;
		isLessThan := true;
		sum := i + j;
		times := i * j;
		if i < j then
			writeln (isLessThan);
	end;

	procedure aNumber;
	var i,j,k : integer;
		a,b,c : real;	
	begin
		i := 0;
		j := 1;
		k := 00000000000000032;
		a := 3.141592;
		b := 0.0E3;
		c := 123.E5;
		writeln(i);
		writeln(j);
		writeln(k);
		writeln(a);
		writeln(b);
		writeln(c);
	end;
BEGIN
	aComment;
	aString;
	aSymbol;
	aNumber;	
END.

		

	
	
