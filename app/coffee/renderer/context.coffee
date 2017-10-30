FS           = require 'fs'
Path         = require 'path'
Post         = require 'ppost'
EventEmitter = require 'events'
jsonschema   = require 'jsonschema'
events       = require './events'
Analyzer     = require './analyzer'
CmdMap       = require '../core/cmd-map'
Schema       = require '../core/json-schema'
AppView      = require './view/app-view'
Validator    = jsonschema.Validator


class Context extends EventEmitter


    constructor: () ->
        @startup()




    startup: () ->
        console.log 'startup ...'

        @cmdMap = new CmdMap @
        @cmdMap.mapDir Path.join __dirname, 'commands'



        @analyzer = new Analyzer()

        @app = new AppView inject: ctx: @
        @app.appendTo document.querySelector '.app'

        @emit events.READ_JSONS, Path.join __dirname, '../../examples/eagle5'
        null




module.exports = new Context()