PROGRAM pointerArray;

(* This test for array pointer should *)
(* save the value of p and pp to be equal *)
(* if it runs correctly it exits the program *)
(* if not, it gives an error notification*)

VAR 
	i : longint;
	p : ^longint;
	pp : array[0..100] of longint;

BEGIN
    FOR i := 0 to 100 do
	pp[i] := i;
	p := @pp[0];
	FOR i := 0 to 100 do
	   IF p[i] <> pp[i] THEN
		WRITELN ('Ohoh, problem!');
END.
