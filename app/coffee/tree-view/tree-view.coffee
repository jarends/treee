EventMap   = require 'emap'
Renderer   = require './tree-renderer'
Renderer2T = require './tree-renderer-2t'
Flattener  = require './tree-flattener'
NodeParser = require './tree-node-parser'
Selector   = require './tree-selector'
KeyManager = require './tree-key-manager'
DnDManager = require './tree-dnd-manager'
Dispatcher = require '../core/dispatcher'
Rect       = require '../core/geom/rect'
bounds     = require '../core/geom/bounds'


###
    000000000  00000000   00000000  00000000          000   000  000  00000000  000   000
       000     000   000  000       000               000   000  000  000       000 0 000
       000     0000000    0000000   0000000   000000   000 000   000  0000000   000000000
       000     000   000  000       000                  000     000  000       000   000
       000     000   000  00000000  00000000              0      000  00000000  00     00
###
class TreeView extends Dispatcher


    constructor: (@view) ->
        #console.log 'TreeView.constructor'
        @view          ?= document.createElement 'div'
        @contentView    = @view.querySelector('.tree-view-content')
        @eventMap       = new EventMap()
        @viewportRect   = new Rect()
        @contentRect    = new Rect()
        @bodyRecy       = new Rect()
        @renderers      = []
        @newRenderers   = []
        @cache          = []
        @rowHeight      = 20
        @rowGap         = 2
        @startIndex     = 0
        @endIndex       = 0
        @totalHeight    = 0
        @rhgh           = 0
        @drawTimeout    = null
        @scrollY        = NaN
        @flattener      = null
        @selector       = null
        @keyManager     = null
        @dndManager     = null
        @drawLaterCount = 0

        if not @contentView
             @contentView = document.createElement('div')
             @view.appendChild @contentView

        @contentView.style.width  = "100%"
        @contentView.style.height = "0px"
        @contentView.classList.add 'tree-view-content'

        @view.tabIndex = 0
        @view.classList.add 'tree-view'

        @eventMap.map window, 'resize', @draw, @
        @eventMap.map @view,  'scroll', @draw, @




    ###
        000  000   000  000  000000000
        000  0000  000  000     000
        000  000 0 000  000     000
        000  000  0000  000     000
        000  000   000  000     000
    ###
    init: (opt = {}) ->
        @rendererClass = opt.rendererClass or Renderer2T
        @flattener     = opt.flattener     or new Flattener  @
        @parser        = opt.parser        or new NodeParser @
        @selector      = opt.selector      or new Selector   @
        @keyManager    = opt.keyManager    or new KeyManager @
        @dndManager    = opt.dndManager    or new DnDManager @
        null




    ###
        0000000    00000000    0000000   000   000
        000   000  000   000  000   000  000 0 000
        000   000  0000000    000000000  000000000
        000   000  000   000  000   000  000   000
        0000000    000   000  000   000  00     00
    ###
    draw: ->
        @drawLaterCount = 0
        clearTimeout @drawTimeout
        if not isNaN(@scrollY) and @scrollY != @view.scrollTop
            @view.scrollTop = @scrollY
        @scrollY = NaN

        contentView = @contentView
        list        = @flattener.list
        l           = list.length
        vb          = bounds @view, @viewportRect
        cb          = bounds @contentView, @contentRect
        rh          = @rowHeight
        rg          = @rowGap
        ch          = cb.height
        cy          = vb.y - cb.y
        rhrg        = @rhrg        = rh + rg
        th          = @totalHeight = rhrg * l - rg
        startIndex  = @startIndex  = Math.max(Math.floor(cy / rhrg), 0)
        endIndex    = @endIndex    = Math.min(Math.floor((cy + vb.height) / rhrg), l - 1)
        renderers   = @newRenderers
        cache       = @renderers
        renderer    = null
        node        = null
        i           = NaN
        y           = NaN

        if l > 0
            for i in [startIndex .. endIndex]
                y        = i * rhrg
                node     = list[i]
                renderer = cache.shift()
                if not renderer
                    renderer = @cache.pop() || new @rendererClass @
                    contentView.appendChild renderer.view

                renderer.setData node
                renderer.view.style.top = y + "px"
                renderers.push renderer

        while cache.length
            renderer = cache.shift()
            contentView.removeChild renderer.view
            @cache.push renderer

        @renderers    = renderers
        @newRenderers = cache
        if(ch != th)
            @contentView.style.height = th + "px"
        null




    ###
        000   000   0000000   0000000    00000000        000   000  000   0000000  000  0000000    000      00000000
        0000  000  000   000  000   000  000             000   000  000  000       000  000   000  000      000
        000 0 000  000   000  000   000  0000000          000 000   000  0000000   000  0000000    000      0000000
        000  0000  000   000  000   000  000                000     000       000  000  000   000  000      000
        000   000   0000000   0000000    00000000            0      000  0000000   000  0000000    0000000  00000000
    ###
    ensureNodeIsVisible: (node) ->
        index = node.index
        if index == -1
            return

        vb    = @viewportRect
        rhrg  = @rhrg
        th    = @totalHeight
        nodeY = rhrg * index
        vh    = vb.height
        minY  = 0
        maxY  = -vh + th

        if index <= @startIndex + 1
            @scrollY = Math.max(Math.min(nodeY - rhrg, maxY), minY)
        else if index >= @endIndex - 1
            @scrollY = Math.max(Math.min(nodeY + 2 * rhrg - vh, maxY), minY)
        null




    ###
        000       0000000   000000000  00000000  00000000
        000      000   000     000     000       000   000
        000      000000000     000     0000000   0000000
        000      000   000     000     000       000   000
        0000000  000   000     000     00000000  000   000
    ###
    drawLater: ->
        if ++@drawLaterCount < 10
            clearTimeout @drawTimeout
            @drawTimeout = setTimeout () =>
                @draw()
        else
            @draw()
        null


module.exports = TreeView
