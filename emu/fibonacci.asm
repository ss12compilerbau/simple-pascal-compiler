; Annahmen: Reg[0] = 0, Reg[29] = n
ADDI 1,0,1 ; a=1
ADDI 2,0,1 ; b=1
ADDI 3,0,0 ; c(=0)
ADDI 4,0,3 ; ;for (int i = 3; i <= n; i++) { -> i=3
CMP 5,4,29 ; i <= n We jump back to this instr.
BGT 5,0,6 ; jump to exit
ADD 3,1,2 ; c = a + b;
ADD 1,2,0 ; a = b;
ADD 2,3,0 ; b = c;
ADDI 4,4,1 ; i++
BR 0,0,-6;jump to CMP
WRN 2 ; return b; WriteNumber
EXT 0 ; exit(0)

###
    int fib (int n) {
        int a = 1;
        int b = 1;
        int c;
        for (int i = 3; i <= n; i++) {
            c = a + b;
            a = b;
            b = c;
        }
        return b;
    }

