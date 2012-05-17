Program simple;
Var i: Longint;

Type tArray = Array of Longint;
Var a3: tArray;

Type tArrayOfArrays = Array of tArray;
Var a4: tArrayOfArrays;
begin
    // required
    int i;
    i = 15;

    // optional
    // int a1[10];
    // a1[9] = 1;

    // optional
    // int *a2;
    // a2 = malloc(10 * sizeof(int));
    // a2[9] = 2;

    // required
    // typedef int *array_t;
    // array_t a3;
    // a3 = malloc(10 * sizeof(int));
    setLength(a3, 10);
    a3[9] := 3;

    // required
    // typedef array_t *array_of_arrays_t;
    // array_of_arrays_t a4;
    // a4 = malloc(2 * sizeof(array_t));
    setLength(a4, 2);
    a4[1] := a3;
    // printf("a4[1][9]: %d\n", a4[1][9]);
    writeln("a4[1][9]: ", a4[1][9]); // -> 3

    // optional
    // int a5[2][10];
    // a5[1][9] = 4;
end.
