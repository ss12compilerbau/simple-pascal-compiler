Emulator = require('./emu').Emulator
###
# Loading and running the emulator
###

# Get the calling arguments
args = process.argv.splice 2
if args.length is 0
    console.info "Usage: coffee emu.coffee filename"
else
    emu = new Emulator
        memSize: 100
        debug: false
    emu.load args[0], (err) ->
        if err
            console.error err
        else
            programParams = args.splice 1
            emu.execute programParams, (exitCode) ->
                if exitCode isnt 0
                    console.info "Exit code is #{exitCode}"
                else
                    console.info "Finished."

