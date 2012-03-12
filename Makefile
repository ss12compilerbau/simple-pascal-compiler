# The default task is 'all'.
all :  clean scanner parser hallo
	echo "Build successful!"

# Test runs all the tests.
test : test.scanner test.parser
	echo "Tests successful!"

# Just for testing make and the fpc installation
hallo :
	fpc hallo.pas
	./hallo

# Scanner
scanner :
	echo "TODO compile the scanner"

test.scanner :
	echo "TODO: To be figured out how to run tests in pascal"

# Parser
parser :
	echo "TODO compile the parser"

test.parser :
	echo "TODO: To be figured out how to run tests in pascal"


clean :
	rm -rf *.s *.o hallo

