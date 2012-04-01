PROGRAM loopTest;

(* This is a test for repeat-until loop statement*)
(*  This should increment and print the variable y *)
(*  till it reaches the same value as in x. The result is: *)
(* 52 *)
(* 53 *)
(* 54 *)
(* 55 *)

VAR 
	x : integer;
	y : integer;
		
BEGIN

	x := 5;
	y := 1;
	
	repeat  
		   y := y+1 ;
		   write(x);
		   writeln(y)
	until  x = y;
	
END.
