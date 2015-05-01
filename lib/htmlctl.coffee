###
# 服务端html模板构建和压缩模块
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
gulp    = require 'gulp'
plumber = require 'gulp-plumber'
gutil   = require 'gulp-util'
config  = require '../config'
butil   = require './butil'
getJSONSync = butil.getJSONSync
errrHandler = butil.errrHandler
color   = gutil.colors
include = require './include'
minifyHTML = require('gulp-minify-html')

cssBgMap = {}
jsmap = {}
jsdistmap = {}
cssmap = {}

try
    cssBgMap    = getJSONSync path.join(config.mapPath, config.cssBgMap)
    jsmap       = getJSONSync path.join(config.mapPath,config.jsMapName)
    jsdistmap   = getJSONSync path.join(config.mapPath,config.jsDistMapName)
    cssmap      = getJSONSync path.join(config.mapPath,config.cssMapName)
catch e
    # ...
hashMaps = butil.objMixin jsmap,jsdistmap,cssmap
imgRoot = config.staticRoot + config.imgDistPath.replace('../','')

# 压缩html
_minhtml = (data)->
    try
        _path = String(data.path).replace(/\\/g,'/')
        return false if _path.indexOf("/#{config.views}_") > -1
        _name = _path.split("/#{config.theme}/#{config.views}")[1]
        _outputPath = path.join(config.htmlTplDist, _name)
        _soure = String(data.contents)
        imgReg = /<img\s[^(src)]*\s*src="([^"]*)"/g
        _soure = _soure.replace imgReg,(str,map)->
            if map.indexOf('http://') isnt -1
                return str
            else
                key = map.replace('_img/', '')
                         .replace(/(^\'|\")|(\'|\"$)/g, '')
                val = imgRoot + (if _.has(cssBgMap,key) then cssBgMap[key].distname else key + '?=t' + String(new Date().getTime()).substr(0,8))
                return str.replace(map, val)

        if config.evn isnt 'dev' and config.evn isnt 'debug'
            gutil.log color.cyan("\'" + _name + "\'"),"combined."
            _soure = _soure.replace(/\/\*([\s\S]*?)\*\//g, '')
                           .replace(/^\s+$/g, '')
                           # .replace(/\n/g, '')
                           .replace(/\t/g, '')
                           # .replace(/\r/g, '')
                           # .replace(/\n\s+/g, ' ')
                           # .replace(/\s+/g, ' ')
                           # .replace(/>([\n\s+]*?)</g,'><')
                           
                           
        butil.mkdirsSync(path.dirname(_outputPath))
        fs.writeFileSync path.join(_outputPath), _soure, 'utf8'
    catch e
        console.log e

module.exports = (file,cb)->
    if typeof file is 'function'
        files = "#{config.htmlTplSrc}**/*.html"
        cb = file
    else
        files = file or "#{config.htmlTplSrc}**/*.html"
        cb = cb or ->

    gutil.log color.yellow "Combine html templates..."
    # html模板引擎配置
    opts = 
        prefix: '@@'
        basepath: '@file'
        evn: config.evn
        isCombo: config.isCombo
        staticRoot: config.staticRoot
        staticPaths:
            css:
                src: config.cssOutPath
                dist: config.cssDistPath
            js:
                src: config.jsOutPath
                dist: config.jsDistPath
        hashmap: hashMaps
        # context:
        #     combo_css: true
        #     combo_js: true

    gulp.src([files])
        .pipe plumber({errorHandler: errrHandler})
        .pipe include(opts)
        # .pipe minifyHTML()
        .on "data",(data)->
            _minhtml(data)   
        .on "end",->
            gutil.log color.green "Html templates done!"
            cb()

