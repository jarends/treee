class TreeSelector


    constructor: (@treeView) ->
        @selectedNodes = []
        @activeNode    = null
        @allowDeselect = false




    setActive: (node) ->
        @activeNode = node;
        @updateView()
        null




    select: (node) ->
        if not node
            @deselectAll()
            @activeNode = null
            return

        @deselectAll()
        node.selected = true
        @activeNode   = node;
        @selectedNodes.push node
        @updateView()
        null




    selectWithShift: (node) ->
        if not node
            @deselectAll()
            @activeNode = null
            return

        active        = @activeNode
        list          = @treeView.flattener.list
        first         = @selectedNodes[0]
        selectedNodes = @selectedNodes
        index         = node.index
        activeIndex   = active.index
        i             = 0
        l             = 0
        child         = null

        #if (active and active.owner != node.owner) or index == -1 or activeIndex == -1
        if index == -1 or activeIndex == -1
            @deselectAll()
            @select(node)
            return

        #if first && first.owner != node.owner
        #    @deselectAll()

        if index < activeIndex
            i = index
            l = activeIndex
        else
            i = activeIndex
            l = index

        for i in [i .. l]
            child = list[i]
            #if child.owner == node.owner and selectedNodes.indexOf(child) == -1
            if selectedNodes.indexOf(child) == -1
                selectedNodes.push child
                child.selected = true

        #@activeNode = node
        @updateView()
        null




    selectWithCommand: (node, deselectOnly) ->
        if not node
            @deselectAll()
            @activeNode = null
            return

        nodes = @selectedNodes
        index = nodes.indexOf(node)
        first = nodes[0]

        if index == -1
            #if first and first.owner != node.owner
            #    @deselectAll()

            if not deselectOnly
                node.selected = true
                nodes.push node
        else
            node.selected = false
            index = nodes.indexOf node
            if index > -1
                nodes.splice index, 1

        if deselectOnly and @activeNode
            @activeNode.selected = false
            index = nodes.indexOf @activeNode
            if index > -1
                nodes.splice index, 1

        @activeNode = node
        @updateView()
        null




    selectByKey: (node, metaKey, shiftKey, deleteOnly) ->
        if metaKey
            @selectWithCommand node, deleteOnly
        else if shiftKey
            @selectWithShift node
        else
            @select node
        null




    selectNodes: (nodes) ->
        @updateView()
        null




    isActive: (node) ->
        node == @activeNode




    isActiveSelected: ->
        @selectedNodes.indexOf(@activeNode) > -1




    isSelected: (node) ->
        @selectedNodes.indexOf(node) > -1




    toggle: (node) ->
        return if not node

        index = @selectedNodes.indexOf(node)
        first = @selectedNodes[0]

        if index > -1
            @selectedNodes.splice index, 1
            node.selected = false
        else
            #if first and first.owner != node.owner
            #    @deselectAll()

            @selectedNodes.push node
            node.selected = true

        @activeNode = node
        @updateView()
        null




    toggleActive: ->
        @toggle @activeNode




    deselect: (node) ->
        return if not node

        index = @selectedNodes.indexOf(node);
        if index > -1
            @selectedNodes.splice index, 1
            node.selected = false

        @activeNode = node
        @updateView()
        null




    deselectAll: ->
        nodes = @selectedNodes
        l     = nodes.length
        node  = null

        for i in [0 ... l]
            node          = nodes[i]
            node.selected = false

        nodes.splice 0, nodes.length
        @updateView()
        null




    updateView: ->
        @treeView.drawLater()
        null




module.exports = TreeSelector
