ViewNode = require('two-trees').ViewNode
TreeView = require '../../../tree-view/tree-view'
Renderer = require './file-tree-renderer-2t'
Parser   = require './file-tree-node-parser'


class FileView extends ViewNode


    updateCfg: (cfg) ->
        super cfg
        @path = cfg.path or '/'
        delete cfg.path


    onMount: () =>

        console.log 'path: ', @path

        @treeView = new TreeView @view.children[0]
        @treeView.init
            rendererClass: Renderer
            parser:        new Parser @treeView

        @treeView.flattener.showRoot = true
        @treeView.flattener.setRoot @path

        #@treeView.flattener.expandAll()
        @treeView.selector.setActive @treeView.flattener.getFirst()

        length = @treeView.flattener.list.length
        height = length * (@treeView.rowHeight + @treeView.rowGap)
        console.log "TreeView.startup: created list with #{length} items and height of #{height}px"


    render: () ->
        @cfg.tag       = 'div'
        @cfg.child     = tag: 'div'
        @cfg.className = @cfg.className + ' file-tree-view'
        @cfg


module.exports = FileView