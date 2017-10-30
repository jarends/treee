EventMap = require 'emap'


class TreeDnDManager


    constructor: (@treeView) ->
        view      = @treeView.view
        @id       = @treeView.view.id
        @eventMap = new EventMap()
        @eventMap.map view, "dragstart", @dragStartHandler, @ # Fired when the user starts dragging an element or text selection.
        @eventMap.map view, "drag",      @dragHandler,      @ # Fired when an element or text selection is being dragged
        @eventMap.map view, "dragend",   @dragEndHandler,   @ # Fired when a drag operation is being ended (for example, by releasing a mouse button or hitting the escape key).

        @eventMap.map view, "dragenter", @dragEnterHandler, @ # Fired when a dragged element or text selection enters a valid drop target.
        @eventMap.map view, "dragover",  @dragOverHandler,  @ # Fired when an element or text selection is being dragged over a valid drop target (every few hundred milliseconds).
        @eventMap.map view, "dragleave", @dragLeaveHandler, @ # Fired when a dragged element or text selection leaves a valid drop target.
        @eventMap.map view, "drop",      @dropHandler,      @ # Fired when an element or text selection is dropped on a valid drop target.



    renderViewForChild: (child) ->
        renderView = child
        while renderView and not renderView.classList.contains('tree-renderer')
            renderView = renderView.parentElement
        return renderView


    nodeForView: (view) ->
        renderView = @renderViewForChild view
        for renderer in @treeView.renderers
            return renderer.node if renderer.view == renderView
        null



    setCurrentDrag: (node) ->
        @currentDrag = node
        null


    setCurrentDrop: (node) ->
        @currentDrop = node
        null




    dispose: ->
        @eventMap.all()
        @currentDrag = null
        @currentDrop = null
        null




    #    0000000    00000000    0000000    0000000 
    #    000   000  000   000  000   000  000      
    #    000   000  0000000    000000000  000  0000
    #    000   000  000   000  000   000  000   000
    #    0000000    000   000  000   000   0000000 

    dragStartHandler: (event) ->
        view  = @renderViewForChild event.target
        node  = @nodeForView view
        img   = document.createElement 'div'
        clone = view.cloneNode(true)
        clone2 = view.cloneNode(true)

        img.style.position = 'absolute'
        img.style.left     = '0px'
        img.style.top      = '0px'
        img.style.width    = view.offsetWidth  + 'px'
        img.style.height   = (view.offsetHeight * 2 + 2) + 'px'
        img.style.zIndex   = '-1'

        clone.style.position = 'absolute'
        clone.style.left     = '0px'
        clone.style.top      = '0px'
        clone.style.width    = view.offsetWidth  + 'px'
        clone.style.height   = view.offsetHeight + 'px'

        clone2.style.position = 'absolute'
        clone2.style.left     = '0px'
        clone2.style.top      = '22px'
        clone2.style.width    = view.offsetWidth  + 'px'
        clone2.style.height   = view.offsetHeight + 'px'

        img.appendChild clone
        img.appendChild clone2
        document.body.appendChild img

        event.dataTransfer.setDragImage img, 0, 0
        event.dataTransfer.setData node.type, JSON.stringify(node.value)
        event.dataTransfer.effectAllowed = 'all'
        event.dataTransfer.dropEffect    = 'move'

        removeClone = () -> document.body.removeChild img
        setTimeout removeClone, 0

        console.log 'dragStartHandler: ', @id, event.dataTransfer.addElement
        @setCurrentDrag node
        null




    dragHandler: (event) ->
        null




    dragEndHandler: (event) ->
        node = @currentDrag
        console.log 'dragEndHandler: ', @id, node
        if @clone and @clone.parentElement
            document.body.removeChild @clone
        @setCurrentDrag null
        null




    #    0000000    00000000    0000000   00000000 
    #    000   000  000   000  000   000  000   000
    #    000   000  0000000    000   000  00000000 
    #    000   000  000   000  000   000  000      
    #    0000000    000   000   0000000   000      

    dragEnterHandler: (event) ->
        node = @nodeForView(event.target)
        console.log 'dragEnterHandler: ', @id, node?.name
        @setCurrentDrop node
        null





    dragOverHandler: (event) ->
        event.preventDefault()
        #node = @currentDrop
        if event.ctrlKey
            event.dataTransfer.dropEffect = 'link'
        else if event.altKey
            event.dataTransfer.dropEffect = 'copy'
        else
            event.dataTransfer.dropEffect = 'move'
        #console.log '!!!!!!!!!!!!!!!! dragOverHandler: ', @id, node
        null





    dragLeaveHandler: (event) ->
        node = @nodeForView(event.target)
        console.log 'dragLeaveHandler: ', @id, node
        @setCurrentDrop(null) if node == @currentDrop
        null





    dropHandler: (event) ->
        event.preventDefault()
        event.stopImmediatePropagation()

        node = @currentDrop

        transfer = event.dataTransfer
        data     = transfer.getData 'tree-data'
        console.log 'drop: ', @id, node
        console.log 'drop: -> ', @id, event.dataTransfer.getData(event.dataTransfer.items[0].type)
        event.dataTransfer.dropEffect = 'copy'

        @setCurrentDrop null
        null




module.exports = TreeDnDManager 
