###*
# 将CSS的debug文件push到生产目录，并将引用到的背景图片自动添加hash后缀
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
config  = require '../config'
gulp    = require 'gulp'
gutil   = require 'gulp-util'
mincss  = require 'gulp-minify-css'
plumber = require 'gulp-plumber'
rename  = require 'gulp-rename'
color   = gutil.colors
# CSS和雪碧图的相关path
_cssPath        = config.cssOutPath
_cssDistPath    = config.cssDistPath
_cssMapName     = config.cssMapName
_mapPath        = config.mapPath
_hashLen        = config.hashLength
_isCombo         = config.isCombo

binit       = require './binit'
butil       = require './butil'
errrHandler = butil.errrHandler
md5         = butil.md5

cssBgMap = {}
try
    cssBgMap = JSON.parse fs.readFileSync(path.join(_mapPath, config.cssBgMap), 'utf8')
catch e
    # ...

# 替换css的背景图片，加上hash
_stream = (files,cb,cb2)->
    _cssOutPath = path.join config.rootPath,config.cssOutPath
    _cndPath = config.cndStaticPath + 'css/'
    gulp.src [files]
    .pipe plumber({errorHandler: errrHandler})
    .pipe mincss({
            keepBreaks:false
            compatibility:
                properties:
                    iePrefixHack:true
                    ieSuffixHack:true
        })
    .on 'data',(source)->
        _path = source.path.replace(_cssOutPath,'')
                           .replace(/\\/g,'/')
        _nameObj = path.parse(_path)
        _nameObj.hash = md5(source.contents)
        cssBgReg = /url\s*\(([^\)]+)\)/g
        _source = String(source.contents).replace cssBgReg, (str,map)->
            if map.indexOf('fonts/') isnt -1
                fontPath = (_cndPath + path.join(_nameObj.dir,map)).replace(/\\/g,'/')
                # console.log fontPath
                return str.replace(map, fontPath)
            else
                key = map.replace('../_img/', '')
                         .replace(/(^\'|\")|(\'|\"$)/g, '')
                val = if _.has(cssBgMap,key) then '../img/' + cssBgMap[key].distname else ( if map.indexOf('data:') > -1 or map.indexOf('about:') > -1 then map else '../img/' + key + '?=t' + String(new Date().getTime()).substr(0,8) )
                return str.replace(map, val)
        cb(_nameObj,_source)
    .on 'end',cb2

# 生成css的生产文件
_buildCss = (_filePath,source)->
    butil.mkdirsSync(_cssDistPath)
    fs.writeFileSync _filePath, source, 'utf8'

# 生成css的Hash Map
_buildPaths = binit.paths

###
# css生产文件构建函数
# @param {string} file 同gulp.src接口所接收的参数，默认是css源文件的所有css文件
# @param {function} done 回调函数
###
pushCss = (file,done)->
    gutil.log color.yellow "Push Css to dist."
    if not file
        _done = ->
        _file = _cssPath + '**/*.css'
    else if typeof file is 'function'
        _done = file
        _file = _cssPath + '**/*.css'
    else
        _file = file
        _done = done
    _stream(
        _file
        ,(obj,source)->
            _source = source
            _distPath = obj.dir + '/' + obj.name + '.' + obj.hash.substr(0,_hashLen) + obj.ext
            _distPath2 = obj.dir + '/' + obj.name + obj.ext
            _filePath = path.join(_cssDistPath, _distPath)
            _filePath2 = path.join(_cssDistPath, _distPath2)
            _buildCss _filePath,_source
            _buildCss _filePath2,_source
        ,->
            _buildPaths '.css',->
                gutil.log color.green 'Pushed!'
                _done()
    ) 

module.exports = pushCss
