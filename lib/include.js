/*
 * 修改自 gulp-file-include 模块
 */

'use strict';

var concat = require('concat-stream'),
    merge = require('merge').recursive,
    es = require('event-stream'),
    gutil = require('gulp-util'),
    path = require('path'),
    fs = require('fs'),
    _ = require('lodash'),
    config = require('./config');

module.exports = function(options) {

    var prefix, basepath, filters, hashmap,context;
    
    if (typeof options === 'object') {
        basepath = options.basepath || '@file';
        prefix = options.prefix || '@@';
        hashmap = options.hashmap;
        context = options.context || {};
        filters = options.filters;
    } else {
        prefix = options || '@@';
        basepath = '@file';
        context = {};
    }
    // console.log(hashmap);
    var env = config.env;
    var isDebug = config.isDebug;
    var staticRoot = config.staticRoot;
    var staticPath = config.staticPath;
    var js_path = config.jsPath;
    var css_path = config.cssPath;
    var hashLen = config.hashLength;
    var includeRegExp = new RegExp(prefix + 'include\\s*\\([^)]*["\'](.*?)["\'](,\\s*({[\\s\\S]*?})){0,1}\\s*\\)+');

    function fileInclude(file) {
        var self = this;

        if (file.isNull()) {
            self.emit('data', file);
        } else if (file.isStream()) {
            file.contents.pipe(concat(function(data) {
                try {
                    self.emit('data', include(file, String(data)));
                } catch (e) {
                    self.emit('error', new gutil.PluginError('gulp-file-include', e.message));
                }
            }));
        } else if (file.isBuffer()) {
            try {
                file = include(file, String(file.contents));
                self.emit('data', file);
            } catch (e) {
                self.emit('error', new gutil.PluginError('gulp-file-include', e.message));
            }
        }
    }

    return es.through(fileInclude);

    /**
     * utils
     */
    function stripCommentedIncludes(content) {
        // remove single line html comments that use the format: <!-- @@include() -->
        var regex = new RegExp('<\!--(.*)' + prefix + 'include([\\s\\S]*?)-->', 'g');
        return content.replace(regex, '');
    }

    function parseConditionalIncludes(content, variables) {
        // parse @@if (something) { include('...') }
        var regexp = new RegExp(prefix + 'if.*\\{[^{}]*\\}\\s*'),
            matches = regexp.exec(content),
            included = false;

        var ctx = merge(true, context);
        merge(ctx, variables);
        if (!ctx.content) ctx.content = content;

        while (matches) {
            var match = matches[0],
                includeContent = /\{([^{}]*)\}/.exec(match)[1];

            // jshint ignore: start
            var exp = /if(.*)\{/.exec(match)[1];
            included = new Function('var context = this; with (context) { return ' + exp + '; }').call(ctx);
            // jshint ignore: end

            if (included) {
                content = content.replace(match, includeContent);
            } else {
                content = content.replace(match, '');
            }

            matches = regexp.exec(content);
        }

        return content;
    }

    function setLinks(type, str) {
        var _str = type === 'js' ? '<script>' + config.GLOBALVAR + '</script>' : '';
        var tempArr = str.split(',');
        var cacheStr = String(new Date().getTime()).substr(0, hashLen);
        var _val, _name, _hash;
        var _requireStr = "";
        for (var i = 0; i < tempArr.length; i++) {
            if (type.indexOf('css') === 0) {
                _val = tempArr[i] + ".css";
                if(_.has(hashmap, _val) && env !== 'local'){
                    _hash = hashmap[_val]['hash'].substr(0, hashLen);
                    _name = !isDebug ? hashmap[_val].distname : _val + "?v=" + _hash;
                }else{
                    _name = _val + "?v=" + cacheStr;
                }
                _str += '<link href="' + css_path + _name + '" rel="stylesheet" type="text/css">' + '\n';
            } else if (type.indexOf('js') === 0) {
                if (env === 'local' && !isDebug && type === 'js') {
                    if (tempArr[i] === config.coreJsName) {
                        _str += '<script src="' + js_path + 'vendor/require/require.js?_v2.4"></script>' + '\n';
                        _str += '<script src="' + js_path + 'vendor/jquery/jquery.js?_v2.4"></script>' + '\n';
                        _str += '<script src="' + js_path + 'require_cfg.js?v=' + cacheStr + '"></script>' + '\n';
                    } else {
                        _requireStr += 'require(["' + tempArr[i].replace(config.prefix, '').replace(/_/g, '/') + '"]);';
                        _str += '<script>' + _requireStr + '</script>';
                    }
                } else {
                    _val = tempArr[i] + ".js";
                    if(_.has(hashmap, _val) && env !== 'local'){
                        _name = !isDebug ? hashmap[_val].distname : _val + "?v=" + hashmap[_val]['hash'].substr(0, hashLen);
                    }else{
                        _name = _val + "?v=" + cacheStr;
                    }
                     _str += '<script src="' + js_path + _name + '" id="' + tempArr[i].replace(config.prefix, '') + '"></script>' + '\n';
                }
            }
        };
        return _str;
    }

    function include(file, text) {
        text = stripCommentedIncludes(text);
        var variables = {};
        // console.log(staticPaths);

        var filebase = basepath === '@file' ? path.dirname(file.path) : basepath === '@root' ? process.cwd() : basepath;
        var matches = includeRegExp.exec(text);

        filebase = path.resolve(process.cwd(), filebase);

        // for checking if we are not including the current file again
        var currentFilename = path.resolve(file.base, file.path);

        while (matches) {
            var match = matches[0];
            var includePath = path.resolve(filebase, matches[1]);

            if (currentFilename.toLowerCase() === includePath.toLowerCase()) {
                throw new Error('recursion detected in file: ' + currentFilename);
            }

            var includeContent = fs.readFileSync(includePath);

            // strip utf-8 BOM  https://github.com/joyent/node/issues/1918
            includeContent = includeContent.toString('utf-8').replace(/\uFEFF/, '');

            // need to double each `$` to escape it in the `replace` function
            includeContent = includeContent.replace(/\$/gi, '$$$$');

            // apply filters on include content
            if (typeof filters === 'object') {
                includeContent = applyFilters(includeContent, match);
            }

            var recMatches = includeRegExp.exec(includeContent);
            if (recMatches && basepath == '@file') {
                var recFile = new gutil.File({
                    cwd: process.cwd(),
                    base: file.base,
                    path: includePath,
                    contents: new Buffer(includeContent)
                });
                recFile = include(recFile, includeContent);
                includeContent = String(recFile.contents);
            }

            text = text.replace(match, includeContent);

            if (matches[3]) {
                // replace variables
                var data = JSON.parse(matches[3]);
                merge(variables, data);
                // grab keys & sort by longest keys 1st to iterate in that order
                var keys = Object.keys(data).sort().reverse();
                for (var i = 0; i < keys.length; i++) {
                    var key = keys[i];
                    var val = data[key];
                    var links = (val === "") ? val : setLinks(key, val);
                    text = text.replace(new RegExp(prefix + key, 'g'), links ? links : val);
                }
            }

            matches = includeRegExp.exec(text);
        }

        text = parseConditionalIncludes(text, variables);

        file.contents = new Buffer(text);
        return file;
    }

    function applyFilters(includeContent, match) {
        if (match.match(/\)+$/)[0].length === 1) {
            // nothing to filter return unchanged
            return includeContent;
        }

        // now get the ordered list of filters
        var filterlist = match.split('(').slice(1, -1);
        filterlist = filterlist.map(function(str) {
            return filters[str.trim()];
        });

        // compose them together into one function
        var filter = filterlist.reduce(compose);

        // and apply the composed function to the stringified content
        return filter(String(includeContent));
    }
};

function compose(f, g) {
    return function(x) {
        return f(g(x));
    };
}
