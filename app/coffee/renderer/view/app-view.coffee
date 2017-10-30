Path         = require 'path'
EMap         = require 'emap'
ViewNode     = require('two-trees').ViewNode
events       = require '../events'
AnalyzerTree = require './analyzer-tree'
DiagramView  = require './diagram-view/diagram-view'
FileTree     = require './file-tree-view/file-tree-view'



class AppView extends ViewNode

    constructor: (cfg) ->
        super cfg
        @index = 0
        @emap  = new EMap()
        @emap.map @ctx, events.ANALYZE_CHANGED, @update


    render: () ->
        r = @ctx.analyzer.result
        #console.log 'render: ', @ctx.analyzer.result

        switch 2
            when 0
                tag:       'div'
                className: 'window'
                child:
                    tag:       FileTree
                    className: 'panel'
                    path:      Path.join __dirname, '../../../../../'
            when 1
                tag:       'div'
                className: 'window'
                child:
                    tag:       AnalyzerTree
                    className: 'panel'
                    data:      @ctx.analyzer.result
            when 2
                tag:       'div'
                className: 'window'
                child:
                    tag:       DiagramView
                    className: 'panel'





module.exports = AppView