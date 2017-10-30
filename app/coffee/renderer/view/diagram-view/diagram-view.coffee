ViewNode = require('two-trees').ViewNode


class DiagramView extends ViewNode


    updateCfg: (cfg) ->
        super cfg


    onMount: () =>
        console.log 'onMount: ', @


    render: () ->
        @cfg.tag = 'div'
        @cfg


module.exports = DiagramView