# Emu is a simple RISC emulator
# still TODO:
# implement file operations
# implement system procedures
# implement passing a string parameter, e.g. as a command line parameter

class Emulator
    # Options can define memSize (in bytes) and debug (boolean)
    constructor: (options) ->
        options ?= {}
        @debug = options.debug or false
        # it has an instruction register and a program counter
        @ir = new Register "IR"
        @pc = new Register "PC"
        # 32 32bit general purpose registers
        @reg = []
        for i in [0..31]
            @reg[i] = new Register "reg[#{(i+100).toString().substr(-2)}]"
        @mem = new Memory options.memSize or 500
        @I = new InstructionSet
        if @debug
            console.info "The instruction set has #{@I.instructions.length} instructions."

    # Loads an assembly file. When done, calls the callback function
    load: (filename, callback) ->
        finish = false
        @origCode = []
        @_loadAddr = 0
        debugger
        @_openFile filename, (data)=>
            for line in data.split "\n"
                if line.indexOf("###") is 0 then finish = true
                unless finish
                    instr = null
                    if line.indexOf('STR') is 0
                        str = line.split(';')[1]
                        instr = "STR '#{str}'"
                    else
                        instr = line.split(";")[0].trim()
                    if instr
                        @_processInstr instr
                        @origCode.push line
            @reg[28].set @_loadAddr
            callback()

    # Execute program with the given parameter list. 
    # When done, call the callback function with the exitCode specified by the running program.
    execute: (params, callback) ->
        # should be put on the stack instead of the registers
        nextRegForParams = 30
        @reg[nextRegForParams].set params.length
        nextRegForParams--
        for p in params
            p = Number(p)
            unless p is 'NaN'
                @reg[nextRegForParams].set p
                nextRegForParams--
            else
                throw "Only number parameters are implemented"
        if @debug
            debugger
        if @debug then @printState()
        while @exit isnt true
            @ir.set @mem.get @pc.get()
            instr = @I.getInstruction @ir.get()
            instrWord = @ir.get()
            a = instr.getA instrWord
            b = instr.getB instrWord
            c = instr.getC instrWord
            if @debug
                @printState()
                console.info state = "\nline #{@pc.get()/4}: running #{instr.name} #{a},#{b},#{c}"
                console.info @origCode[@pc.get()/4]
            # Call instruction.execute with context this, so setting @exit = true 
            instr.execute.apply @, [a,b,c]#, @reg, @mem, @pc]
        if @debug
            @printState()
        callback(@exitCode)

    # Print the machine state on the console
    printState: ->
        console.log "\nMachine state:"
        console.log @ir.toString()
        console.log @pc.toString()
        for r, i in @reg
            console.log r.toString()
        console.log 'Code+Global:'
        @mem.printState 0, @reg[28].get()
        console.log 'Heap:'
        @mem.printState @reg[28].get() + 1, @reg[29].get()

    # internal method
    _processInstr: (instrStr) ->
        cl = []
        cl[0] = instrStr.split(" ")[0].trim()
        if cl[0] is 'STR'
            console.info 'STR: ', str = instrStr.substring(5, instrStr.length-1)
            for i in [0..4]
                debugger
                strInstr = str.charCodeAt(i*4) or 0
                strInstr = (strInstr << 8) + (str.charCodeAt(i*4 + 1) or 0)
                strInstr = (strInstr << 8) + (str.charCodeAt(i*4 + 2) or 0)
                strInstr = (strInstr << 8) + (str.charCodeAt(i*4 + 3) or 0)
                @mem.put @_loadAddr, strInstr
                @_loadAddr += 4
        else
            for p in instrStr.split(" ")[1].trim().replace(' ', '').split ","
                cl.push Number p.trim()
            instr = @I.encode cl
            if @debug
                console.info "#{@_loadAddr}: ", cl
            @mem.put @_loadAddr, instr
            @_loadAddr += 4

    # internal method
    _openFile: (filename, callback) ->
        fs = require 'fs'
        fs.readFile filename, "utf-8", (err, data) ->
            if err and err.errno is 34
                console.error "The file #{filename} doesn't exist!"
            else
                callback data
                # callback()

# 32-bit register
class Register
    constructor: (@name) ->
        @val = 0
    set: (val) ->
        if val > 0xffffffff
            throw "32 bit overflow on " + @name
        @val = val
    get: ->
        @val
    toString: ->
        hex = (@val+0x100000000).toString(16).substr(-8)
        "#{@name} = 0x#{hex} (#{@val})"

