ViewNode = require('two-trees').ViewNode


class TreeRenderer extends ViewNode


    constructor: (@treeView) ->
        super()
        @node   = null
        @isOver = false
        @isDown = false


    setData: (node) ->
        @node = node
        @updateNow()
        null


    iconClickHandler: (event) =>
        if @node.expanded
            @treeView.flattener.collapse @node, event.metaKey
        else
            @treeView.flattener.expand @node, event.metaKey

        event.stopImmediatePropagation()
        null


    clickHandler: (event) =>
        @treeView.selector.selectByKey @node, event.metaKey, event.shiftKey, false
        null


    render: () ->
        return tag:'div' if not @node

        node       = @node
        isValue    = node.type == 'value'
        noChildren = !node.children or !node.children.length
        depth      = if @treeView.flattener.showRoot then node.depth else node.depth - 1

        tag: 'div'
        className:
            'tree-renderer':           true
            'tree-renderer-selected':  node.selected
            'tree-renderer-active':    @treeView.selector.isActive node
        onClick:  @clickHandler
        children: [
            tag:       'span'
            className: 'tree-renderer-index'
            text:      node.index
        ,
            tag:       'span'
            className:
                'tree-renderer-icon':      true
                'tree-renderer-expanded':  node.expanded
                'tree-renderer-no-expand': isValue or noChildren
            style:     "margin-left: #{depth * 20 + 5}px;"
            onClick:   @iconClickHandler
        ,
            tag:       'span'
            className: 'tree-renderer-label'
            text:      node.name + ':'
        ,
            tag:       'span'
            className: 'tree-renderer-value'
            text:      if isValue then node.value else ''
        ]




module.exports = TreeRenderer
