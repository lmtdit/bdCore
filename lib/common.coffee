###
# 一些公共的处理逻辑
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
gutil   = require 'gulp-util'
color   = gutil.colors
butil   = require './butil'
config  = require './config'
getJSONSync = butil.getJSONSync
# 环境判断
env     = config.env
isDebug = config.isDebug

# map
cssBgMap = {}
jsdistmap = {}
cssmap = {}

try
    cssBgMap    = getJSONSync path.join(config.mapPath, config.cssBgMap)
    jsdistmap   = getJSONSync path.join(config.mapPath,config.jsDistMapName)
    cssmap      = getJSONSync path.join(config.mapPath,config.cssMapName)
catch e
    # ...

imgPath = config.imgPath
# imgReg = /<img\s[^(src)]*\s*src=('|")([^'|^"]*)('|")/g
imgReg = /<img[\s\S]*?[^(src)]src=('|")([^'|^"]*)('|")/g
srcReg = /src=('|")([^'|^"]*)('|")/

# Mixin hashMaps
exports.hashMaps = butil.objMixin jsdistmap,cssmap

# replace img tags with hash
exports.replaceImg = (source,type)->
    _type = type or ''
    file_source = source.replace imgReg,(str)->
        map = ''
        str.replace srcReg,(s)->
          map = s.replace(/^src=/,'').replace(/(\'|\")|(\'|\"$)/g, '')
        if map.indexOf('/_img/') isnt 0 or map.indexOf('http://') is 0 or map.indexOf('data:') is 0 or map.indexOf('/<?php/') isnt 0
            return str
        else if _type is 'tpl'
            key = map.replace('/_img/', '').replace(/(^\'|\")|(\'|\"$)/g, '')
            val = imgPath + key + '?=t' + String(new Date().getTime()).substr(0,8)
            return str.replace(map, val)
        else
            key = map.replace('/_img/', '').replace(/(^\'|\")|(\'|\"$)/g, '')
            val = imgPath + (if _.has(cssBgMap,key) then cssBgMap[key].distname else key + '?=t' + String(new Date().getTime()).substr(0,8))
            # console.log "#{map}--> #{val}"
            return str.replace(map, val)
    return  file_source

exports.htmlMinify = (source)->
    _source = source.replace(/\/\*([\s\S]*?)\*\//g, '')
                    .replace(/<!--([\s\S]*?)-->/g, '')
                    .replace(/^\s+$/g, '')
                    .replace(/\n/g, '')
                    .replace(/\t/g, '')
                    .replace(/\r/g, '')
                    .replace(/\n\s+/g, ' ')
                    .replace(/\s+/g, ' ')
                    .replace(/>([\n\s]*?)</g,'><')
                    .replace(/<?phpforeach/g,'<?php foreach')
                    .replace(/<?phpecho/g,'<?php echo')
    return _source