# byte-addressed Memory block with word-wise put and get
class Memory
    constructor: (size)->
        @mem = []
        for i in [0..size]
            @mem[i] = 0
    # addr is the starting byte, word is the value
    put: (addr, word) ->
        if addr+3 > @mem.length
            throw "Memory overflow"
        # console.info "putting 0x#{word.toString(16)} at mem[#{addr}]"
        for i in [0..3]
            offset = (3-i)*8
            @mem[addr + i] = (word >> offset) & 255
    # addr is the starting byte. Return value is a word.
    get: (addr) ->
        res = 0
        for i in [0..3]
            res += @mem[addr+i] << ((3-i)*8)
        res
    # Prints the whole memory block on the console
    printState: (from, to) ->
        # console.log "Memory state:"
        res = ""
        r = ""
        re = ""
        for m, adr in @mem
            if adr < to and adr > from
                r += "#{(m + 0x100).toString(16).substr(-2)}"
                if adr % 4 is 3
                    re += " 0x#{r}(#{@get(adr-3)})"
                    r = ""
                    if adr % 20 is 19
                        res += "#{re}\n"
                        re = ""
        res += "#{re}\n"
        console.log res

# The instruction set
# The instructions are called in teh context of the Emulator object. 
# That means, in teh functions @reg, @mem, @pc, @ir, etc are instance variables of
# the emulator.
class InstructionSet
    constructor: ->
        # can be accessed by @instructions[opcode]
        @instructions = []
        # can be accessed by @operations['CMP']
        @operations = {}

        # Register Instructions, immediate addressing (F1)
        @add 0, 'ADDI', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() + c
            @pc.set @pc.get() + 4

        @add 1, 'SUBI', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() - c
            @pc.set @pc.get() + 4

        @add 2, 'MULI', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() * c
            @pc.set @pc.get() + 4

        @add 3, 'DIVI', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() / c
            @pc.set @pc.get() + 4

        @add 4, 'MODI', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() % c
            @pc.set @pc.get() + 4

        @add 5, 'CMPI', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() - c
            @pc.set @pc.get() + 4

        # Register Instructions, register addressing (F2)
        @add 6, 'ADD', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() + @reg[c].get()
            @pc.set @pc.get() + 4

        @add 7, 'SUB', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() - @reg[c].get()
            @pc.set @pc.get() + 4

        @add 8, 'MUL', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() * @reg[c].get()
            @pc.set @pc.get() + 4

        @add 9, 'DIV', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() / @reg[c].get()
            @pc.set @pc.get() + 4

        @add 10, 'MOD', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() % @reg[c].get()
            @pc.set @pc.get() + 4

        @add 11, 'CMP', 'F1', (a,b,c) ->
            @reg[a].set @reg[b].get() - @reg[c].get()
            @pc.set @pc.get() + 4

        # Memory Instructions F1, Load and store words
        @add 12, 'LDW', 'F1', (a,b,c) ->
            @reg[a].set(@mem.get((@reg[b].get() + c)))
            @pc.set @pc.get() + 4

        @add 13, 'STW', 'F1', (a,b,c) ->
            @mem.put((@reg[b].get() + c), @reg[a].get())
            @pc.set @pc.get() + 4

        # F1 POP and PUSH

        # Control Instructions F1 Conditional Branching
        @add 14, 'BEQ', 'F1', (a,b,c) ->
            if @reg[a].get() is 0
                @pc.set @pc.get() + c*4
            else
                @pc.set @pc.get() + 4

        @add 15, 'BGE', 'F1', (a,b,c) ->
            if @reg[a].get() >= 0
                @pc.set @pc.get() + c*4
            else
                @pc.set @pc.get() + 4

        @add 16, 'BGT', 'F1', (a,b,c) ->
            if @reg[a].get() > 0
                @pc.set @pc.get() + c*4
            else
                @pc.set @pc.get() + 4

        @add 17, 'BLE', 'F1', (a,b,c) ->
            if @reg[a].get() <= 0
                @pc.set @pc.get() + c*4
            else
                @pc.set @pc.get() + 4

        @add 18, 'BLT', 'F1', (a,b,c) ->
            if @reg[a].get() < 0
                @pc.set @pc.get() + c*4
            else
                @pc.set @pc.get() + 4

        @add 19, 'BNE', 'F1', (a,b,c) ->
            if @reg[a].get() isnt 0
                @pc.set @pc.get() + c*4
            else
                @pc.set @pc.get() + 4

        # Unconditional Branching F1
        @add 20, 'BR', 'F1', (a,b,c) ->
            @pc.set @pc.get() + c*4

        @add 21, 'BSR', 'F1', (a,b,c) ->
            @reg[31].set @pc.get() + 4
            @pc.set @pc.get() + c*4

        @add 22, 'WRN', 'F1', (a,b,c) ->
            console.log @reg[a].get()
            @pc.set @pc.get() + 4

        @add 23, 'EXT', 'F1', (a,b,c) ->
            @exit = true
            @exitCode = a
            @pc.set @pc.get() + 4

        @add 24, 'POP', 'F1', (a,b,c) ->
            @reg[a].set mem.get(@reg[b].get()/4)
            @reg[b].set(@reg[b].get() + c)
            @pc.set(@pc.get() + 4)

        @add 25, 'PSH', 'F1', (a,b,c) ->
            @reg[b].set(@reg[b].get() - c)
            @mem.put(@reg[b].get()/4, @reg[a].get())
            @pc.set @pc.get() + 4

        # RET c: pc = reg[c]; F2, Return from Subroutine
        @add 26, 'RET', 'F2', (a,b,c) ->
            @pc.set @reg[c].get()

        @add 27, 'WRS', 'F1', (a,b,c) ->
            res = ''
            console.info 'WRS'
            word = @mem.get(@reg[c].get())
            # console.log 'word', word >> 8 & 255

            # console.log @reg[a].get()
            @pc.set @pc.get() + 4

        @add 28, 'WCR', 'F1', (a,b,c) ->
            @pc.set @pc.get() + 4
            # console.info
        

        ### 
        File management F2
        FLO a, b, c:
        open ﬁle (pointer to ﬁle name string: reg[a];
                         pointer to mode string "r" or "w": reg[b]) {
          ...fopen...
          reg[c] = ﬁle descriptor;
        }
        FLC c:
        close ﬁle (ﬁle descriptor: reg[c]) {
          ...fclose...
        }

        Reading, writing, F2

        RDC a, c:
        read character from open ﬁle (ﬁle descriptor: reg[a]) {
          ...fread...
          reg[c] = read character;
        }
        WRC a, c:
        write character to open ﬁle (ﬁle descriptor: reg[a];
                                                       character: reg[c]) {
          ...fwrite...
        }
        ###

    # Instructionset.add(opcode, name, format, execute)
    # Instantiates an Instruction, keeping two indices for quick access, one by opcode, one by name.
    # format is one of 'F1', 'F2' and 'F3', execute is a callback that gets executed
    # in the context of the Emulator object. That means @pc = emulator.pc.
    add: (opcode, name, format, execute) ->
        if @instructions[opcode] isnt undefined
            throw "Opcode for #{opcode} is already defined for #{@instructions[opcode].name}. It cannot be overwritten by #{name}"
        else switch format.toUpperCase()
            when 'F1'
                @instructions[opcode] = @operations[name] = new F1Instr opcode, name, execute
            when 'F2'
                @instructions[opcode] = @operations[name] = new F2Instr opcode, name, execute
            when 'F3'
                @instructions[opcode] = @operations[name] = new F3Instr opcode, name, execute

    # encodes a command array [op, a,b,c] into an instruction word
    encode: (cl) ->
        unless @operations[cl[0]]
            debugger
            throw "Operation #{cl[0]} is undefined!"
        @operations[cl[0]].encode cl[1] or 0, cl[2] or 0, cl[3] or 0

    # get instruction object based on the instruction word
    getInstruction: (instrWord) ->
        opcode = instrWord >> 26 & 63
        @instructions[opcode]

