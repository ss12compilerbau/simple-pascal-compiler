# Simple Pascal Compiler

This is a compiler based on Pascal Programming Language.  To start with the project, we have written a scanner which scan files and itself. The scanner checks every symbol or character in a file till it reaches the end of the file.

Instructions to build and test:

On commandline/console:

	make	    ---- to build the project.
	make test   ---- to run tests.
	make clean  ---- to remove/delete unncessary files after building.

## EBNF
### Programs and Blocks

      pgm                   = pgmHeading [ pgmDeclarations ] pgmStatements "." .
      pgmHeading            = program pgmIdentifier "(" ")" ";" .
      pgmDeclarations       = pgmDeclaration {pgmDeclaration} .
      pgmDeclaration        = [ constDeclaration |  varDeclaration | procDeclaration ] .
      constDeclaration      = const constIdentifier "=" constant ";" .
      varDeclaration        = var varIdentifier ":" type ";" .
      procDeclaration       = procHeading pgmStatements ";" .
      procHeading           = procedure procIdentifier ";" .

### Statements

      pgmStatements         = begin [ statements ] end .
      statements            = statement { statement } .
      statement             = simpleStatement | structuredStatement | mallocStatement.
      simpleStatement       = [ ( variable ":=" expression | procIdentifier ) ";" ] .
      structuredStatement   = begin statements end | while expression do statements | ifStatement .
      ifStatement           = if expression then statement [ else statement ] ";".
      mallocStatement       = variable ":=" malloc "(" positiveInteger [ "," variable ] ")" ";" .

### Expressions

      expression            = simpleExpression [ relOperator simpleExpression ] .
      simpleExpression      = [ sign ] term { addOperator term } .
      term                  = factor { multOperator factor } .
      factor                = variable | integer | string | constIdentifier | procIdentifier | "(" expression ")" | not factor .

### Types

      type                  = simpleType | recordType | pointerType .
      simpleType            = longint | string .
      varInTypeDeclaration  = varIdentifier "=" type ";" .
      recordType            = record varInTypeDeclaration { varInTypeDeclaration } end .
      pointerType           = "^" typeIdentifier

### EBNF GenComVariables and Identifier Categories

      pgmIndentifier        = identifier
      constIndentifier      = identifier
      varIndentifier        = identifier
      typeIndentifier       = identifier
      procIndentifier       = identifier
      identifier            = letter { letter | digit } .
      constant              = [ sign ] ( integer |  string ) .
      variable              = varIdentifier | indexedVariable | recordVariable | refVariable
      varIdentifier         = Identifier
      indexedVariable       = variable "[" positiveInteger "]"
      recordVariable        = variable "." identifier
      refVariable           = variable "^"

### Low Level Definitions

      sign                  = "+" | "-" .
      integer               = [ sign ] unsignedInteger .
      unsignedInteger       = digit { digit } .
      positiveInteger       = unsignedInteger greater 0
      string                = "'" stringCharacter { stringCharacter } "'" .
      stringCharacter       = any-character-except-quote | "''" . 
      relOperator           = "=" | "<>" | "<" | "<=" | ">" | ">=" .
      addOperator           = "+" | "-" | or . 
      multOperator          = "*" | "/" | and .
      letter                = "A" | ... | "Z" | "a" | ... | "z" . 
      digit                 = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" .

