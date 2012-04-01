Program functionTest;

(* This test a function minus which is a subtraction *)
(* of two variables. In this program, given (7-5) it *)
(* prints the result of 2*)

VAR 
	a : integer;
	b : integer;
	c : integer;

	function minus(i, j : integer) : integer;
	var n : integer;
		begin
			n := i - j;
			minus := n;
		end;
BEGIN
	a := 7;
	b := 5;
	c := minus(a,b);
	writeln(c);
	if c = 2 then writeln ('Test Passed!')
	else writeln('Test Failed!');
END.
		
		
			