# Generic Instruction
class Instruction
    # all of them have an opcode, a name and a function that gets executed in the context of the emulator.
    constructor: (@opcode, @name, @execute) ->
        if @opcode > 63 or @opcode < 0
            throw "The opcode has to be between 0 and 63"

# Specific F1 Instruction: opcode 6 bit, a, b 5 bit, c 16 bit
class F1Instr extends Instruction
    encode: (a,b,c) ->
        if c<0 then c += 0x10000
        (@opcode << 26) + (a << 21) + (b << 16) + c
    getA: (instr) ->
        instr >> 21 & 31 # 5 bit
    getB: (instr) ->
        instr >> 16 & 31 # 5 bit
    getC: (instr) ->
        c = instr & 0xffff # 16 bit
        if c > 0xff then c -= 0x10000
        c

# Specific F2 Instruction: opcode 6 bit, a, b, c 5 bit
class F2Instr extends Instruction
    encode: (a,b,c) ->
        if c<0 then c += 0x10000
        (@opcode << 26) + (a << 21) + (b << 16) + c
    getA: (instr) ->
        instr >> 21 & 31 # 5 bit
    getB: (instr) ->
        instr >> 16 & 31 # 5 bit
    getC: (instr) ->
        c = instr & 31 # 5 bit
        if c > 0xff then c -= 0x10000
        c

# Specific F3 Instruction: opcode 6 bit, c 26 bit
class F3Instr extends Instruction
    encode: (a,b,c) ->
        if c < 0
            throw "F3 instructions cannot have a negative c"
        (@opcode << 26) + c
    getA: (instr) ->
        0
    getB: (instr) ->
        0
    getC: (instr) ->
        instr & 0x3ffffff # 26 bit

exports.Emulator = Emulator
