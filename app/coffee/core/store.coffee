FS        = require 'fs'
utils     = require './utils'
deepMerge = utils.deepMerge




class Store


    constructor: (@ctx, path, def) ->
        @delay = 100
        @read(path, def) if path


    get: (path, def) ->
        keys = path.split '.'
        last = keys.pop()
        obj  = @data
        l    = keys.length
        for key, i in keys
            old = obj
            obj = old[key]
            if obj == null or obj == undefined
                next = keys[i + 1] if i < l - 1
                num  = parseInt next, 10
                if not isNaN(num) and num + '' == next
                    old[key] = obj = []
                else
                    old[key] = obj = {}

        value = obj[last]
        if value == null or value == undefined
            value = obj[last] = def
        value


    set: (path, value) ->
        keys = path.split '.'
        last = keys.pop()
        obj  = @data
        l    = keys.length
        for key, i in keys
            old = obj
            obj = old[key]
            if obj == null or obj == undefined
                next = keys[i + 1] if i < l - 1
                num  = parseInt next, 10
                if not isNaN(num) and num + '' == next
                    old[key] = obj = []
                else
                    old[key] = obj = {}

        if value == null or value == undefined
            delete obj[last] = value
        else
            obj[last] = value

        @update()
        value


    read: (@path, def) ->
        try
            data = require @path
        catch e
            @data = deepMerge {}, def or {}
            @write()
            return @data

        @data = deepMerge {}, def or {}, data or {}
        @data


    update: () ->
        clearTimeout @timeout
        @timeout = setTimeout @write, @delay
        null


    write: () =>
        return null if not @path or not @data
        try
            json = JSON.stringify @data
        catch e
            console.log 'ERROR stringifying props: ', e
            return null

        FS.writeFile @path, json, (e) ->
            if e
                console.log 'ERROR writing props: ', e
        null


module.exports = Store