FS   = require 'fs'
Path = require 'path'


toCamelCase = (value) ->
    value.replace /-[a-z]/g, (value) ->
        value.charAt(1).toUpperCase()


class CmdMap


    constructor: (@emitter, @ctx) ->
        @ctx        = @emitter if not @ctx
        @eventToCmd = {}




    map: (event, ctrl, target = null) ->
        @unmap event if @eventToCmd[event]
        if typeof ctrl.execute == 'function'
            cmd = (args...) ->
                ctrl.execute.apply ctrl, args

        else if ctrl.prototype and typeof ctrl.prototype.execute == 'function'
            cmd = (args...) =>
                c         = new ctrl()
                c.event   = event
                c.emitter = @emitter
                c.ctx     = @ctx
                c.execute.apply c, args

        else if typeof ctrl == 'function'
            cmd = (args...) ->
                ctrl.apply target, args
        else
            console.error 'Error: Can not map command or callback: ', ctrl, '\n Expecting an object with an execute method, a class witch has an execute method or a function.'
            return

        @emitter.on event,   cmd
        @eventToCmd[event] = cmd
        @




    unmap: (event) ->
        cmd = @eventToCmd[event]
        if cmd
            @emitter.removeListener event, cmd
            delete @eventToCmd[event]
        @




    mapDir: (dir) ->
        files = FS.readdirSync dir
        for file in files
            if /\.js$/.test file
                event = toCamelCase Path.basename(file, '.js')
                try
                    @map event, require Path.join(dir, file)
                catch error
                    console.log 'error mapping command: ', dir, file





module.exports = CmdMap
