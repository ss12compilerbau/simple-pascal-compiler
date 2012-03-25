# Makefile manual:
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

test.scanner : test.scanner.hello
	./scanner scanner.pas scanner.out

test.scanner.hello:
	./scanner tests/hello.pas tests/hello.out
	diff tests/hello.out tests/hello.should

# Parser
parser :
	echo "TODO compile the parser"

test.parser :
	echo "TODO: To be figured out how to run tests in pascal"


clean :
	rm -rf *.s *.o hello scan scanner *.out tests/*.out
	echo "Clean succesful"

