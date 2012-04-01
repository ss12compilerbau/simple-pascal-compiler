PROGRAM arrayTest;

(*Testing array contents*)
(*First output from writeln m[10] gives the result of 10*)
(*Second output will give the array content of m[i] which*)
(*results to 12345678910*)

VAR
	i : integer;
	m : array[1..10] of integer;
	
BEGIN
	i := 20;
	m[10] := 10;
	writeln('Content of m[10] is : ', m[10]);
	i := 1;
	while i < 11 do begin
		m[i] := i;
		i := i + 1;
	end;
	i := 1;
	
	while i < 11 do begin
		write(m[i]);
		i := i + 1;
	end;
	writeln();
End.
		
