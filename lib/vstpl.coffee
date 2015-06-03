###
# html模板构建函数模块
###

concat = require('concat-stream')
merge = require('merge').recursive
es = require('event-stream')
gutil = require('gulp-util')
path = require('path')
fs = require('fs')

_include = (options)->
    if typeof options is 'object'
        basepath = options.basepath or '@file'
        prefix = options.prefix or '@@'
        hashmap = options.hashmap
        context = options.context or {}
        staticPath = options.staticPath or {}
        filters = options.filters
    else 
        prefix = options or '@@'
        basepath = '@file'
        context = {}

    includeRegExp = 
        new RegExp(prefix + 'include\\s*\\([^)]*["\'](.*?)["\'](,\\s*({[\\s\\S]*?})){0,1}\\s*\\)+')

    ###utils###
    compose = (f, g)->
        return (x)->
            return f(g(x))

    stripCommentedIncludes = (content)->
        # remove single line html comments that use the format: <!-- @@include() -->
        regex = new RegExp('<\!--(.*)' + prefix + 'include([\\s\\S]*?)-->', 'g')
        return content.replace(regex, '')

    parseConditionalIncludes = (content, variables) ->
        # parse @@if (something) { include('...') }
        regexp = new RegExp(prefix + 'if.*\\{[^{}]*\\}\\s*')
        matches = regexp.exec(content)
        included = false

        ctx = merge(true, context)
        merge(ctx, variables)
        if not ctx.content
            ctx.content = content

        while (matches) 
            match = matches[0]
            includeContent = /\{([^{}]*)\}/.exec(match)[1]

            # jshint ignore: start
            exp = /if(.*)\{/.exec(match)[1]
            included = new Function('var context = this; with (context) { return ' + exp + ' }').call(ctx)
            
            # jshint ignore: end
            if included
                content = content.replace(match, includeContent)
            else 
                content = content.replace(match, '')

            matches = regexp.exec(content)

        return content


    applyFilters = (includeContent, match) ->
        # nothing to filter return unchanged
        return includeContent if match.match(/\)+$/)[0].length is 1
        # now get the ordered list of filters
        filterlist = match.split('(').slice(1, -1)
        filterlist = filterlist.map (str)->
            return filters[str.trim()]
        # compose them together into one function
        filter = filterlist.reduce(compose)
        # and apply the composed function to the stringified content
        return filter(String(includeContent))


    include = (file, text)->
        text = stripCommentedIncludes(text)
        variables = {}
        filebase = if basepath is '@file' then path.dirname(file.path) else (if basepath is '@root' then process.cwd() else basepath)
        matches = includeRegExp.exec(text)

        filebase = path.resolve(process.cwd(), filebase)

        # for checking if we are not including the current file again
        currentFilename = path.resolve(file.base, file.path)

        while matches
            match = matches[0]
            includePath = path.resolve(filebase, matches[1])

            if currentFilename.toLowerCase() is includePath.toLowerCase()
                throw new Error('recursion detected in file: ' + currentFilename)

            includeContent = fs.readFileSync(includePath)

            # strip utf-8 BOM  https:#github.com/joyent/node/issues/1918
            includeContent = includeContent.toString('utf-8').replace(/\uFEFF/, '')

            # need to double each `$` to escape it in the `replace` function
            includeContent = includeContent.replace(/\$/gi, '$$$$')

            # apply filters on include content
            if typeof filters is 'object'
                includeContent = applyFilters(includeContent, match)

            recMatches = includeRegExp.exec(includeContent)

            if recMatches && basepath is '@file'
                recFile = new gutil.File({
                    cwd: process.cwd(),
                    base: file.base,
                    path: includePath,
                    contents: new Buffer(includeContent)
                })
                recFile = include(recFile, includeContent)
                includeContent = String(recFile.contents)

            text = text.replace(match, includeContent)
            
            if matches[3] 
                # replace variables
                data = JSON.parse(matches[3])
                merge(variables, data)
                # grab keys & sort by longest keys 1st to iterate in that order
                keys = Object.keys(data).sort()
                                        .reverse()
            for i in keys
                key = keys[i]
                val = data[key]
                if hashmap[val] and hashmap[val] isnt ''
                    val = hashmap[val]
                text = text.replace(new RegExp(prefix + key, 'g'), val)

            matches = includeRegExp.exec(text)

        text = parseConditionalIncludes(text, variables)
        file.contents = new Buffer(text)
        return file

    fileInclude = (file)->
        self = this
        if file.isNull()
            self.emit('data', file)
        else if file.isStream()
            file.contents.pipe concat((data)->
                try
                    self.emit('data', include(file, String(data)))
                catch e
                    self.emit('error', new gutil.PluginError('include', e.message))
            )
        else if file.isBuffer()
            try
                file = include(file, String(file.contents))
                self.emit('data', file)
            catch e
                self.emit('error', new gutil.PluginError('include', e.message))

    return es.through(fileInclude)

module.exports = _include