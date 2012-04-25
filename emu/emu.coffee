# Emu is a simple RISC emulator
# still TODO:
# implement cycle of load, fetch, decode, execute, load again, etc.
# implement pop and push operations
# implement control instructions
# implement file operations
# implement system procedures

class Emulator
    constructor: ->
        # it has an instruction register and a program counter
        @ir = new InstructionRegister
        @pc = new Register "PC"
        # 32 32bit general purpose registers
        @reg = []
        for i in [0..31]
            @reg[i] = new Register "reg[#{(i+100).toString().substr(-2)}]"

        @mem = new Memory 500

        @I = new InstructionSet

        # Register Instructions, immediate addressing (F1)
        @I.add 0, 'ADDI', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() + c
            pc.set pc.get() + 4

        @I.add 1, 'SUBI', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() - c
            pc.set pc.get() + 4

        @I.add 2, 'MULI', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() * c
            pc.set pc.get() + 4

        @I.add 3, 'DIVI', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() / c
            pc.set pc.get() + 4

        @I.add 4, 'MODI', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() % c
            pc.set pc.get() + 4

        @I.add 5, 'CMPI', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() - c
            pc.set pc.get() + 4

        # Register Instructions, register addressing (F2)
        @I.add 6, 'ADD', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() + reg[c].get()
            pc.set pc.get() + 4

        @I.add 7, 'SUB', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() - reg[c].get()
            pc.set pc.get() + 4

        @I.add 8, 'MUL', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() * reg[c].get()
            pc.set pc.get() + 4

        @I.add 9, 'DIV', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() / reg[c].get()
            pc.set pc.get() + 4

        @I.add 10, 'MOD', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() % reg[c].get()
            pc.set pc.get() + 4

        @I.add 11, 'CMP', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set reg[b].get() - reg[c].get()
            pc.set pc.get() + 4

        ###
        # Memory Instructions F1, Load and store words
        @I.add 12, 'LDW', 'F1', (a,b,c, reg, mem, pc) ->
            reg[a].set mem[reg[b].get() + c].get()/4]
            pc.set pc.get() + 4

        @I.add 13, 'STW', 'F1', (a,b,c, reg, mem, pc) ->
            mem[reg[b].get() + c].get()/4].set reg[a]
            pc.set pc.get() + 4
        ###
        console.info "The instruction set has #{@I.instructions.length} instructions."

    load: (filename, callback) ->
        finish = false
        @_loadAddr = 0
        @_openFile filename, (data)=>
            for line in data.split "\n"
                if line.indexOf("###") is 0 then finish = true
                unless finish
                    instr = line.split(";")[0].trim()
                    if instr then @processInstr instr
            callback()
    processInstr: (instrStr) ->
        cl = []
        cl[0] = instrStr.split(" ")[0].trim()
        for p in instrStr.split(" ")[1].trim().split ","
            cl.push Number p.trim()
        instr = @I.encode cl
        console.info cl, "0x#{instr.toString(16)}"
        @mem.put @_loadAddr, instr
        @_loadAddr += 4
    _openFile: (filename, callback) ->
        fs = require 'fs'
        fs.readFile args[0], "utf-8", (err, data) ->
            if err and err.errno is 34
                console.error "The file #{args[0]} doesn't exist!"
            else
                callback data
                # callback()
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
        console.info "Execute is to be implemented"
        callback(0)

    printState: ->
        console.log "\nMachine state:"
        console.log @ir.toString()
        console.log @pc.toString()
        for r, i in @reg
            console.log r.toString()
        @mem.printState()

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

class InstructionRegister extends Register
    constructor: ->
        super 'IR'
    decode: ->
        @op = @val >> 26 & 63;

class Memory
    constructor: (size)->
        @mem = []
        for i in [0..size]
            @mem[i] = 0
    put: (addr, word) ->
        if addr+3 > @mem.length
            throw "Memory overflow"
        # console.info "putting 0x#{word.toString(16)} at mem[#{addr}]"
        for i in [0..3]
            offset = (3-i)*8
            @mem[addr + i] = (word >> offset) & 255
        # @printState()
    get: (addr) ->
        res = 0
        for i in [0..3]
            res += @mem[addr+i] << ((3-i)*8)
        res
    printState: ->
        console.log "Memory state:"
        res = ""
        for m in @mem
            res += " #{(m + 0x100).toString(16).substr(-2)}"
        console.log res

class InstructionSet
    constructor: ->
        @instructions = []
        @operations = {}
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
    encode: (cl) ->
        unless @operations[cl[0]]
            throw "Operation #{cl[0]} is undefined!"
        @operations[cl[0]].encode cl[1] or 0, cl[2] or 0, cl[3] or 0

class Instruction
    constructor: (@opcode, @name, @execute) ->
        if @opcode > 63 or @opcode < 0
            throw "The opcode has to be between 0 and 63"

class F1Instr extends Instruction
    encode: (a,b,c) ->
        (@opcode << 26) + (a << 21) + (b << 16) + c
    getA: (instr) ->
        instr >> 21 & 31 # 5 bit
    getB: (instr) ->
        instr >> 16 & 31 # 5 bit
    getC: (instr) ->
        instr & 0xffff # 16 bit

class F2Instr extends Instruction
    encode: (a,b,c) ->
        (@opcode << 26) + (a << 21) + (b << 16) + c
    getA: (instr) ->
        instr >> 21 & 31 # 5 bit
    getB: (instr) ->
        instr >> 16 & 31 # 5 bit
    getC: (instr) ->
        instr & 31 # 5 bit

class F3Instr extends Instruction
    encode: (a,b,c) ->
        (@opcode << 26) + c
    getA: (instr) ->
        0
    getB: (instr) ->
        0
    getC: (instr) ->
        instr & 0x3ffffff # 26 bit

# Loading and running the emulator
args = process.argv.splice 2
if args.length is 0
    console.info "Usage: coffee emu.coffee filename"
else
    emu = new Emulator
    emu.load args[0], (err) ->
        if err
            console.error err
        else
            programParams = args.splice 1
            emu.execute programParams, (exitCode) ->
                emu.printState()
                if exitCode isnt 0
                    console.info "Exit code is #{exitCode}"
                else
                    console.info "Finished."
###
mem = new Memory(16)
mem.put 0, 0x11223344
mem.put 4, 0x12345678

console.info "at 0: 0x" + mem.get(0).toString(16)
console.info "at 2: 0x" + mem.get(2).toString(16)
console.info "at 4: 0x" + mem.get(4).toString(16)

mem.printState()
###


