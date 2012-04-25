# Emu is a simple RISC emulator
# still TODO:
# implement mem store
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

    load: (filename) ->
        console.info "to be implemented"
    run: ->
        console.info "to be implemented"

    printState: ->
        console.log @ir.toString()
        console.log @pc.toString()
        for r, i in @reg
            console.log r.toString()

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


class InstructionSet
    constructor: ->
        @instructions = []
    add: (opcode, name, format, execute) -> 
        switch format.toUpperCase()
            when 'F1'
                @instructions[opcode] = new F1Instr opcode, name, execute
            when 'F2'
                @instructions[opcode] = new F2Instr opcode, name, execute
            when 'F3'
                @instructions[opcode] = new F3Instr opcode, name, execute

class Instruction
    constructor: (@opcode, @name, @execute) ->

class F1Instr extends Instruction
    getA: (instr) ->
        instr >> 21 & 31 # 5 bit
    getB: (instr) ->
        instr >> 16 & 31 # 5 bit
    getC: (instr) ->
        instr & 0xffff # 16 bit

class F2Instr extends Instruction
    getA: (instr) ->
        instr >> 21 & 31 # 5 bit
    getB: (instr) ->
        instr >> 16 & 31 # 5 bit
    getC: (instr) ->
        instr & 31 # 5 bit

class F3Instr extends Instruction
    getA: (instr) ->
        0
    getB: (instr) ->
        0
    getC: (instr) ->
        instr & 0x3ffffff # 26 bit

args = process.argv.splice(2)
# console.info args
fs = require 'fs'
fs.open args[0], 'r', (err, fd) ->
    if err and err.errno is 34
        console.error "The file #{args[0]} doesn't exist!"
    else 
        console.info "The file descriptor is #{fd}"
        emu = new Emulator

        ###
        emu.ir.set 0xffffffff
        emu.ir.decode()
        console.log emu.ir.op
        emu.printState()
        ###



