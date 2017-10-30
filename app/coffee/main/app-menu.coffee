electron = require 'electron'
app      = electron.app
Menu     = electron.Menu
Dialog   = electron.dialog


class AppMenu


    constructor: (@ctx) ->
        @init()


    init: () ->

        Menu.setApplicationMenu Menu.buildFromTemplate [

            id: 'treee'
            label: 'treee'
            submenu: [
                label:       'About treee'
                id:          'about'
                accelerator: 'Cmd+.'
                click:       @onClick
            ,
                type: 'separator'
            ,
                label:       'Hide treee'
                id:          'hide'
                accelerator: 'Cmd+h'
                role:        'hide'
            ,
                label:       'Hide Others'
                id:          'hide-others'
                accelerator: 'Alt+Cmd+h'
                role:        'hideothers'
            ,
                type: 'separator'
            ,
                label:       'Toggle Dev-Tools'
                id:          'toggle-dev-tools'
                accelerator: 'Alt+Cmd+i'
                click:       @onClick
            ,
                label:       'Reload'
                id:          'reload'
                accelerator: 'Cmd+r'
                click:       @onClick
            ,
                type: 'separator'
            ,
                label:       'Quit'
                id:          'quit'
                accelerator: 'Cmd+q'
                click:       @onClick
            ]
        ,
            id: 'file'
            label: 'File'
            submenu: [
                label:       'Open File'
                id:          'open-file'
                accelerator: 'Cmd+o'
                click:       @onClick
            ,
                type: 'separator'
            ]
        ]


    showAddFolderDialog: () ->
        opts =
            title:       'add folder'
            defaultPath: @ctx.store.get 'lastFolderPath'
            properties: [
                'openDirectory'
                'showHiddenFiles'
            ]

        Dialog.showOpenDialog opts, (filePaths) =>
            if filePaths
                path = filePaths[0]
                @ctx.folders.addFolder path
                @ctx.store.set 'lastFolderPath', path
        null




    onClick: (item, win) =>
        console.log 'menu item clicked: ', item.id
        switch item.id
            when 'reload'           then win.webContents.reloadIgnoringCache()
            when 'toggle-dev-tools' then win.webContents.toggleDevTools()
            when 'quit'             then app.quit()
            when 'add-folder'       then @showAddFolderDialog()
            when 'open-file'        then console.log 'open file'


module.exports = AppMenu
