EMap      = require 'emap'
ViewNode  = require('two-trees').ViewNode
getBounds = require '../../core/geom/bounds'


class HResizer extends ViewNode


    startResize: (event) =>
        event.preventDefault()
        document.body.classList.add 'h-resize-global'
        @emap = @emap or new EMap()
        @emap.map document, "mousemove", @doResize,  @
        @emap.map document, "mouseup",   @endResize, @

        c     = @parent.children
        index = c.indexOf @
        @__   = []
        @_    = p: event.pageX

        for child, i in c
            if child instanceof HResizer
                @__.push {}
            else
                v = child.view
                s = v.style
                b = getBounds v
                @__.push
                    grow:    s.flexGrow
                    shrink:  s.flexShrink
                s.flexBasis  = b.width + 'px'
                s.flexGrow   = 0
                s.flexShrink = 0
                if i == index - 1
                    @_.vA  = v
                    @_.bA  = b
                    @_.msA = parseFloat(s.minWidth) or 0
                else if i == index + 1
                    @_.vB  = v
                    @_.bB  = b
                    @_.msB = parseFloat(s.minWidth) or 0
        @


    doResize: (event) ->
        event.preventDefault()
        d  = event.pageX - @_.p

        sA = @_.bA.width + d
        sB = @_.bB.width - d

        if sA < @_.msA
            d  = @_.msA - @_.bA.width
            sA = @_.msA
            sB = @_.bB.width - d

        else if sB < @_.msB
            d  = @_.bB.width - @_.msB
            sB = @_.msB
            sA = @_.bA.width + d

        @_.vA.style.flexBasis = sA + 'px'
        @_.vB.style.flexBasis = sB + 'px'
        @


    endResize: () ->
        document.body.classList.remove 'h-resize-global'
        @emap.unmap document, "mousemove", @doResize,  @
        @emap.unmap document, "mouseup",   @endResize, @

        for child, i in @parent.children
            if not (child instanceof HResizer)
                v = child.view
                s = v.style
                d = @__[i]
                s.flexGrow   = d.grow
                s.flexShrink = d.shrink
        @


    render: () ->
        tag:         'div'
        className:   'resizer h-resizer'
        onMousedown: @startResize


module.exports = HResizer