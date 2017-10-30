



###

    infos:

        all array types
        all object types

        type A extends type B

        all instances for a type
        all values for a property

        all parents/places, a type is used (array child or object property)


        array type:



###


class Schema

    @fromData = (data) ->
        type = typeof data
        if not data and type == 'object'
            type = 'null'
        else if Array.isArray data
            type = 'array'
        schema = type: type
        switch type
            when 'string'  then return @fromStr  data, schema
            when 'number'  then return @fromNum  data, schema
            when 'boolean' then return @fromBool data, schema
            when 'object'  then return @fromObj  data, schema
            when 'array'   then return @fromArr  data, schema
            when 'null'    then return @fromNull schema
        null


    @fromStr = (str, schema = type: 'string') ->
        #console.log 'fromStr: ', str
        schema

    @fromNum = (num, schema = type: 'number') ->
        #console.log 'fromNum: ', num
        schema

    @fromBool = (bool, schema = type: 'boolean') ->
        #console.log 'fromBool: ', bool
        schema

    @fromObj = (obj, schema = type: 'object') ->
        #console.log 'fromObj: ', obj
        properties = schema.properties ?= {}
        for key, value of obj
            properties[key] = @fromData value
        schema


    @fromArr = (arr, schema = type: 'array') ->
        #console.log 'fromArr: ', arr
        items = schema.items = schema.items or []
        for value in arr
            item = @fromData value
            #TODO: check equal type
            items.push item
        schema


    @fromNull = (schema = {}) ->
        #console.log 'fromNull: '
        schema


    @defsFromData = (data, defs) ->





    constructor: (@instance) ->
        console.log 'schema created: ', @instance







class SchemaBuilder


    constructor: () ->
        @typeMap =
            arr:  []
            obj:  []
            str:  []
            num:  []
            int:  []
            bool: []
            null: []

        @types = [
            @typeMap.arr
            @typeMap.obj
            @typeMap.str
            @typeMap.num
            @typeMap.int
            @typeMap.bool
            @typeMap.null
        ]


    addData: (data) ->





module.exports = Schema