# Simple Pascal Compiler

This is a compiler based on Pascal Programming Language but handles only a subset of the pascal language. It is planned to be self-compiling soon. The compiler produces assembly code that can be run on our Virtual machine (emu/emulator.js).

## Dependencies:
* Free Pascal Compiler (fpc)
* Node JS 0.6.* for running the virtual machine

Instructions to build and test:

On commandline/console:

	make	    ---- to build the project.
	make test   ---- to run tests.
	make clean  ---- to remove/delete unncessary files after building.
	make runLastAsmTest ---- to run the virtual machine with the last compiled out.asm file
	
	./SPC someFile.pas  ---- to compile a pascal file.

## The EBNF

Until it isn't final, the final version is only reachable [here](http://www.cs.uni-salzburg.at/~ck/wiki/index.php?n=CC-Summer-2012.SPCEBNF)

As of May 24th 2012:

### Programs and Blocks

**pgm** = pgmHeading pgmDeclarations codeBlock “.” .   
**pgmHeading** = *program* pgmIdentifier “;” .   
**pgmDeclarations** = { pgmDeclaration } .   
**pgmDeclaration** = varDeclaration | typeDeclaration | procDeclaration
.   
**procDeclaration** = procHeading ( *forward* | ( varDeclarations
codeBlock ) ) “;” .   
**procHeading** = *procedure* procIdentifier defParameters “;” .   
**varDeclarations** = { varDeclaration } .   
**varDeclaration** = *var* declaration “;” .   
**typeDeclaration** = *type* oneTypeDeclaration { oneTypeDeclaration } .
  
**oneTypeDeclaration** = typeIdentifier “=” ( recordType | arrayType | (
“\^” typeIdentifier ) ) “;” .   

### Statements, Procedures and Functions

**codeBlock** = *begin* statements *end* .   
**statements** = { statement }   
**statement** = simpleStatement | ifStatement | whileStatement |
procCall .   
**simpleStatement** = variable “:=” ( expression | procCall ) “;” .   
**ifStatement** = *if* expression *then* codeBlock [ *else* codeBlock ]
“;” .   
**whileStatement** = *while* expression *do* codeBlock “;” .   
**procCall** = procIdentifier callParameters “;” .   
**defParameters** = [ “(” declaration { “;” declaration } “)” ]   
**declaration** = varIdentifier “:” type .   
**callParameters** = [ “(” expression { “;” expression } “)” ]   

### Expressions Procedures and Functions

**expression** = simpleExpression [ relOperator simpleExpression ] .   
**simpleExpression** = term { addOperator term } .   
**term** = factor { multOperator factor } .   
**factor** = variable | ( [ sign ] longint ) | string | “(” expression
“)” | *not* factor .   

### Types

**type** = simpleType | typeIdentifier .   
**simpleType** = longint | string | char | boolean | text .   
**recordType** = *record* declaration { “;” declaration } *end* .   
**arrayType** = *array* *of* typeIdentifier .   

### Variables

**variable** = varExtIdentifier { varModifier } .   
**varModifier** = [ “\^” ] “.” varExtIdentifier .   
**varExtIdentifier** = varIdentifier { “[” expression “]” } .   

### Identifiers

**pgmIndentifier** = identifier .   
**constIndentifier** = identifier .   
**varIndentifier** = identifier .   
**typeIndentifier** = identifier .   
**procIndentifier** = identifier .   
**funcIndentifier** = identifier .   
**identifier** = letter { letter | digit } .   

### Low Level Definitions

**sign** = “+” | “-” .   
**longint** = digit { digit } .   
**string** = “’” stringCharacter { stringCharacter } “’” .   
**stringCharacter** = any-character-except-quote | “’’” .   
**relOperator** = “=” | “\<\>” | “\<” | “\<=” | “\>” | “\>=” .   
**addOperator** = “+” | “-” | or .   
**multOperator** = “\*” | div | and .   
**letter** = “A” | … | “Z” | “a” | … | “z” .   
**digit** = “0” | “1” | “2” | “3” | “4” | “5” | “6” | “7” | “8” | “9” .
  

### Kommentare

**Kommentare** sind zwischen “(\*” und “\*)” eingeschlossen oder folgen
nach “//”

## The Virtual Machine
The 32-bit RISC-like processor emulator is written in CoffeeScript. It takes an assembly file as parameter and runs it. The -d parameter makes it run in debug mode. In this case each register and memory state is shown on the console. For a list of supported assembly commands and their semantics please see the human-readable source code in emu/emulator.coffee

## ToDo
* Implement code generation for procedures
* Implement code generation for procedure calls
* Implement code generation for record field access
* Deal with Strings (fix 64 bytes?)
* Implement file operations in the VM
* Implement symbol table taking care of type sections and forward type declarations
* Check out the tests if they work and if not, why
* Do whatever is missing for self-compiling

## Authors:
    * Szabolcs Gruenwald -- szaby.gruenwald@web.de
    * Reinhold Kolm -- reinhold.kolm@gmx.at

