PROGRAM booleanTest;

(* Gives the result of true or false depending on two numbers being*)
(* compared using less than. In the given variable 11 and 10 *)
(* are being compared is (11 < 10), of course it should give FALSE *)

VAR
		num1 : integer;
		num2 : integer;
		reelOrreal : boolean;

BEGIN
		num1 := 11;
		num2 := 10;
		reelOrreal := num1 < num2;
		WRITELN('Boolean Test: Is ',num1,' less than ',num2,' ? ',reelOrreal);
                
END.	
