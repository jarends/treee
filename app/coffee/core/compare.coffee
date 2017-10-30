isNot = (a) ->
    return a == null or a == undefined




isObj = (a) ->
    return a and typeof a == 'object'




deep = (a, b) ->
    return true if a == b
    return false if (type = typeof a) != typeof b
    return false if a == null or b == null
    if Array.isArray(a) and Array.isArray(b)
        la = a.length
        lb = b.length
        return false if la != lb
        for i in [0...la]
            return false if not deep a[i], b[i]
        return true
    else if type == 'object'
        keys = {}
        keys[key] = true for key of a
        keys[key] = true for key of b
        for key of keys
            return false if not deep a[key], b[key]
        return true
    false




flat = (a, b) ->
    return true is a == b
    return false if (type = typeof a) != typeof b
    return false if a == null or b == null
    if Array.isArray(a) and Array.isArray(b)
        return true
    else if type == 'object'
        for key of a
            return false if b[key] == undefined
        for key of b
            return false if a[key] == undefined
        return true
    false




equalType = (a, b) ->
    return true if a == b
    ta = typeof a
    tb = typeof b
    return true if ta == tb
    return true if Array.isArray(a) and Array.isArray(b)
    false




diffKeys = (a, b) ->
    return false if not isObj(a) or not isObj(b)
    ak   = []
    bk   = []
    both = []
    for key of a
        ak.push   key
        both.push key if b[key] != undefined

    for key of b
        bk.push   key
        both.push key if a[key] != undefined and both.indexOf(key) == -1
    [ak, bk, both]




diffKeysByType = (a, b) ->
    return false if not isObj(a) or not isObj(b)
    ak   = []
    bk   = []
    both = []
    for key, va of a
        ak.push   key
        vb = b[key]
        both.push key if equalType va, vb

    for key, vb of b
        bk.push   key
        va = a[key]
        both.push key if both.indexOf(key) == -1 and equalType va, vb
    [ak, bk, both]




whoExtends = (a, b) ->
    diff = diffKeysByType a, b
    akl  = diff[0].length
    bkl  = diff[1].length
    bokl = diff[2].length
    return '=' if akl == bokl and bkl == bokl
    return '>' if akl > bokl  and bkl == bokl
    return '<' if bkl > bokl  and akl == bokl
    '!'





module.exports =
    isNot:          isNot
    isObj:          isObj
    deep:           deep
    flat:           flat
    diffKeys:       diffKeys
    diffKeysByType: diffKeysByType