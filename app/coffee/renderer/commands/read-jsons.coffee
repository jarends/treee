readJsons = (path, recursive) ->
    FS   = require 'fs'
    Path = require 'path'
    jsons = []

    getJson = (path) ->
        data = path: path
        try
            data.json = JSON.parse FS.readFileSync path, 'utf8'
        catch e
            data.error = e
        data

    readPath = (path, recursive, depth) ->
        stat = FS.statSync path
        ext  = Path.extname path
        if ext == '.json' and stat.isFile()
            jsons.push getJson path
        else if stat.isDirectory() and (depth == 0 or recursive)
            try
                files = FS.readdirSync path
                for file in files
                    readPath Path.join(path, file), recursive, depth + 1
            catch e
                jsons.push
                    error: e
                    path:  path

    readPath path, recursive, 0
    jsons


class Cmd

    constructor: (path, recursive) ->
        return readJsons path, recursive if @ == global


    execute: (path, recursive = true) ->
        Fork   = require 'fork-func'
        events = require '../events'
        Fork __filename, path, recursive, (error, result) =>
            if error
                console.log 'readJson.execute error: ', error
            else
                console.log 'readJson.execute result: ', result
                @emitter.emit events.ANALYZE_JSONS, result
        null


module.exports = Cmd


