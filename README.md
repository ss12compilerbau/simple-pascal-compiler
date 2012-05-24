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
Until it isn't final, it's only reachable (here)[http://www.cs.uni-salzburg.at/~ck/wiki/index.php?n=CC-Summer-2012.SPCEBNF]

## The Virtual Machine
The 32-bit RISC-like processor emulator is written in CoffeeScript. It takes an assembly file as parameter and runs it. The -d parameter makes it run in debug mode. In this case each register and memory state is shown on the console. For a list of supported assembly commands and their semantics please see the human-readable source code in emu/emulator.coffee

## Authors:
    * Szabolcs Gruenwald -- szaby.gruenwald@web.de
    * Reinhold Kolm -- reinhold.kolm@gmx.at

