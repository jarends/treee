EventMap = require 'emap'


class TreeKeyManager


    constructor: (@treeView) ->
        @eventMap = new EventMap()
        @addListeners()




    addListeners: ->
        view = @treeView.view
        @eventMap.map view, 'keydown', @keyDownHandler, this
        @eventMap.map view, 'keyup',   @keyUpHandler,   this
        null




    dispose: ->
        @eventMap.unmapEvents()
        null




    keyDownHandler: (event) ->
        switch event.keyCode
            when 37 then @arrowLeft       event
            when 38 then @arrowUp         event
            when 39 then @arrowRight      event
            when 40 then @arrowDown       event
            when 32 then @toggleSelection event
        null




    keyUpHandler: (event) ->
        null




    arrowUp: (event) ->
        event.preventDefault()
        next = @treeView.flattener.getUp @treeView.selector.activeNode
        #console.log 'arrowUp', next
        if next
            @navigate next, event.metaKey, event.shiftKey
        else
            @navigate @treeView.flattener.getLast(), event.metaKey, event.shiftKey
        null




    arrowDown: (event) ->
        event.preventDefault()
        next = @treeView.flattener.getDown @treeView.selector.activeNode
        #console.log 'arrowDown', next
        if next
            @navigate next, event.metaKey, event.shiftKey
        else
            @navigate @treeView.flattener.getFirst(), event.metaKey, event.shiftKey
        null




    arrowLeft: (event) ->
        event.preventDefault()
        active = @treeView.selector.activeNode
        next   = @treeView.flattener.getUp active

        if active and active.expanded
            @treeView.flattener.collapse active, event.metaKey
        else if next
            @navigate next, event.metaKey, event.shiftKey
        null




    arrowRight: (event) ->
        event.preventDefault()
        active = @treeView.selector.activeNode
        next   = @treeView.flattener.getDown active

        if active and !active.expanded and active.children and active.children.length
            @treeView.flattener.expand active, event.metaKey
        else if next
            @navigate next, event.metaKey, event.shiftKey
        null




    navigate: (next, metaKey, shiftKey) ->
        selector = @treeView.selector

        if metaKey || shiftKey
            selector.selectByKey next, metaKey, shiftKey
        else if selector.selectedNodes.length == 1
            selector.select next
        else
            selector.setActive next

        @treeView.ensureNodeIsVisible next
        null




    toggleSelection: (event) ->
        @treeView.selector.toggleActive()
        event.preventDefault()
        event.stopImmediatePropagation()




module.exports = TreeKeyManager
