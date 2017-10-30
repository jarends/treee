d3           = require 'd3'
EMap         = require 'emap'
ViewNode     = require('two-trees').ViewNode
events       = require '../events'




DATA =
    name: 'root'
    children: [
        name: 'child 0'
        children:[
            name: 'child 0.0'
        ,
            name: 'child 0.1'
        ]
    ,
        name: 'child 1'
        children:[
            name: 'child 1.0'
        ,
            name: 'child 1.1'
        ]
    ]





#    000000000  00000000   00000000  00000000
#       000     000   000  000       000
#       000     0000000    0000000   0000000
#       000     000   000  000       000
#       000     000   000  00000000  00000000

class DeptsTree extends ViewNode


    constructor: (cfg) ->
        super cfg
        @index = 0
        @emap  = new EMap()
        @emap.map @ctx, events.ANALYZE_CHANGED, @updateData, @


    onMount: () ->
        @vw = 800
        @vh = 600

        @duration = 500
        @tree     = d3.tree().size [@vh, @vw]
        @svg      = d3.select(@view).append 'svg'
            .attr 'width',  @vw
            .attr 'height', @vh


    onUnmount: () =>
        @svg.remove()


    updateData: () ->
        @root     = d3.hierarchy DATA #@ctx.analyzer.result.baseInheritance
        @root.x0  = @vh / 2;
        @root.y0  = 50;
        @updateTree @root


    updateTree: (source) ->
        # Creates a curved (diagonal) path from parent to the child nodes
        diagonal = (s, d) ->
            """M #{s.y} #{s.x} C #{(s.y + d.y) / 2} #{s.x}, #{(s.y + d.y) / 2} #{d.x}, #{d.y} #{d.x}"""

        # Toggle children on click.
        click = (d) =>
            if d.children
                d._children = d.children
                d.children = null
            else
                d.children = d._children
                d._children = null
            @updateTree d

        # Compute the new tree layout.
        data  = @tree @root
        nodes = data.descendants()
        links = data.descendants().slice 1

        # Normalize for fixed-depth.
        nodes.forEach (d) -> d.y = d.depth * 120 + 50


        # Update the nodes...
        node = @svg.selectAll 'g.node'
            .data nodes, (d) => d.id or (d.id = ++@index)

        # Node Enter
        nodeEnter = node.enter().append 'g'
            .attr 'class', 'node'
            .attr 'transform', (d) -> 'translate(' + source.y0 + ',' + source.x0 + ')'

        # Circle Enter
        nodeEnter.append 'circle'
            .attr  'class', 'node'
            .attr  'r', 1e-6
            .style 'fill', (d) -> if d._children then 'lightsteelblue' else '#fff'
            .on    'click', click

        # Label Enter
        nodeEnter.append 'text'
            .attr 'class', 'node'
            .attr 'dy', '.35em'
            .attr 'x', (d) -> if d.children or d._children then -13 else 13
            .attr 'text-anchor', (d) -> if d.children or d._children then 'end' else 'start'
            .style 'fill-opacity', 1e-6
            .text (d) -> d.data.name
            .transition()
            .duration @duration
            .style 'fill-opacity', 1


        # UPDATE
        nodeUpdate = nodeEnter.merge node

        # Transition to the proper position for the node
        nodeUpdate.transition()
            .duration @duration
            .attr 'transform', (d) -> 'translate(' + d.y + ',' + d.x + ')'

        # Update the node attributes and style
        nodeUpdate.select 'circle.node'
            .style 'fill', (d) -> if d._children then '#67f' else '#fff'
            .attr 'cursor', 'pointer'
            .transition()
            .duration @duration
            .attr 'r', 10

        # Update the text
        nodeUpdate.select 'text.node'
            .transition()
            .duration @duration
            .style 'fill-opacity', 1



        # Exit
        nodeExit = node.exit().transition()
            .duration @duration
            .attr 'transform', (d) -> 'translate(' + source.y + ',' + source.x + ')'
            .remove()

        # On exit reduce the node circles size to 0
        nodeExit.select 'circle'
            .attr 'r', 1e-6

        # On exit reduce the opacity of text labels
        nodeExit.select 'text'
            .style 'fill-opacity', 1e-6




        # Update the links...
        link = @svg.selectAll 'path.link'
            .data links, (d) -> d.id

        # Enter any new links at the parent's previous position.
        linkEnter = link.enter().insert 'path', 'g'
            .attr 'class', 'link'
            .attr 'd', (d) ->
                o = x: source.x0, y: source.y0
                diagonal o, o

        # UPDATE
        linkUpdate = linkEnter.merge link

        # Transition back to the parent element position
        linkUpdate.transition()
            .duration @duration
            .attr 'd', (d) -> diagonal d, d.parent

        # Remove any exiting links
        linkExit = link.exit().transition()
            .duration @duration
            .attr 'd', (d) ->
                o = x: source.x, y: source.y
                diagonal o, o
            .remove()

        # Store the old positions for transition.
        nodes.forEach (d) ->
            d.x0 = d.x
            d.y0 = d.y
    @




    render: () ->
        @cfg.tag = 'div'
        @cfg


module.exports = DeptsTree



