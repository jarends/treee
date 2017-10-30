class Dispatcher


    constructor: () ->
        @listenerMap = {}




    #     0000000   0000000    0000000  
    #    000   000  000   000  000   000
    #    000000000  000   000  000   000
    #    000   000  000   000  000   000
    #    000   000  0000000    0000000  

    add: (type, handler, owner, once = false) ->
        listeners = @listenerMap[type]
        if not listeners
            listeners = @listenerMap[type] = []
        else
            for info in listeners
                return false if info.handler == handler and info.owner == owner and info.once = once

        listeners.push {owner:owner, handler:handler, once:once}
        true




    #     0000000   000   000   0000000  00000000
    #    000   000  0000  000  000       000     
    #    000   000  000 0 000  000       0000000 
    #    000   000  000  0000  000       000     
    #     0000000   000   000   0000000  00000000

    once: (type, handler, owner) ->
        @add type, handler, owner, true




    #    00000000   00000000  00     00   0000000   000   000  00000000
    #    000   000  000       000   000  000   000  000   000  000     
    #    0000000    0000000   000000000  000   000   000 000   0000000 
    #    000   000  000       000 0 000  000   000     000     000     
    #    000   000  00000000  000   000   0000000       0      00000000

    remove: (type, handler, owner, once = false) ->
        listeners = @listenerMap[type]
        return false if not listeners

        for info, i in listeners
            if info.handler == handler and info.owner == owner and info.once == once
                listeners.splice(i, 1)
                delete @listenerMap[type] if not listeners.length
                return true
        false




    #     0000000   000      000    
    #    000   000  000      000    
    #    000000000  000      000    
    #    000   000  000      000    
    #    000   000  0000000  0000000

    removeAll: (type) ->
        removed = false

        if type
            removed = !!@listenerMap[type]
            delete @listenerMap[type]
        else
            for type of @listenerMap
                removed = removed || @removeAll(type)

        removed




    #    000   000   0000000    0000000
    #    000   000  000   000  000     
    #    000000000  000000000  0000000 
    #    000   000  000   000       000
    #    000   000  000   000  0000000 

    has: (type, handler, owner, once = false) ->
        if not type
            for type of @listenerMap
                return true
            return false

        listeners = @listenerMap[type]
        return false if not listeners
        return listeners.length > 0 if not handler

        for info in listeners
            return true if info.handler == handler and info.owner == owner and info.once == once

        false




    #    0000000    000   0000000  00000000    0000000   000000000   0000000  000   000
    #    000   000  000  000       000   000  000   000     000     000       000   000
    #    000   000  000  0000000   00000000   000000000     000     000       000000000
    #    000   000  000       000  000        000   000     000     000       000   000
    #    0000000    000  0000000   000        000   000     000      0000000  000   000
    
    dispatch: (type, args...) ->
        listeners = @listenerMap[type]
        return false if not listeners

        args.unshift(type)
        copy = listeners.concat()

        for info in copy
            @remove(type, info.handler, info.owner, info.once) if info.once
            info.handler.apply(info.owner, args)

        copy.lenght > 0




module.exports = Dispatcher
