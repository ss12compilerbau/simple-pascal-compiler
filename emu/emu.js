// Generated by CoffeeScript 1.3.1
(function() {
  var Emulator, F1Instr, F2Instr, F3Instr, Instruction, InstructionSet, Memory, Register,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Emulator = (function() {

    Emulator.name = 'Emulator';

    function Emulator(options) {
      var i, _i;
      this.options = options;
      if (this.options == null) {
        this.options = {};
      }
      this.debug = options.debug || false;
      this.ir = new Register("IR");
      this.pc = new Register("PC");
      this.reg = [];
      for (i = _i = 0; _i <= 31; i = ++_i) {
        this.reg[i] = new Register("reg[" + ((i + 100).toString().substr(-2)) + "]");
      }
      this.mem = new Memory(options.memSize || 500);
      this.I = new InstructionSet;
      if (this.debug) {
        console.info("The instruction set has " + this.I.instructions.length + " instructions.");
      }
    }

    Emulator.prototype.load = function(filename, callback) {
      var finish,
        _this = this;
      finish = false;
      this.origCode = [];
      this._loadAddr = 0;
      debugger;
      return this._openFile(filename, function(data) {
        var instr, line, str, _i, _len, _ref;
        _ref = data.split("\n");
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          line = _ref[_i];
          if (line.indexOf("###") === 0) {
            finish = true;
          }
          if (!finish) {
            instr = null;
            if (line.indexOf('STR') === 0) {
              str = line.split(';')[1];
              instr = "STR '" + str + "'";
            } else {
              instr = line.split(";")[0].trim();
            }
            if (instr) {
              _this._processInstr(instr);
              _this.origCode.push(line);
            }
          }
        }
        _this.reg[28].set(_this._loadAddr);
        return callback();
      });
    };

    Emulator.prototype.execute = function(params, callback) {
      var a, b, c, instr, instrWord, nextRegForParams, p, state, _i, _len;
      nextRegForParams = 30;
      this.reg[nextRegForParams].set(params.length);
      nextRegForParams--;
      for (_i = 0, _len = params.length; _i < _len; _i++) {
        p = params[_i];
        p = Number(p);
        if (p !== 'NaN') {
          this.reg[nextRegForParams].set(p);
          nextRegForParams--;
        } else {
          throw "Only number parameters are implemented";
        }
      }
      this.reg[30].set(this.options.memSize);
      if (this.debug) {
        debugger;
      }
      if (this.debug) {
        this.printState();
      }
      while (this.exit !== true) {
        this.ir.set(this.mem.get(this.pc.get()));
        instr = this.I.getInstruction(this.ir.get());
        instrWord = this.ir.get();
        a = instr.getA(instrWord);
        b = instr.getB(instrWord);
        c = instr.getC(instrWord);
        if (this.debug) {
          this.printState();
          console.info(state = "\nline " + (this.pc.get() / 4) + ": running " + instr.name + " " + a + "," + b + "," + c);
          console.info(this.origCode[this.pc.get() / 4]);
        }
        instr.execute.apply(this, [a, b, c]);
      }
      if (this.debug) {
        this.printState();
      }
      return callback(this.exitCode);
    };

    Emulator.prototype.printState = function() {
      var i, r, _i, _len, _ref;
      console.log("\nMachine state:");
      console.log(this.ir.toString());
      console.log(this.pc.toString());
      _ref = this.reg;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        r = _ref[i];
        console.log(r.toString());
      }
      console.log('Code+Global:');
      this.mem.printState(0, this.reg[28].get());
      console.log('Heap:');
      this.mem.printState(this.reg[28].get() + 1, this.reg[29].get());
      console.log('Stack:');
      return this.mem.printState(this.reg[30].get() + 1, this.options.memSize);
    };

    Emulator.prototype._processInstr = function(instrStr) {
      var cl, i, instr, p, str, strInstr, _i, _j, _len, _ref, _results;
      cl = [];
      cl[0] = instrStr.split(" ")[0].trim();
      if (cl[0] === 'STR') {
        console.info('STR: ', str = instrStr.substring(5, instrStr.length - 1));
        _results = [];
        for (i = _i = 0; _i <= 4; i = ++_i) {
          debugger;
          strInstr = str.charCodeAt(i * 4) || 0;
          strInstr = (strInstr << 8) + (str.charCodeAt(i * 4 + 1) || 0);
          strInstr = (strInstr << 8) + (str.charCodeAt(i * 4 + 2) || 0);
          strInstr = (strInstr << 8) + (str.charCodeAt(i * 4 + 3) || 0);
          this.mem.put(this._loadAddr, strInstr);
          _results.push(this._loadAddr += 4);
        }
        return _results;
      } else {
        _ref = instrStr.split(" ")[1].trim().replace(' ', '').split(",");
        for (_j = 0, _len = _ref.length; _j < _len; _j++) {
          p = _ref[_j];
          cl.push(Number(p.trim()));
        }
        instr = this.I.encode(cl);
        if (this.debug) {
          console.info("" + this._loadAddr + ": ", cl);
        }
        this.mem.put(this._loadAddr, instr);
        return this._loadAddr += 4;
      }
    };

    Emulator.prototype._openFile = function(filename, callback) {
      var fs;
      fs = require('fs');
      return fs.readFile(filename, "utf-8", function(err, data) {
        if (err && err.errno === 34) {
          return console.error("The file " + filename + " doesn't exist!");
        } else {
          return callback(data);
        }
      });
    };

    return Emulator;

  })();

  Register = (function() {

    Register.name = 'Register';

    function Register(name) {
      this.name = name;
      this.val = 0;
    }

    Register.prototype.set = function(val) {
      if (val > 0xffffffff) {
        throw "32 bit overflow on " + this.name;
      }
      return this.val = val;
    };

    Register.prototype.get = function() {
      return this.val;
    };

    Register.prototype.toString = function() {
      var hex;
      hex = (this.val + 0x100000000).toString(16).substr(-8);
      return "" + this.name + " = 0x" + hex + " (" + this.val + ")";
    };

    return Register;

  })();

  Memory = (function() {

    Memory.name = 'Memory';

    function Memory(size) {
      var i, _i;
      this.mem = [];
      for (i = _i = 0; 0 <= size ? _i <= size : _i >= size; i = 0 <= size ? ++_i : --_i) {
        this.mem[i] = 0;
      }
    }

    Memory.prototype.put = function(addr, word) {
      var i, offset, _i, _results;
      if (addr + 3 > this.mem.length) {
        throw "Memory overflow (" + addr + ")";
      }
      _results = [];
      for (i = _i = 0; _i <= 3; i = ++_i) {
        offset = (3 - i) * 8;
        _results.push(this.mem[addr + i] = (word >> offset) & 255);
      }
      return _results;
    };

    Memory.prototype.get = function(addr) {
      var i, res, _i;
      res = 0;
      for (i = _i = 0; _i <= 3; i = ++_i) {
        res += this.mem[addr + i] << ((3 - i) * 8);
      }
      return res;
    };

    Memory.prototype.printState = function(from, to) {
      var adr, m, r, re, res, _i, _len, _ref;
      res = "";
      r = "";
      re = "";
      _ref = this.mem;
      for (adr = _i = 0, _len = _ref.length; _i < _len; adr = ++_i) {
        m = _ref[adr];
        if (adr < to && adr > from) {
          r += "" + ((m + 0x100).toString(16).substr(-2));
          if (adr % 4 === 3) {
            re += " 0x" + r + "(" + (this.get(adr - 3)) + ")";
            r = "";
            if (adr % 20 === 19) {
              res += "" + re + "\n";
              re = "";
            }
          }
        }
      }
      res += "" + re + "\n";
      return console.log(res);
    };

    return Memory;

  })();

  InstructionSet = (function() {

    InstructionSet.name = 'InstructionSet';

    function InstructionSet() {
      this.instructions = [];
      this.operations = {};
      this.add(0, 'ADDI', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() + c);
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(1, 'SUBI', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() - c);
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(2, 'MULI', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() * c);
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(3, 'DIVI', 'F1', function(a, b, c) {
        if (c === 0) {
          console.info('Runtime error: Division by Zero!');
        } else {
          this.reg[a].set(this.reg[b].get() / c);
        }
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(4, 'MODI', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() % c);
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(5, 'CMPI', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() - c);
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(6, 'ADD', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() + this.reg[c].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(7, 'SUB', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() - this.reg[c].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(8, 'MUL', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() * this.reg[c].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(9, 'DIV', 'F1', function(a, b, c) {
        if (this.reg[c].get() === 0) {
          console.info('Runtime error: Division by Zero!');
        } else {
          this.reg[a].set(this.reg[b].get() / this.reg[c].get());
        }
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(10, 'MOD', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() % this.reg[c].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(11, 'CMP', 'F1', function(a, b, c) {
        this.reg[a].set(this.reg[b].get() - this.reg[c].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(12, 'LDW', 'F1', function(a, b, c) {
        this.reg[a].set(this.mem.get(this.reg[b].get() + c));
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(13, 'STW', 'F1', function(a, b, c) {
        this.mem.put(this.reg[b].get() + c, this.reg[a].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(14, 'BEQ', 'F1', function(a, b, c) {
        if (this.reg[a].get() === 0) {
          return this.pc.set(this.pc.get() + c * 4);
        } else {
          return this.pc.set(this.pc.get() + 4);
        }
      });
      this.add(15, 'BGE', 'F1', function(a, b, c) {
        if (this.reg[a].get() >= 0) {
          return this.pc.set(this.pc.get() + c * 4);
        } else {
          return this.pc.set(this.pc.get() + 4);
        }
      });
      this.add(16, 'BGT', 'F1', function(a, b, c) {
        if (this.reg[a].get() > 0) {
          return this.pc.set(this.pc.get() + c * 4);
        } else {
          return this.pc.set(this.pc.get() + 4);
        }
      });
      this.add(17, 'BLE', 'F1', function(a, b, c) {
        if (this.reg[a].get() <= 0) {
          return this.pc.set(this.pc.get() + c * 4);
        } else {
          return this.pc.set(this.pc.get() + 4);
        }
      });
      this.add(18, 'BLT', 'F1', function(a, b, c) {
        if (this.reg[a].get() < 0) {
          return this.pc.set(this.pc.get() + c * 4);
        } else {
          return this.pc.set(this.pc.get() + 4);
        }
      });
      this.add(19, 'BNE', 'F1', function(a, b, c) {
        if (this.reg[a].get() !== 0) {
          return this.pc.set(this.pc.get() + c * 4);
        } else {
          return this.pc.set(this.pc.get() + 4);
        }
      });
      this.add(20, 'BR', 'F1', function(a, b, c) {
        return this.pc.set(this.pc.get() + c * 4);
      });
      this.add(21, 'BSR', 'F1', function(a, b, c) {
        this.reg[31].set(this.pc.get() + 4);
        return this.pc.set(this.pc.get() + c * 4);
      });
      this.add(22, 'WRN', 'F1', function(a, b, c) {
        console.log(this.reg[a].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(23, 'EXT', 'F1', function(a, b, c) {
        this.exit = true;
        this.exitCode = a;
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(24, 'POP', 'F1', function(a, b, c) {
        this.reg[a].set(this.mem.get(this.reg[b].get()));
        this.reg[b].set(this.reg[b].get() + c);
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(25, 'PSH', 'F1', function(a, b, c) {
        this.reg[b].set(this.reg[b].get() - c);
        this.mem.put(this.reg[b].get(), this.reg[a].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(26, 'RET', 'F2', function(a, b, c) {
        return this.pc.set(this.reg[c].get());
      });
      this.add(27, 'WRS', 'F1', function(a, b, c) {
        var res, word;
        res = '';
        console.info('WRS');
        word = this.mem.get(this.reg[c].get());
        return this.pc.set(this.pc.get() + 4);
      });
      this.add(28, 'WCR', 'F1', function(a, b, c) {
        return this.pc.set(this.pc.get() + 4);
      });
      /* 
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
      */

    }

    InstructionSet.prototype.add = function(opcode, name, format, execute) {
      if (this.instructions[opcode] !== void 0) {
        throw "Opcode for " + opcode + " is already defined for " + this.instructions[opcode].name + ". It cannot be overwritten by " + name;
      } else {
        switch (format.toUpperCase()) {
          case 'F1':
            return this.instructions[opcode] = this.operations[name] = new F1Instr(opcode, name, execute);
          case 'F2':
            return this.instructions[opcode] = this.operations[name] = new F2Instr(opcode, name, execute);
          case 'F3':
            return this.instructions[opcode] = this.operations[name] = new F3Instr(opcode, name, execute);
        }
      }
    };

    InstructionSet.prototype.encode = function(cl) {
      if (!this.operations[cl[0]]) {
        debugger;
        throw "Operation " + cl[0] + " is undefined!";
      }
      return this.operations[cl[0]].encode(cl[1] || 0, cl[2] || 0, cl[3] || 0);
    };

    InstructionSet.prototype.getInstruction = function(instrWord) {
      var opcode;
      opcode = instrWord >> 26 & 63;
      return this.instructions[opcode];
    };

    return InstructionSet;

  })();

  Instruction = (function() {

    Instruction.name = 'Instruction';

    function Instruction(opcode, name, execute) {
      this.opcode = opcode;
      this.name = name;
      this.execute = execute;
      if (this.opcode > 63 || this.opcode < 0) {
        throw "The opcode has to be between 0 and 63";
      }
    }

    return Instruction;

  })();

  F1Instr = (function(_super) {

    __extends(F1Instr, _super);

    F1Instr.name = 'F1Instr';

    function F1Instr() {
      return F1Instr.__super__.constructor.apply(this, arguments);
    }

    F1Instr.prototype.encode = function(a, b, c) {
      if (c < 0) {
        c += 0x10000;
      }
      return (this.opcode << 26) + (a << 21) + (b << 16) + c;
    };

    F1Instr.prototype.getA = function(instr) {
      return instr >> 21 & 31;
    };

    F1Instr.prototype.getB = function(instr) {
      return instr >> 16 & 31;
    };

    F1Instr.prototype.getC = function(instr) {
      var c;
      c = instr & 0xffff;
      if (c > 0x8000) {
        c -= 0x10000;
      }
      return c;
    };

    return F1Instr;

  })(Instruction);

  F2Instr = (function(_super) {

    __extends(F2Instr, _super);

    F2Instr.name = 'F2Instr';

    function F2Instr() {
      return F2Instr.__super__.constructor.apply(this, arguments);
    }

    F2Instr.prototype.encode = function(a, b, c) {
      if (c < 0) {
        c += 0x10000;
      }
      return (this.opcode << 26) + (a << 21) + (b << 16) + c;
    };

    F2Instr.prototype.getA = function(instr) {
      return instr >> 21 & 31;
    };

    F2Instr.prototype.getB = function(instr) {
      return instr >> 16 & 31;
    };

    F2Instr.prototype.getC = function(instr) {
      var c;
      c = instr & 31;
      if (c > 0xff) {
        c -= 0x10000;
      }
      return c;
    };

    return F2Instr;

  })(Instruction);

  F3Instr = (function(_super) {

    __extends(F3Instr, _super);

    F3Instr.name = 'F3Instr';

    function F3Instr() {
      return F3Instr.__super__.constructor.apply(this, arguments);
    }

    F3Instr.prototype.encode = function(a, b, c) {
      if (c < 0) {
        throw "F3 instructions cannot have a negative c";
      }
      return (this.opcode << 26) + c;
    };

    F3Instr.prototype.getA = function(instr) {
      return 0;
    };

    F3Instr.prototype.getB = function(instr) {
      return 0;
    };

    F3Instr.prototype.getC = function(instr) {
      return instr & 0x3ffffff;
    };

    return F3Instr;

  })(Instruction);

  exports.Emulator = Emulator;

}).call(this);
