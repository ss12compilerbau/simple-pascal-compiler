#Makefile manual:
# http://www.gnu.org/software/make/manual/

# The default task is 'all'.
all : build
build:  clean scanner parser
	echo "Build successful!"

# Test runs all the tests.
test : build test.scanner test.parser
	echo "Tests successful!"

# Scanner
scanner :
	fpc scanner.pas

test.scanner :
	./scanner scanner.pas scanner.out

test.scanner.hello:
	./scanner hello.pas hello.out
	diff tests/hello.out tests/hello.should

# Parser
parser :
	echo "TODO: parsing the parser"

test.parser :
	echo "TODO: to test the parser"


clean :
	rm -rf *.s *.o hello scan scanner *.out tests/*.out
	echo "Clean succesful"

