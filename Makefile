# The default task is 'all'.
all :  scanner      parser      hallo
# Test runs all the tests.
test : test.scanner test.parser

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

