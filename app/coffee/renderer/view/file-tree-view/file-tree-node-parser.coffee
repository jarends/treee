FS     = require 'fs'
Path   = require 'path'
Choki  = require 'chokidar'
EMap   = require 'emap'
IGNORE = /(^|[\/\\])(node_modules|dist|\.idea|\.git)($|[\/\\])/



getPath = (path) ->
    if path
        path = this.name + '.' + path
    else
        path = this.name

    if not this.owner
        return path
    this.owner.getPath path




class Pending

    constructor: (@owner) ->
        @type  = 'file'
        @name  = ''
        @depth = if @owner then @owner.depth + 1 else 0

    parse: () -> @parsed = true




class TreeNodeParser

    @FileNode: FileNode
    @Pending:  Pending



    constructor: (@treeView) ->
        @nodeMap   = {}
        @readQueue = []
        @readings  = 0
        @emap      = new EMap()
        @watch null


    watch: (path) ->
        if @watcher
            @emap.all()
            @watcher.close()

        @watcher = Choki.watch path,
            ignored:       IGNORE
            ignoreInitial: true
            usePolling:    false
            useFsEvents:   true

        @emap.map @watcher, 'add',       @addedHandler,       @
        @emap.map @watcher, 'addDir',    @dirAddedHandler,    @
        @emap.map @watcher, 'unlink',    @unlinkedHandler,    @
        @emap.map @watcher, 'unlinkDir', @dirUnlinkedHandler, @


    getNode: (owner, name, path) ->
        #@watch path if not owner
        node = @nodeMap[path]
        if not node
            node = new FileNode @, path, owner
            #@watcher.add path if node.type == 'dir' and not IGNORE.test path
            @nodeMap[path] = node
            node.getPath   = getPath
        node


    parse: (node) ->
        node.parse()
        null




    readDir: (node) ->
        @readQueue.push node:node, expended:node.expanded
        @readNow()



    readNow: () ->
        if not @readings and not @readQueue.length
            console.log 'READING READY!!!'
        else if not @readings and @readQueue.length
            console.log 'START READING...'

        @readQueue.sort @sortNodes
        while @readings < 5 and @readQueue.length
            ++@readings
            data = @readQueue.shift()
            @read data.node
        null


    read: (node) ->
        FS.readdir node.path, (error, files) =>
            --@readings
            expanded = node.expanded and node.index > -1
            @treeView.flattener.collapse node if expanded
            node.children = []
            for file, i in files
                child = @getNode node, i, Path.join(node.path, file)
                node.children.push child
            @treeView.flattener.expand node, true if expanded
            @readNow()
        null



    sortNodes: (a, b) ->
        return -1 if a.node.path < b.node.path
        return  1 if a.node.path > b.node.path
        0






    updateNode: (node) ->
        flattener = @treeView.flattener
        expanded  = node.expanded
        flattener.collapse node if expanded
        node.update()
        flattener.expand node if expanded
        node


    disposeNode: (node) ->
        path = node.path
        delete @nodeMap[path]
        @watcher.remove path
        node




    addedHandler: (path) ->
        #console.log 'file added: ', path
        null


    dirAddedHandler: (path) ->
        #console.log 'dir added: ', path
        null


    unlinkedHandler: (path) ->
        #console.log 'file removed: ', path
        node = @nodeMap[path]
        if node
            if node.owner
                @treeView.flattener
        null


    dirUnlinkedHandler: (path) ->
        #console.log 'dir removed: ', path
        null




class FileNode


    constructor: (@parser, @path, @owner) ->
        @parsed     = false
        @selected   = false
        @expanded   = false
        @depth      = if @owner then @owner.depth + 1 else 0
        @parseStats()


    parse: () ->
        @parsed = true
        @parseChildren()


    parseStats: () ->
        try
            stat = FS.statSync @path
        @dir  = Path.dirname  @path
        @ext  = Path.extname (@path).replace /^\./, ''
        @name = Path.basename @path
        @base = Path.basename @path, '.' + @ext
        @type = if stat and stat.isDirectory() then 'dir' else 'file'
        #@parser.watcher.add @path if @type == 'dir' and not IGNORE.test @path
        @


    parseChildren: () ->
        if @type == 'dir'
            @children = [new Pending @]
            @parser.readDir @
        @




module.exports = TreeNodeParser