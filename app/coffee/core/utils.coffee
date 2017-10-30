_ = require 'lodash'


deepExtend = (target, source) ->
    for key, value of source
        if _.isObject(value) and not _.isArray(value)
            targetValue = target[key]
            if not _.isObject targetValue
                targetValue = {}
            target[key] = deepExtend targetValue, value
        else
            target[key] = value
    target


deepMerge = (target, sources...) ->
    for source in sources
        deepExtend target, source
    target




class Rect


    constructor: (@x = 0, @y = 0, @width = 0, @height = 0) ->


    set: (@x = 0, @y = 0, @width = 0, @height = 0) ->
        @


    hitTest: (x, y) ->
        r = @x + @width
        b = @y + @height
        x >= @x and x <= r and y >= @y and y <= b


    intersection: (rect) ->
        r0 = @x + @width
        b0 = @y + @height
        x  = rect.x
        y  = rect.y
        r1 = x + rect.width
        b1 = y + rect.height
        l = if @x > x  then @x else x
        r = if r0 > r1 then r0 else r1
        t = if @y > y  then @y else y
        b = if b0 > b1 then b0 else b1

        return 0 if l > r or t > b
        (r - l) * (b - t)


    percent: (rect) ->
        @intersection(rect) / (@width * @height)




getBounds = (view, rect) ->
    vr = view.getBoundingClientRect()
    br = document.body.getBoundingClientRect()
    l  = vr.left - br.left
    t  = vr.top  - br.top
    w  = vr.width
    h  = vr.height

    if not rect
        rect = new Rect(l, t, w, h)
    else
        rect.set(l, t, w, h)
    rect





size = (view, width, height) ->
    view.style.width  = width  + 'px'
    view.style.height = height + 'px'




position = (view, x, y) ->
    view.style.left = x + 'px';
    view.style.top  = y + 'px';




transform = (view, x, y, angle, scale) ->
    setTransform(view.style, "translate(#{x}px,#{y}px) rotate(#{angle}deg) scale(#{scale})");




translate = (view, x, y) ->
    setTransform(view.style, "translate(#{x}px,#{y}px)");




rotate = (view, angle) ->
    setTransform(view.style, "rotate(#{angle}deg)");




scale = (view, scale) ->
    setTransform(view.style, "scale(#{scale})");




setTransform = (style, transform) ->
    style.webkitTransform = transform;
    style.transform       = transform;




cloneCanvas = (canvas) ->
    newCanvas        = document.createElement 'canvas'
    context          = newCanvas.getContext '2d'
    newCanvas.width  = canvas.width
    newCanvas.height = canvas.height

    context.drawImage canvas, 0, 0
    return newCanvas;




module.exports =
    _:            _
    deepExtend:   deepExtend
    deepMerge:    deepMerge
    Rect:         Rect
    getBounds:    getBounds
    size:         size
    position:     position
    transform:    transform
    translate:    translate
    rotate:       rotate
    scale:        scale
    setTramsform: setTransform
    cloneCanvas:  cloneCanvas