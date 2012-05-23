#Makefile manual:
# http://www.gnu.org/software/make/manual/

COMPILER=fpc -gw3

# The default task is 'all'.
all : build

clean :
	rm -rf *.s *.o hello ScanWrapper ParseWrapper STWrapper SPC CGWrapper *.out tests/*.out *.exe *.asm
	@echo "Clean succesful"

build:  clean  build.codegen
	cp CGWrapper SPC
	@echo "Build successful!"

runLustAsmTest:
	node emu/emulator -d out.asm

# Test runs all the tests.
test : build test.scanner test.symboltable test.parser 
	@echo "Tests successful!"

# Scanner
build.scanner : clean
	${COMPILER} ScanWrapper.pas
	@echo "Scanner build successful"

test.scanner : build.scanner test.scanner.terminals test.scanner.comment test.scanner.commentfail test.scanner.keywords test.scanner.string  test.scanner.stringfail test.scanner.include test.scanner.selfScanning
	@echo "Scanner tests ok."

test.scanner.terminals : build.scanner
	./ScanWrapper tests/scan_terminals.pas >test.out
	diff test.out tests/scan_terminals.should
	@echo "test.scanner.terminals ok"

test.scanner.keywords : build.scanner
	./ScanWrapper tests/scan_keywords.pas >test.out
	diff test.out tests/scan_keywords.should
	@echo "test.scanner.keywords ok"

test.scanner.comment : build.scanner
	./ScanWrapper tests/scan_comment.pas >test.out
	diff test.out tests/scan_comment.should
	@echo "test.scanner.comment ok"

test.scanner.commentfail : build.scanner
	./ScanWrapper tests/scan_commentfail.pas >test.out
	diff test.out tests/scan_commentfail.should
	@echo "test.scanner.commentfail ok"

test.scanner.string : build.scanner
	./ScanWrapper tests/scan_string.pas >test.out
	diff test.out tests/scan_string.should
	@echo "test.scanner.string ok"

test.scanner.stringfail : build.scanner
	./ScanWrapper tests/scan_stringfail.pas >test.out
	diff test.out tests/scan_stringfail.should
	@echo "test.scanner.stringfail ok"

test.scanner.include : build.scanner
	./ScanWrapper tests/scan_include.pas >test.out
	diff test.out tests/scan_include.should
	@echo "test.scanner.string ok"

test.scanner.selfScanning : build.scanner
	./ScanWrapper scanner.pas >/dev/null
	@echo "selfscanning ok"

# Parser
build.parser : clean
	${COMPILER} ParseWrapper.pas

test.parser : test.selfParsing
	@echo "test.parser successful"

test.selfParsing : build.parser
	 ./ParseWrapper ParseWrapper.pas

# Symboltable
build.symboltable : clean
	${COMPILER} STWrapper.pas
	@echo "Symboltable build successful!"

test.symboltable: build.symboltable
	./STWrapper # >test.out
	# diff test.out tests/symboltabletest.should
	@echo "Symboltable tests ok."

# Code generator
build.codegen: clean
	${COMPILER} CGWrapper.pas

test.codegen : test.codegen.assignment test.codegen.boolean test.codegen.arrays test.codegen.records test.codegen.arrayselements test.codegen.conditionals-loops test.codegen.field
	@echo "Codegeneration tests ok."

test.codegen.assignment : build.codegen
	./CGWrapper tests/cg-assignment.pas
	diff out.asm tests/cg-assignment.should
	@echo "Assignment test okay."

test.codegen.boolean: build.codegen
	./CGWrapper tests/cg-boolean.pas
	@echo "Code emitted:"
	@cat out.asm

test.codegen.ifstatement: build.codegen
	./CGWrapper tests/cg-ifstatement.pas
	diff out.asm tests/cg-ifstatement.should
	@echo "If statement test okay."

test.codegen.whilestatement: build.codegen
	./CGWrapper tests/cg-whilestatement.pas
	diff out.asm tests/cg-whilestatement.should
	@echo "While statement test okay."

test.codegen.arrays: build.codegen
	./CGWrapper tests/cg-arrays.pas
	@echo "Code emitted:"
	@cat out.asm

test.codegen.records: build.codegen
	./CGWrapper tests/cg-records.pas
	@echo "Code emitted:"
	@cat out.asm

test.codegen.arrayselements: build.codegen
	./CGWrapper tests/cg-arrayselements.pas
	@echo "Code emitted:"
	@cat out.asm

test.codegen.conditionals-loops: build.codegen
	./CGWrapper tests/cg-conditionals-loops.pas
	@echo "Code emitted:"
	@cat out.asm

test.codegen.field: build.codegen
	./CGWrapper tests/cg-field.pas
	@echo "Code emitted:"
	@cat out.asm

test.codegen.hw4: build.codegen
	./CGWrapper tests/hw4.pas
	@echo "Code emitted:"
	@cat out.asm


# Emulator
install.emu:
	npm install -g coffee-script

test.emu: test.emu.fibo
	@echo "All emulator tests ok."
test.emu.fibo:
	coffee emu/emulator.coffee emu/fibonacci.asm 12 > test.out
	diff test.out tests/emu_fibo12.should
	@echo "Emulator fibonacci test ok."

