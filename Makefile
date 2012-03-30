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

test.scanner : test.scanner.test

	./scanner scanner.pas scanner.out

test.scanner.test:
	./scanner test.txt test.out
	cp test.out test.should
	diff test.out test.should

# Parser
parser :
	echo "TODO: parsing the parser"

test.parser :
	echo "TODO: to tests the parser"


clean :
	rm -rf *.s *.o test scan scanner *.out *.should 
	echo "Clean succesful"

