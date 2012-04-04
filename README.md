# Simple Pascal Compiler

This is a compiler based on Pascal Programming Language.  To start with the project, we have written a scanner which scan files and itself. The scanner checks every symbol or character in a file till it reaches the end of the file.

Instructions to build and test:

On commandline/console:

	make	    ---- to build the project.
	make test   ---- to run tests.
	make clean  ---- to remove/delete unncessary files after building.

## EBNF
### Programs and Blocks

            pgm = pgmHeading pgmDeclarations codeBlock "." .
            pgmHeading = program pgmIdentifier ";" .
            pgmDeclarations = { pgmDeclaration }
            pgmDeclaration = varDeclaration | procDeclaration | funcDeclaration .
            procDeclaration = procHeading varDeclarations codeBlock ";" .
            procHeading = procedure procIdentifier defParameters ";" .
            funcDeclaration = funcHeading varDeclarations codeBlock ";" .
            funcHeading = function funcIdentifier defParameters ":" type ";" .
            varDeclarations = { varDeclaration }
            varDeclaration = var declaration ";" .

### Statements, Procedures and Functions

            codeBlock = begin statements  end .
            statements = { statement }
            statement = simpleStatement | ifStatement | whileStatement | proCall .
            simpleStatement = variable ":=" ( expression | funcCall ) ";" .
            ifStatement = if expression  then codeBlock [  else codeBlock ] ";" .
            whileStatement = while expression  do codeBlock ";" .
            funcCall = funcIdentifier callParameters ";" .
            procCall = procIdentifier callParameters ";" .
            defParameters = [ "(" paraDecl { ";" paraDecl } ")" ]
            paraDecl = varIdentifier ":" type
            callParameters = [ "(" expression { ";" expression } ")" ]

### Expressions Procedures and Functions

            expression = simpleExpression [ relOperator simpleExpression ] .
            simpleExpression = [ sign ] term { addOperator term } .
            term = factor { multOperator factor } .
            factor = variable | longint | string | funcIdentifier | "(" expression ")" |  not factor .

### Types

            type = simpleType | recordType | pointerType .
            simpleType = longint | string .
            recordType = record paraDecl { ";" paraDecl }  end .
            pointerType = "^" typeIdentifier
            EBNF GenComVariables
            variable = varIdentifier { varModifier } .
            varModifier = [ "^" ] ( arrAccess | recAccess )
            arrAccess = "[" expression "]"
            recAccess = "." varIdentifier

### Identifiers

            pgmIndentifier = identifier
            constIndentifier = identifier
            varIndentifier = identifier
            typeIndentifier = identifier
            procIndentifier = identifier
            funcIndentifier = identifier
            identifier = letter { letter | digit } .

### Low Level Definitions

            sign = "+" | "-" .
            longint = [ sign ] unsignedLongnt .
            unsignedLongint = digit { digit } .
            string = "'" stringCharacter { stringCharacter } "'" .
            stringCharacter = any-character-except-quote | "''" . 
            relOperator = "=" | "<>" | "<" | "<=" | ">" | ">=" .
            addOperator = "+" | "-" | or . 
            multOperator = "*" | "/" | and .
            letter = "A" | ... | "Z" | "a" | ... | "z" . 
            digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" . 

### Kommentare

            Kommentare sind zwischen "(*" und "*)" eingeschlossen

