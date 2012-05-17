Program arrayelements;
Var i: Longint;
Var j: Longint;

Type tArray = Array of Longint;
Var a: tArray;

Type tArrayOfArrays = Array of tArray;
Var b: tArrayOfArrays;

begin
    i := 0;
    // ADDI 1, 0, 0 or MOVI 1, 0, 0
    // STW 1, 28, -4

    j := 0;
    // ADDI 1, 0, 0 or MOVI 1, 0, 0
    // STW 1, 28, -8

    // a := malloc(4 * sizeof(int));
    setLength(a, 4);
    // b := malloc(3 * sizeof(array_t));
    setLength(b, 3);
    // b[0] := malloc(5 * sizeof(int));
    setLength(b[0], 5);
    // b[1] := malloc(5 * sizeof(int));
    setLength(b[1], 5);
    // b[2] := malloc(5 * sizeof(int));
    setLength(b[2], 5);

    i := a[j];
    // LDW 1, 28, -8
    // MULI 1, 1, 4
    // LDW 2, 28, -12: deref from VAR_MODE into REG_MODE
    // ADD 2, 2, 1: index from REG_MODE into REF_MODE
    // LDW 2, 2, 0: load from REF_MODE into REG_MODE: unlike LDW 2, 1, -24
    // STW 2, 28, -4

    i := a[2];
    // LDW 1, 28, -12: deref from VAR_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 2*4: load from REF_MODE into REG_MODE: unlike LDW 1, 0, -16
    // STW 1, 28, -4

    i := a[i+j];
    // LDW 1, 28, -4
    // LDW 2, 28, -8
    // ADD 1, 1, 2
    // MULI 1, 1, 4
    // LDW 2, 28, -12: deref from VAR_MODE into REG_MODE
    // ADD 2, 2, 1: index from REG_MODE into REF_MODE
    // LDW 2, 2, 0: load from REF_MODE into REG_MODE: unlike LDW 2, 1, -24
    // STW 2, 28, -4

    i := b[i][j];
    // LDW 1, 28, -4
    // MULI 1, 1, 4: unlike MULI 1, 1, 20
    // LDW 2, 28, -16: deref from VAR_MODE into REG_MODE
    // ADD 2, 2, 1: index from REG_MODE into REF_MODE
    // LDW 1, 28, -8
    // MULI 1, 1, 4
    // LDW 2, 2, 0: deref from REF_MODE into REG_MODE
    // ADD 2, 2, 1: index from REG_MODE into REF_MODE
    // LDW 2, 2, 0: load from REF_MODE into REG_MODE: unlike LDW 1, 2, -84
    // STW 2, 28, -4

    i := b[2][4];
    // LDW 1, 28, -16: deref from VAR_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 2*4: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 4*4: load from REF_MODE into REG_MODE: unlike LDW 1, 0, -28
    // STW 1, 28, -4
end.
