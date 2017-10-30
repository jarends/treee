EventMap = require 'emap'


class TreeRenderer


    constructor: (@treeView) ->
        @node   = null
        @isOver = false
        @isDown = false

        @view      = document.createElement 'div'
        @iconView  = document.createElement 'span'
        @indexView = document.createElement 'span'
        @labelView = document.createElement 'span'
        @valueView = document.createElement 'span'

        @view.draggable      = true
        @view.className      = 'tree-renderer'
        @iconView.className  = 'tree-renderer-icon'
        @indexView.className = 'tree-renderer-index'
        @labelView.className = 'tree-renderer-label'
        @valueView.className = 'tree-renderer-value'

        @view.appendChild @indexView
        @view.appendChild @iconView
        @view.appendChild @labelView
        @view.appendChild @valueView

        @eventMap = new EventMap()
        @eventMap.map @iconView, 'click',     @iconClickHandler, @
        @eventMap.map @view,     'click',     @clickHandler,     @




    setData: (node) ->
        @node = node
        @updateData()
        null




    updateData: ->
        node       = @node
        isValue    = node.type == 'value'
        noChildren = !node.children or !node.children.length
        depth      = if @treeView.flattener.showRoot then node.depth else node.depth - 1

        @indexView.textContent     = node.index
        @labelView.textContent     = node.name + ':'
        @valueView.textContent     = if isValue then node.value else ''
        @iconView.style.marginLeft = (depth * 20 + 5) + 'px'

        if @node.selected
            @view.classList.add 'tree-renderer-selected'
        else
            @view.classList.remove 'tree-renderer-selected'

        if @treeView.selector.isActive node
            @view.classList.add 'tree-renderer-active'
        else
            @view.classList.remove 'tree-renderer-active'

        if @node.expanded
            @iconView.classList.add 'tree-renderer-expanded'
        else
            @iconView.classList.remove 'tree-renderer-expanded'

        if isValue or noChildren
            @iconView.classList.add 'tree-renderer-no-expand'
        else
            @iconView.classList.remove 'tree-renderer-no-expand'
        null




    iconClickHandler: (event) ->
        if @node.expanded
            @treeView.flattener.collapse @node, event.metaKey
        else
            @treeView.flattener.expand @node, event.metaKey

        event.stopImmediatePropagation()
        null




    clickHandler: (event) ->
        @treeView.selector.selectByKey @node, event.metaKey, event.shiftKey, false
        null




module.exports = TreeRenderer
