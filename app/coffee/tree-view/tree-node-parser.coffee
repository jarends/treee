getPath = (path) ->
    if path
        path = this.name + '.' + path
    else
        path = this.name

    if not this.owner
        return path
    this.owner.getPath path




class TreeNodeParser


    constructor: (@treeView) ->


    getNode: (owner, name, value) ->
        node          = @treeView.flattener.cache.pop() || {}
        node.parsed   = false
        node.selected = false
        node.expanded = false
        node.name     = name
        node.value    = value
        node.owner    = owner
        node.depth    = if owner then owner.depth + 1 else 0
        node.getPath  = getPath

        if value and Array.isArray value
            node.type = 'array'
        else if value and typeof value == 'object'
            node.type = 'object'
        else
            node.type = 'value'
        node


    parse: (node) ->
        value = node.value

        if node.type == 'array'
            node.children = [] if not node.children
            children      = node.children
            l             = value.length
            for i in [0 ... l]
                children.push @getNode(node, i, value[i])

        else if node.type == 'object'
            node.children = [] if not node.children
            children      = node.children
            obj           = value
            for key of obj
                children.push @getNode(node, key, obj[key])

        node.parsed = true
        null




module.exports = TreeNodeParser