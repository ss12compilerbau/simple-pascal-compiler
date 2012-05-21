Emulator = require('./emu').Emulator
###
# Loading and running the emulator
###

# Get the calling arguments
args = process.argv.splice 2
if args.length is 0
    console.info "Usage: coffee emu.coffee filename"
else
    debug = false
    if args[0] is "-d"
        debug = true
        args = args.splice 1
    emu = new Emulator
        memSize: 400
        debug: debug
    emu.load args[0], ->
        programParams = args.splice 1
        unless programParams instanceof Array
            programParams = [programParams]
        emu.execute programParams, (exitCode) ->
            if exitCode isnt 0
                console.info "Exit code is #{exitCode}"
            else
                console.info "Finished."

