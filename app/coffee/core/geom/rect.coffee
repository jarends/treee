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


module.exports = Rect
