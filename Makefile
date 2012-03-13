# Makefile manual:
# http://www.gnu.org/software/make/manual/

# The default task is 'all'.
all :  clean scanner parser
	echo "Build successful!"

# Test runs all the tests.
test : test.scanner test.parser
	echo "Tests successful!"

# Scanner
scanner :
	fpc scan.pas
	./scan scan.pas

test.scanner :
	echo "TODO: To be figured out how to run tests in pascal"

# Parser
parser :
	echo "TODO compile the parser"

test.parser :
	echo "TODO: To be figured out how to run tests in pascal"


clean :
	rm -rf *.s *.o hallo scan scanner

