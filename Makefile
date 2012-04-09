#Makefile manual:
# http://www.gnu.org/software/make/manual/

# The default task is 'all'.
all : build
build:  clean build.scanner build.parser
	@echo "Build successful!"

# Test runs all the tests.
test : build test.scanner test.parser
	@echo "Tests successful!"

# Scanner
build.scanner :
	fpc ScanWrapper.pas

test.scanner : test.selfScanning test.scanner.terminals test.scanner.comment
	@echo "Scanner tests ok."

test.scanner.terminals :
	./ScanWrapper tests/scan_terminals.pas >test.out
	diff test.out tests/scan_terminals.should
	@echo "test.scanner.terminals ok"

test.scanner.keywords :
	./ScanWrapper tests/scan_keywords.pas >test.out
	diff test.out tests/scan_keywords.should
	@echo "test.scanner.terminals ok"

test.scanner.comment :
	./ScanWrapper tests/scan_comment.pas >test.out
	diff test.out tests/scan_comment.should
	@echo "test.scanner.comment ok"

test.selfScanning :
	./ScanWrapper scanner.pas >/dev/null
	@echo "selfscanning ok"

# Parser
build.parser :
	@echo "TODO: build the parser"
	# fpc ParserWrapper.pas

test.parser : test.selfParsing
	@echo "TODO: to test the parser"

test.selfParsing :
	# ./ParserWrapper parser.pas

# Symboltable
build.symboltable :
	fpc STWrapper.pas

test.symboltable:
	@echo "Symboltable tests ok."

clean :
	rm -rf *.s *.o hello ScanWrapper SPC *.out tests/*.out
	@echo "Clean succesful"

