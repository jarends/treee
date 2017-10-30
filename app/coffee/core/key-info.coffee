mods =
    Shift:   '⇧'
    Control: '^'
    Alt:     '⌥'
    Meta:    '⌘'
    Dead:    true


keyInfo = (event) ->
    shift  = event.shiftKey
    ctrl   = event.ctrlKey
    alt    = event.altKey
    cmd    = event.metaKey
    char   = ''
    mod    = ''

    if event instanceof KeyboardEvent
        key    = event.key
        isChar = key.length == 1 and not (ctrl or cmd)
        char   = key if isChar
        code   = event.code
        code   = if key.length == 1 and /^Key/.test(code) then code.slice(-1).toLowerCase() else code

    else if event instanceof MouseEvent
        key    = ''
        isChar = false
        code   = event.type


    if not mods[key] and not isChar
        mod += 'Shift+' if shift
        mod += 'Ctrl+'  if ctrl
        mod += 'Alt+'   if alt
        mod += 'Cmd+'   if cmd
        mod += code

    isChar: isChar
    char:   char
    isMod:  mod.length > 0
    mod:    mod
    key:    key
    code:   code
    shift:  shift
    ctrl:   ctrl
    alt:    alt
    cmd:    cmd
    event:  event


module.exports = keyInfo
