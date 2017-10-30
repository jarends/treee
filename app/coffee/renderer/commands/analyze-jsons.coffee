analyzeJsons = (jsons) ->
    Analyzer = require '../analyzer'
    a = new Analyzer jsons
    a.result


class Cmd

    constructor: (jsons) ->
        return analyzeJsons jsons if @ == global


    execute: (jsons) ->
        Fork   = require 'fork-func'
        events = require '../events'
        Fork __filename, jsons, (error, result) =>
            if error
                console.log 'analyzeJson.execute error: ', error
            else
                console.log 'analyzeJson.execute result: ', result
                @ctx.analyzer.fromResult result
                @emitter.emit events.ANALYZE_CHANGED, result
        null

module.exports = Cmd