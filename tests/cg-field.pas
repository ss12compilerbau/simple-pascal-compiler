Program field;

Type tRecord = record
    f: Longint;
    g: Longint;
end;

Type ptArrayOfRecordReferences: Array of ^tRecord;

Type tRecordOfArrayOfRecordReferences = record
    u: Longint;
    v: ptArrayOfRecordReferences;
    w: Longint;
End;

Type tArrayOfRecordOfArrayReferences = Array of tRecordOfArrayOfRecordReferences;

Var i: Longint;
Var j: Longint;
Var k: Longint;

Var s: tArrayOfRecordOfArrayReferences;

begin

    i := 0;
    // ADDI 1, 0, 0 or MOVI 1, 0, 0
    // STW 1, 28, -4

    j := 0;
    // ADDI 1, 0, 0 or MOVI 1, 0, 0
    // STW 1, 28, -8

    k := 0;
    // ADDI 1, 0, 0 or MOVI 1, 0, 0
    // STW 1, 28, -12

    s := malloc(2 * sizeof(struct record_of_array_t *));
    s[0] := malloc(sizeof(struct record_of_array_t));
    s[0]->v := malloc(4 * sizeof(struct record_t));
    s[0]->v[0] := malloc(sizeof(struct record_t));
    s[0]->v[1] := malloc(sizeof(struct record_t));
    s[0]->v[2] := malloc(sizeof(struct record_t));
    s[0]->v[3] := malloc(sizeof(struct record_t));
    s[1] := malloc(sizeof(struct record_of_array_t));
    s[1]->v := malloc(4 * sizeof(struct record_t));
    s[1]->v[0] := malloc(sizeof(struct record_t));
    s[1]->v[1] := malloc(sizeof(struct record_t));
    s[1]->v[2] := malloc(sizeof(struct record_t));
    s[1]->v[3] := malloc(sizeof(struct record_t));

    k := s[i]->u;
    // LDW 1, 28, -4
    // MULI 1, 1, 4: unlike MULI 1, 1, 40
    // LDW 2, 28, -16: deref from VAR_MODE into REG_MODE
    // ADD 2, 2, 1: index from REG_MODE into REF_MODE
    // LDW 2, 2, 0: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 2, 2, 0: load from REF_MODE into REG_MODE: unlike LDW 2, 1, -92
    // STW 2, 28, -12

    k := s[1]->w;
    // LDW 1, 28, -16: deref from VAR_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 1*4: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 8: load from REF_MODE into REG_MODE: unlike LDW 1, 0, -16
    // STW 1, 28, -12

    k := s[i]->v[j]->f;
    // LDW 1, 28, -4
    // MULI 1, 1, 4: unlike MULI 1, 1, 40
    // LDW 2, 28, -16: deref from VAR_MODE into REG_MODE
    // ADD 2, 2, 1: index from REG_MODE into REF_MODE
    // LDW 2, 2, 0: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 28, -8
    // MULI 1, 1, 4: unlike MULI 2, 2, 8
    // LDW 2, 2, 4: deref from REF_MODE into REG_MODE
    // ADD 2, 2, 1: index from REG_MODE into REF_MODE
    // LDW 2, 2, 0: load from REF_MODE into REG_MODE: unlike LDW 1, 2, -88
    // STW 2, 28, -12

    k := s[1]->v[2]->g;
    // LDW 1, 28, -16: deref from VAR_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 1*4: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 4: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 2*4: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 4: load from REF_MODE into REG_MODE: unlike LDW 1, 0, -28
    // STW 1, 28, -12

    s[0]->v[i]->g := k;
    // LDW 1, 28, -16: deref from VAR_MODE into REF_MODE (via REG_MODE)
    // LDW 1, 1, 0*4: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 2, 28, -4
    // MULI 2, 2, 4: unlike MULI 1, 1, 8
    // LDW 1, 1, 4: deref from REF_MODE into REG_MODE
    // ADD 1, 1, 2: index from REG_MODE into REF_MODE
    // LDW 1, 1, 0: deref from REF_MODE into REF_MODE (via REG_MODE)
    // LDW 2, 28, -12
    // STW 2, 1, 4: unlike STW 2, 1, -84
End.
