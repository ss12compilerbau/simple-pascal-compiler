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

test.scanner : test.selfScanning test.scanner.terminals test scanner.comment
	./ScanWrapper scanner.pas >scanner.out

test.scanner.terminals :
	./ScanWrapper tests/scan_terminals.pas >test.out
	@diff test.out tests/scan_terminals.should
	@echo "test.scanner.terminals ok"

test.scanner.comment :
	./ScanWrapper tests/scan_comment.pas >test.out
	@diff test.out tests/scan_comment.should
	@echo "test.scanner.comment ok"

test.selfScanning :
	./ScanWrapper scanner.pas

# Parser
build.parser :
	fpc SPC.pas

test.parser : test.selfParsing
	@echo "TODO: to test the parser"

test.selfParsing :
	./SPC parser.pas

clean :
	rm -rf *.s *.o hello ScanWrapper SPC *.out tests/*.out
	@echo "Clean succesful"

