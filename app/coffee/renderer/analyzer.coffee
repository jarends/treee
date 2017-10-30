_ = require '../core/compare'


class Analyzer


    constructor: (jsons) ->
        @files    = {}
        @schemas  = {}
        @state    = schemaId: 0
        @classes  =
            all:  {}
            base: {}

        @types =
            null:    []
            boolean: []
            number:  []
            string:  []
            object:  []
            array:   []

        @result =
            state:   @state
            files:   @files
            schemas: @schemas
            types:   @types

        if jsons
            for data in jsons
                @addJson data.json, data.path if data.json
            @updateInheritance()
            @parseArrays()




    fromResult: (@result) ->
        @state   = @result.state
        @files   = @result.files
        @schemas = @result.schemas
        @types   = @result.types
        @




    addJson: (json, path) ->
        schema       = @parse json
        schema.path  = path
        @files[path] = schema.id
        schema




    getInheritanceTree: () ->
        has       = {}
        duplicate = {}
        children  = []
        root      =
            label:     'base'
            duplicate: duplicate
            children:  children

        getC = (id) =>
            s = @schemas[id]
            c = []
            for cid in s.diff.byKeys.extends
                cs     = @schemas[cid]
                exists = false
                for eid in cs.diff.byKeys.equal
                    break if exists = c.indexOf(eid) > -1
                if not exists
                    if not has[cid]
                        has[cid] = true
                        c.push
                            label:    's' + cid
                            children: getC cid
                    else
                        duplicate[cid] = true
                        console.log 'duplicate: ', cid
            c

        for id in @result.base.byKeys
            has[id] = true
            children.push @schemas[id]
            #label:    's' + id
            #children: getC id
        root




    createClasses: () ->
        all = {}
        bas = {}
        @classes = @result.classes = classes =
            all:  all
            base: base

        setClass = (id, ids) ->
            for iid in ids



        for id in @result.base.byKeys
            has[id] = true
            base = @schemas[id]
            setClass(id)




    parse: (value, name, parent) ->
        id     = ++@state.schemaId
        type   = typeof value
        schema =
            id:      id
            type:    type
            default: value
            parent:  parent?.id
            name:    name

        if not value and type == 'object'
            type = schema.type = 'null'

        else if Array.isArray value
            type = schema.type = 'array'
            @parseArray schema

        else if type == 'object'
            @parseObject schema

        @types[type].push id
        @schemas[id] = schema
        schema




    parseObject: (schema) ->
        props        = schema.properties = {}
        obj          = schema.default
        schema.clazz = NaN
        schema.diff  =
            byType:
                equal:    []
                extends:  []
                extended: []
                mixed:    []
                sameName: []
            byKeys:
                equal:    []
                extends:  []
                extended: []
                mixed:    []
                sameName: []

        for key, value of obj
            prop = @parse value, key, schema
            props[key] = prop.id

        objs = @types.object
        a    = schema
        for oid in objs
            b = @schemas[oid]

            d  = _.diffKeysByType a.default, b.default
            ad = a.diff.byType
            bd = b.diff.byType
            akl  = d[0].length
            bkl  = d[1].length
            bokl = d[2].length
            if akl == bokl and bkl == bokl
                ad.equal.push b.id
                bd.equal.push a.id

            else if akl > bokl and bkl == bokl
                ad.extends.push b.id
                bd.extended.push a.id

            else if bkl > bokl and akl == bokl
                ad.extended.push b.id
                bd.extends.push a.id
            else if bokl > 0
                ad.mixed.push
                    id:   b.id
                    diff: bokl
                bd.mixed.push
                    id:   a.id
                    diff: bokl

            if a.name == b.name
                ad.sameName.push b.id
                bd.sameName.push a.id


            d  = _.diffKeys a.default, b.default
            ad = a.diff.byKeys
            bd = b.diff.byKeys
            akl  = d[0].length
            bkl  = d[1].length
            bokl = d[2].length
            if akl == bokl and bkl == bokl
                ad.equal.push b.id
                bd.equal.push a.id

            else if akl > bokl and bkl == bokl
                ad.extends.push b.id
                bd.extended.push a.id

            else if bkl > bokl and akl == bokl
                ad.extended.push b.id
                bd.extends.push a.id
            else if bokl > 0
                ad.mixed.push
                    id:   b.id
                    diff: bokl
                bd.mixed.push
                    id:   a.id
                    diff: bokl

            if a.name == b.name
                ad.sameName.push b.id
                bd.sameName.push a.id

        schema




    parseArray: (schema) ->
        arr   = schema.default
        items = schema.items = []
        types = schema.types =
            null:    []
            boolean: []
            number:  []
            string:  []
            object:  []
            array:   []

        for value, i in arr
            item = @parse(value, i, schema)
            items.push item.id
            types[item.type].push item.id
        schema




    updateInheritance: () ->
        unique = @result.unique =
            byType: []
            byKeys: []

        base = @result.base =
            byType: []
            byKeys: []

        objs = @types.object
        for id in objs
            s = @schemas[id]

            d = s.diff.byType
            u = unique.byType
            b = base.byType
            if d.extended.length == 0
                exists = false
                if d.equal.length > 0
                    for eid in d.equal
                        break if exists = u.indexOf(eid) > -1
                u.push id if not exists

            if d.extends.length == 0
                exists = false
                if d.equal.length > 0
                    for eid in d.equal
                        break if exists = b.indexOf(eid) > -1
                b.push id if not exists

            d = s.diff.byKeys
            u = unique.byKeys
            b = base.byKeys
            if d.extended.length == 0
                exists = false
                if d.equal.length > 0
                    for eid in d.equal
                        break if exists = u.indexOf(eid) > -1
                u.push id if not exists

            if d.extends.length == 0
                exists = false
                if d.equal.length > 0
                    for eid in d.equal
                        break if exists = b.indexOf(eid) > -1
                b.push id if not exists

        @result.baseInheritance = @getInheritanceTree()
        @result




    parseArrays: () ->





module.exports = Analyzer