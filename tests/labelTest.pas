PROGRAM labelTest;

(* This is a sample of using labels. Entering the value of i *)
(* will give the result of the given label. For example if the *)
(* user entered a number more than 100 then it will it will give *)
(* an error of the value is too large, so with value of 2 or 3 is *)
(* bad value and if its lower than 0, then it goes to saying value *)
(* must be greater than 0 *)

VAR
	i : integer;

LABEL
		badValue, negValue, bigValue;

BEGIN
		writeln('Enter value for i: ');
		readln(i);
		
		if i < 0 then
			goto negValue
		else if (i = 2) or (i = 3) then
			goto badValue
		else if i > 100 then
			goto bigValue;
		

		negValue:
			writeln('Value of i must be greater than 0.');
			
		badValue:
			writeln('Illegal value of i: 2 or 3. ');
			
		bigValue:
			writeln('Value of i is too large.');
END.



