class TreeFlattener


    constructor: (@treeView) ->
        @root     = null
        @showRoot = false
        @list     = []
        @cache    = []




    setRoot: (root) ->
        @dispose() if @root and @root.value != root
        @root = @getNode(null, 'root', root) if not @root
        @clearAll()
        if @showRoot
            @list.push @root
            @root.index = 0
        else
            @root.index = -1
        @parseNode @root        
        @root




    expand: (node, recursive) ->
        @parseNode(node) if not node.parsed

        index = node.index
        if index == -1 and node != @root
            throw new Error 'node not in tree'

        list       = @list
        addeds     = []
        secondList = null
        length     = 0
        i          = 0

        @addChildren node, recursive, addeds, index:index

        if addeds.length > 0
            ++index
            secondList = list.splice index, list.length - index
            list       = list.concat addeds
            index      = list.length
            list       = list.concat secondList
            length     = list.length
            @list      = list

            for i in [index ... length]
                list[i].index = i
            @treeView.drawLater()
        null




    collapse: (node, recursive) ->
        @parseNode(node) if not node.parsed

        index  = node.index
        list   = @list
        count  = 0
        length = 0
        i      = 0

        if index == -1 and node != @root
            throw new Error 'node not in tree'

        count = @removeChildren node, recursive, false, 0
        node.expanded = false
        if count
            list.splice ++index, count
            length = list.length
            for i in [index ... length]
                list[i].index = i
            @treeView.drawLater()
        null




    expandAll: () ->
        @parseNode(@root) if not @root.parsed

        if @showRoot
            @expand @root, true
            return

        children = @root.children
        l        = if children then children.length else 0
        for i in [0 ... l]
            @expand children[i], true
        null




    collapseAll: () ->
        @parseNode(@root) if not @root.parsed

        if @showRoot
            @collapse @root, true
            return

        children = @root.children
        l        = if children then children.length else 0
        for i in [0 ... l]
            @collapse children[i], true
        null




    updateNode: (node) ->
        @collapse node
        @expand   node




    filter: (func) ->
        @filterFunc = func
        @updateNode @root




    addChildren: (node, recursive, list, listIndex) ->
        @parseNode node if not node.parsed

        node.expanded = node.type != 'value'
        node.index    = listIndex.index

        children = node.children
        l        = if children then children.length else 0
        child    = null
        for i in [0 ... l]
            child = children[i]
            if @filterFunc
                continue if not @filterFunc child

            child.index = ++listIndex.index
            list.push child

            @parseNode(child) if not child.parsed

            if (recursive or child.expanded) and not node.denyRecursive
                @addChildren child, recursive, list, listIndex
        null




    removeChildren: (node, recursive, removeFromExpanded, count) ->
        @parseNode(node) if not node.parsed
        children   = node.children
        l          = if children and node.expanded then children.length else 0
        child      = null
        for i in [0 ... l]
            child       = children[i]
            child.index = -1
            if recursive or child.expanded
                count += @removeChildren child, recursive, recursive, 0

        count        += l     if l > 0
        node.expanded = false if removeFromExpanded
        count




    getNode: (owner, name, value) ->
        @treeView.parser.getNode owner, name, value




    parseNode: (node) ->
        @treeView.parser.parse node
        null




    copy: ->
        null


    cut: ->
        null


    paste: ->
        null




    getFirst: () ->
        @list[0]




    getLast: () ->
        @list[@list.length - 1]




    getUp: (node, quick) ->
        return @getLast() if not node

        index = node.index
        return null if index == -1
        @list[index - 1]




    getDown: (node) ->
        return @getFirst() if not node
        index = node.index
        return null if index == -1 or index >= @list.length - 1
        @list[index + 1]




    getQuickDown: (node) ->
        @getDown node




    firstSibling: (node) ->
        null




    lastSibling: (node) ->
        null




    previousSibling: (node) ->
        owner    = node.owner
        children = if owner    then owner.children else null
        index    = if children then children.indexOf(owner) else -1
        return children[index - 1] if index > 0
        null




    nextSibling: (node) ->
        owner    = node.owner
        children = if owner then owner.children else null
        length   = if children then children.length else 0
        index    = if children then children.indexOf(owner) else -1
        return children[index + 1] if index > -1 and index < length - 1
        null




    clearAll: ->
        @list.splice 0, @list.length
        @clearNode @root
        @treeView.drawLater()
        null




    clearNode: (node) ->
        children = node.children
        l        = if children then children.length else 0
        child    = null
        for i in [0 ... l]
            child = children[i]
            @clearNode child

        node.children.splice(0, l) if l > 0
        node.parsed = false;

        if node != @root
            node.name     = null
            node.type     = null
            node.owner    = null
            node.depth    = NaN
            node.selected = false
            node.expanded = false
            node.value    = null
            node.index    = -1
            @cache.push node
        null



    dispose: ->
        @clearAll()
        @root = null;
        @treeView.drawLater()
        null




    update: ->
        null



module.exports = TreeFlattener
