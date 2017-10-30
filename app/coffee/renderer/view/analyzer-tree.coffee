EMap         = require 'emap'
ViewNode     = require('two-trees').ViewNode
TreeView     = require '../../tree-view/tree-view'
TreeRenderer = require '../../tree-view/tree-renderer'
TreeParser   = require '../../tree-view/tree-node-parser'
events       = require '../events'




#    000000000  00000000   00000000  00000000
#       000     000   000  000       000     
#       000     0000000    0000000   0000000 
#       000     000   000  000       000     
#       000     000   000  00000000  00000000

class AnalyzerTree extends ViewNode


    constructor: (cfg) ->
        super cfg
        @emap = new EMap()
        @emap.map @ctx, events.ANALYZE_CHANGED, @updateTree, @


    onMount: () =>
        if not @treeView
            @treeView = new TreeView @view.children[0]
            @treeView.init()
            @treeView.flattener.showRoot = true


    updateTree: () ->
        @treeView.flattener.setRoot @ctx.analyzer.result
        @treeView.flattener.collapseAll()
        @treeView.flattener.expandAll()

        console.log 'analyzer.result: ', @ctx.analyzer.result

        @treeView.selector.setActive @treeView.flattener.getFirst()

        length = @treeView.flattener.list.length
        height = length * (@treeView.rowHeight + @treeView.rowGap)
        console.log "AnalyzerTree: created list with #{length} items and height of #{height}px"

        ###
        setTimeout () =>
            @treeView.flattener.filter (node) ->
                path = node.getPath()
                return path != 'root.base' and path != 'root.schemas'
            length = @treeView.flattener.list.length
            height = length * (@treeView.rowHeight + @treeView.rowGap)
            console.log "AnalyzerTree: created list with #{length} items and height of #{height}px"
        ,
            2000
        ###
        @


    render: () ->
        @cfg.tag       = 'div'
        @cfg.child     = tag: 'div'
        @cfg.className = @cfg.className + ' file-tree-view'
        @cfg


module.exports = AnalyzerTree
