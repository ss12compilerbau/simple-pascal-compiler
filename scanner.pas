PROGRAM OSS; (* NW 19.9.93 / 17.11.94*)
	(*IMPORT Oberon, Texts;*)
  
	CONST cIdLen = 16;
	CONST cKW = 34;
    (*symbols*)
	CONST cNull = 0;
    CONST cTimes = 1;
    CONST cDiv = 3;
    CONST cMod = 4;
    CONST cAnd = 5;
    CONST cPlus = 6;
    CONST cMinus = 7;
    CONST cOr = 8;
    CONST cEql = 9;
    CONST cNeq = 10;
    CONST cLss = 11;
    CONST cGeq = 12;
    CONST cLeq = 13;
    CONST cGtr = 14;
    CONST cPeriod = 18;
    CONST cComma = 19;
    CONST cColon = 20;
    CONST cRparen = 22;
    CONST cRbrak = 23; 
    CONST cOf = 25;
    CONST cThen = 26;
    CONST cDo = 27; 
    CONST cLparen = 29;
    CONST cLbrak = 30;
    CONST cNot = 32;
    CONST cBecomes = 33;
    CONST cNumber = 34;
    CONST cIdent = 37; 
    CONST cDemicolon = 38;
    CONST cEnd = 40;
    CONST cElse = 41;
    CONST cElsif = 42;
    CONST cIf = 44;
    CONST cWhile = 46;
    CONST cArray = 54;
    CONST cRecord = 55;
    CONST cConst = 57;
    CONST cType = 58;
    CONST cVar = 59;
    CONST cProcedure = 60;
    CONST cBegin = 61;
    CONST cModule = 63;
    CONST cEof = 64;

	TYPE tIdent = ARRAY [1..cIdLen] OF CHAR;

	VAR val: LONGINT;
	VAR id: tIdent;
	VAR error: BOOLEAN;

	VAR ch: CHAR;
	VAR nkw: INTEGER;
	VAR errpos: LONGINT;
	VAR R: Text;
	VAR W: Text;
	VAR keyTab: ARRAY [1..cKW] OF
	RECORD 
		sym: INTEGER;
		id: ARRAY [1..12] OF CHAR;
	END;
	
	VAR sym: INTEGER; (* eingefügt da in Proz ident verwendet?? *)

	(*
	PROCEDURE Mark(msg: ARRAY OF CHAR);
	VAR p: LONGINT;
	BEGIN p := Texts.Pos(R) - 1;
		IF p > errpos THEN
			Texts.WriteString(W, "  pos "); Texts.WriteInt(W, p, 1);
			Texts.Write(W, " "); Texts.WriteString(W, msg);
			Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
		END ;
		errpos := p; error := TRUE
	END Mark;
	*)

  
	PROCEDURE Get(VAR sym: INTEGER);
  
		PROCEDURE Ident;
		VAR i, k: INTEGER;
		BEGIN i := 0;
			REPEAT
				IF i < cIdLen THEN BEGIN id[i] := ch; INC(i); END;
			Read(R, ch);
			(*
			UNTIL (ch < '0') OR (ch > '9') AND (CAP(ch) < 'A') OR (CAP(ch) > 'Z');
			id[i] := 0X; k := 0;
			*)
			UNTIL (ch < '0') OR (ch > '9') AND (ch < 'A') OR (ch > 'Z');
			id[i] := CHR(0); k := 0;
			(*
			WHILE (k < nkw) & (id # keyTab[k].id) DO INC(k) END ;
			*)
			WHILE (k < nkw) AND (id = keyTab[k].id) DO
				BEGIN
					INC(k) 
				END ;
			IF k < nkw THEN
				sym := keyTab[k].sym
			ELSE
				sym := sym; (* sym := ident; *) (* ausgeblendet, da ident nirgends def? *)
		END;

		PROCEDURE Number;
			BEGIN
				val := 0;
				(* sym := number; *) (* ausgeblendet, da number niergends definiert *)
				sym := sym;
				REPEAT
					(*
					MAX(LONGINT) nicht gefunden 
					IF val <= (MAX(LONGINT) - ORD(ch) + ORD("0")) DIV 10 THEN
					*) 
					IF val <= (2000000000 - ORD(ch) + ORD('0')) DIV 10 THEN
						val := 10 * val + (ORD(ch) - ORD('0'))
					ELSE
						begin 
							(* Mark('number too large'); *)
							val := 0
						END ;
					Read(R, ch);
				UNTIL (ch < '0') OR (ch > '9')
			END;
    
		PROCEDURE comment;
		BEGIN 
			Read(R, ch);
			WHILE 1=1;
				WHILE 1=1;
					(* LOOP *) (* hab Befehl nicht verstanden *)
					(* LOOP *) (* hab Befehl nicht verstanden *)
					WHILE ch = "(" DO Texts.Read(R, ch);
					IF ch = '*' THEN comment END
				END ;
				IF ch = '*' THEN Read(R, ch); EXIT END ;
				IF R.eot THEN EXIT END ;
				Read(R, ch)
			END ;
			IF ch = ') THEN Texts.Read(R, ch); EXIT END ;
			IF R.eot THEN (*Mark("comment not terminated")*); EXIT END
		END
	END;

  BEGIN
    WHILE ~R.eot & (ch <= " ") DO Texts.Read(R, ch) END;
    IF R.eot THEN sym := eof
    ELSE 
      CASE ch OF
         "&": Texts.Read(R, ch); sym := and
      |  "*": Texts.Read(R, ch); sym := times
      |  "+": Texts.Read(R, ch); sym := plus
      |  "-": Texts.Read(R, ch); sym := minus
      |  "=": Texts.Read(R, ch); sym := eql
      |  "#": Texts.Read(R, ch); sym := neq
      |  "<": Texts.Read(R, ch);
          IF ch = "=" THEN Texts.Read(R, ch); sym := leq ELSE sym := lss END
      |  ">": Texts.Read(R, ch);
          IF ch = "=" THEN Texts.Read(R, ch); sym := geq ELSE sym := gtr END
      |  ";": Texts.Read(R, ch); sym := semicolon
      |  ",": Texts.Read(R, ch); sym := comma
      |  ":": Texts.Read(R, ch);
          IF ch = "=" THEN Texts.Read(R, ch); sym := becomes ELSE sym := colon END
      |  ".": Texts.Read(R, ch); sym := period
      |  "(": Texts.Read(R, ch);
          IF ch = "*" THEN comment; Get(sym) ELSE sym := lparen END
      |  ")": Texts.Read(R, ch); sym := rparen
      |  "[": Texts.Read(R, ch); sym := lbrak
      |  "]": Texts.Read(R, ch); sym := rbrak
      |  "0".."9": Number;
      |  "A" .. "Z", "a".."z": Ident
      |  "~": Texts.Read(R, ch); sym := not
      ELSE Texts.Read(R, ch); sym := null
      END
    END
  END Get;

  PROCEDURE Init*(T: Texts.Text; pos: LONGINT);
  BEGIN error := FALSE; errpos := pos; Texts.OpenReader(R, T, pos); Texts.Read(R, ch)
  END Init;
  
  PROCEDURE EnterKW(sym: INTEGER; name: ARRAY OF CHAR);
  BEGIN keyTab[nkw].sym := sym; COPY(name, keyTab[nkw].id); INC(nkw)
  END EnterKW;

BEGIN Texts.OpenWriter(W); error := TRUE; nkw := 0;
  EnterKW(null, "BY");
  EnterKW(do, "DO");
  EnterKW(if, "IF");
  EnterKW(null, "IN");
  EnterKW(null, "IS");
  EnterKW(of, "OF");
  EnterKW(or, "OR");
  EnterKW(null, "TO");
  EnterKW(end, "END");
  EnterKW(null, "FOR");
  EnterKW(mod, "MOD");
  EnterKW(null, "NIL");
  EnterKW(var, "VAR");
  EnterKW(null, "CASE");
  EnterKW(else, "ELSE");
  EnterKW(null, "EXIT");
  EnterKW(then, "THEN");
  EnterKW(type, "TYPE");
  EnterKW(null, "WITH");
  EnterKW(array, "ARRAY");
  EnterKW(begin, "BEGIN");
  EnterKW(const, "CONST");
  EnterKW(elsif, "ELSIF");
  EnterKW(null, "IMPORT");
  EnterKW(null, "UNTIL");
  EnterKW(while, "WHILE");
  EnterKW(record, "RECORD");
  EnterKW(null, "REPEAT");
  EnterKW(null, "RETURN");
  EnterKW(null, "POINTER");
  EnterKW(procedure, "PROCEDURE");
  EnterKW(div, "DIV");
  EnterKW(null, "LOOP");
  EnterKW(module, "MODULE");
END OSS.

