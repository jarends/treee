ViewNode = require('two-trees').ViewNode
FileView = require './file-view'
HResizer = require './h-resizer'
VResizer = require './v-resizer'



getRow = (style = '') ->
    tag:       'div'
    className: 'row'
    style:     style
    children: [
        tag:       FileView
        className: 'panel'
        style:     'flex: 0 0 300px; min-width: 200px;'
    ,
        tag:       HResizer
    ,
        tag:       FileView
        className: 'panel'
        style:     'flex: 1 1 0px;'
    ,
        tag:       HResizer
    ,
        tag:       'div'
        className: 'panel'
        style:     'flex: 1 1 0px;'
        child:     tag: 'iframe'
    ,
        tag:       HResizer
    ,
        tag:       FileView
        className: 'panel'
        style:     'flex: 1 1 0px; min-width: 40px;'
    ,
        tag:       HResizer
    ,
        tag:       FileView
        className: 'panel'
        style:     'flex: 0 0 120px; min-width: 80px;'
    ]


getCol: () ->
    tag:       'div'
    className: 'col'
    children: [
        getRow 'flex: 0 0 300px; min-height: 200px;'
        tag: VResizer
        getRow 'flex: 1 1 0px;'
        tag: VResizer
        getRow 'flex: 0 0 120px; min-height: 80px;'
    ]



class AppView extends ViewNode


    render: () ->
        tag:       'div'
        className: 'window'
        ###
        children: [
            tag:       'div'
            className: 'toolbar'
        ,
            tag:       'div'
            className: 'content'
            child:     getRow()

        ]
        ###
        child:
            tag: FileView
            className: 'panel'
            style: 'width: 100%; height: 100%;'

module.exports = AppView