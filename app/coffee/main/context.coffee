Path          = require 'path'
electron      = require 'electron'
EventMap      = require 'emap'
Post          = require 'ppost'
AppMenu       = require './app-menu'
Store         = require '../core/store'
utils         = require '../core/utils'
BrowserWindow = electron.BrowserWindow
app           = electron.app
deepExtend    = utils.deepExtend




class Context


    constructor: () ->


        @HOME       = app.getPath 'home'
        @APP_FOLDER = Path.join __dirname, '../../'
        @APP_DATA   = Path.join app.getPath('userData'), 'data.json'
        @NAME       = app.getName()
        @PKG_JSON   = require Path.join @APP_FOLDER, 'package.json'


        @DEFAULT_PROPS =
            win:
                x:               0
                y:               0
                width:           800
                height:          600
                backgroundColor: '#000000'

            lastFolderPath: @HOME
            recentFiles:    []


        @emap = new EventMap()
        @emap.map app,     'ready',             @onReady,    @
        @emap.map app,     'window-all-closed', @onClose,    @
        @emap.map app,     'activate',          @onActivate, @
        @emap.map app,     'quit',              @onQuit,     @
        #@emap.map process, 'exit',              @terminate,  @
        #@emap.map process, 'SIGINT',            @terminate,  @
        #@emap.map process, 'SIGTERM',           @terminate,  @




    init: () ->
        @store = new Store   @, @APP_DATA, @DEFAULT_PROPS
        @menu  = new AppMenu @

        @createWin()
        null




    createWin: () ->
        opts      = deepExtend {}, @store.data.win
        opts.show = false
        @mainWin  = new BrowserWindow(opts)

        @emap.map @mainWin, 'ready-to-show', @onWinReadyToShow, @
        @emap.map @mainWin, 'closed',        @onWinClosed,      @
        @emap.map @mainWin, 'resize',        @onWinChanged,     @
        @emap.map @mainWin, 'move',          @onWinChanged,     @

        @mainWin.loadURL 'file://' + Path.join(__dirname, '../../index.html')
        #@startTicker()
        null


    startTicker: () ->
        tick = () ->
            clearTimeout @timeout
            setTimeout tick, (1000 / 30) >> 0
        clearTimeout @timeout
        tick()
        @


    onReady: () ->
        console.log 'Main.onReady'
        @init()
        null


    onWinChanged: () ->
        deepExtend @store.data.win, @mainWin.getBounds()
        @store.update()
        null


    onWinReadyToShow: () ->
        console.log 'Main.onWinReadyToShow'
        @mainWin.show()
        null


    onWinClosed: () ->
        console.log 'Main.onWinClosed'
        @emap.unmap @mainWin, 'ready-to-show', @onWinReadyToShow, @
        @emap.unmap @mainWin, 'closed',        @onWinClosed,      @
        @emap.unmap @mainWin, 'resize',        @onWinChanged,     @
        @emap.unmap @mainWin, 'move',          @onWinChanged,     @
        @mainWin = null
        null


    onActivate: () ->
        console.log 'Main.onActivate'
        if @mainWin == null
            @createWin()
        null


    onClose: () ->
        console.log 'Main.onClose'
        if process.platform != 'darwin'
            app.quit()
        null


    onQuit: () ->
        console.log 'Main.onQuit'
        #Post.toAll 'quit'
        null


    terminate: () ->
        console.log 'Main.terminate'
        null




module.exports = new Context()