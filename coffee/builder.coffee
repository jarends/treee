Path   = require 'path'
CSpawn = require 'cross-spawn'
CWD    = Path.resolve __dirname, '..'
task   = process.argv[2] or 'run'


class Builder


    constructor: () ->
        @inDir     = Path.join CWD, 'app'
        @outDir    = Path.join CWD, 'build'
        @pkg       = require Path.join(@inDir, 'package.json')
        @name      = @pkg.name
        @version   = @pkg.version
        @eVersion  = @pkg.electron_version or '1.6.4'
        @bundleId  = 'org.netTrek.' + @name
        @electron  = Path.join CWD, 'node_modules', 'electron', 'cli.js'
        @packager  = Path.join CWD, 'node_modules', 'electron-packager', 'cli.js'
        @options   =
            stdio: 'inherit'
            cwd:   CWD


    run: () ->
        @options.stdio = 'inherit'
        CSpawn.sync 'node', [@electron, @inDir], @options
        null


    open: () ->
        dir = @name + '-darwin-x64'
        app = @name + '.app'
        @options.stdio = 'inherit'
        CSpawn.sync 'open', [Path.join @outDir, dir, app], @options
        null


    build: (platform, arch) ->
        args = [
            @packager
            'app'
            @name
            "build-with-native-modules"
            "--overwrite"
            "--platform="         + platform
            "--arch="             + arch
            "--electron-version=" + @eVersion
            "--app-version="      + @version
            "--app-bundle-id="    + @bundleId
            "--icon="             + Path.join @inDir, 'img/icon.icns'
            "--out="              + @outDir
        ]
        @options.stdio = 'inherit'
        CSpawn.sync 'node', args, @options
        null


    buildMac: () ->
        @build 'darwin', 'x64'
        null


    buildWin32: () ->
        @build 'win32',  'ia32'
        null


    buildWin64: () ->
        @build 'win32',  'x64'
        null


    buildWin: () ->
        @buildWin32()
        @buildWin64()
        null


    buildAll: () ->
        @buildMac()
        @buildWin()
        null


    createIcons: () ->
        try
            @options.stdio = null
            CSpawn.sync './bin/create-icons.sh', [], @options
        catch e
            console.log 'error while creating icons: ', e
        null


    install: () ->
        try
            @options.stdio = 'inherit'
            CSpawn.sync './bin/install.sh', [@name], @options
        catch e
            console.log 'error while installing the app: ', e
        null


    launch: () ->
        try
            @options.stdio = null
            CSpawn.sync 'killall', [@name], @options
            CSpawn.sync 'killall', [@name], @options
            CSpawn.sync 'open', ['/Applications/' + @name + '.app'], @options
        catch e
            console.log 'error while installing the app: ', e
        null


    distribute: () ->
        @createIcons()
        @buildMac()
        @install()
        null




    printHelp: () ->
        console.log """usage:
run          (r)   - run app from project folder, same as: node .
open         (o)   - open app from build folder
mac          (m)   - build for mac
win          (w)   - build win32 and win64
win32        (w32) - build win32
win64        (w64) - build win64
all          (a)   - build all platforms
install      (i)   - install and launch app from application folder
launch       (l)   - launch app from application folder
distribute   (d)   - build for mac, install, kill  and launch
help         (h)   - show this help text"""
        null




builder = new Builder()




switch task
    when 'run'         , 'r'   then builder.run()
    when 'open'        , 'o'   then builder.open()
    when 'install'     , 'i'   then builder.install()
    when 'launch'      , 'l'   then builder.launch()
    when 'mac'         , 'm'   then builder.buildMac()
    when 'win'         , 'w'   then builder.buildWin()
    when 'win32'       , 'w32' then builder.buildWin32()
    when 'win64'       , 'w64' then builder.buildWin64()
    when 'all'         , 'a'   then builder.buildAll()
    when 'create-icons', 'ci'  then builder.createIcons()
    when 'distribute'  , 'd'   then builder.distribute()
    when 'help'        , 'h'   then builder.printHelp()
    else
        console.log "\nunknown task \"#{task}\"\n"
        builder.printHelp()