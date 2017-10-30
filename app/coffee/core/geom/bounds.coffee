Rect = require("./Rect")


bounds = (view, rect) ->
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


module.exports = bounds