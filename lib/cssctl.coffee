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
# rename  = require 'gulp-rename'

color = gutil.colors

# CSS和雪碧图的相关path
_cssPath        = config.cssOutPath
_cssDistPath    = config.cssDistPath
_cssMapName     = config.cssMapName
_mapPath        = config.mapPath
_hashLen        = config.hashLength
_isCombo         = config.isCombo


butil       = require './butil'
errrHandler = butil.errrHandler
md5         = butil.md5

###
# 替换css的背景图片路径，添加hash戳
# @param {string} files 接收一个路径参数，同gulp.src
# @param {function} cb 处理过程中，处理一个buffer流的回调
# @param {function} cb2 所有buffer处理完成后的回调函数
###

_stream = (files,cb,cb2)->
    cssBgMap = JSON.parse fs.readFileSync(path.join(_mapPath, config.cssBgMap), 'utf8')
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
        _nameObj = path.parse source.path
        _nameObj.hash = md5(source.contents)
        cssBgReg = /url\s*\(([^\)]+)\)/g
        _source = String(source.contents).replace cssBgReg, (str,map)->
            key = map.replace('../_img/', '')
                     .replace(/(^\'|\")|(\'|\"$)/g, '')
            val = if _.has(cssBgMap,key) then '../../img/' + cssBgMap[key].distname else ( if map.indexOf('data:') > -1 or map.indexOf('about:') > -1 then map else '../../img/' + key + '?=t' + String(new Date().getTime()).substr(0,8) )
            return str.replace(map, val)
        cb(_nameObj,_source)
    .on 'end',cb2

# 生成css的生产文件
_buildCss = (name,source)->
    butil.mkdirsSync(_cssDistPath)
    fs.writeFileSync path.join(_cssDistPath, name), source, 'utf8'

# 生成css的Hash Map
_buildCssMap = (data,cb)->
    jsonData = JSON.stringify data, null, 2
    butil.mkdirsSync(_mapPath)
    fs.writeFileSync path.join(_mapPath, _cssMapName), jsonData, 'utf8'
    cb()

###
# css生产文件构建函数
# @param {string} file 同gulp.src接口所接收的参数，默认是css debug目录的所有css文件
# @param {function} done 回调函数
###
pushCss = (file,done)->
    cssMap = {}
    gutil.log "Push Css to dist."
    if not file
        _done = ->
        _file = _cssPath + '*.css'
    else if typeof file is 'function'
        _done = file
        _file = _cssPath + '*.css'
    else
        _file = file
        _done = done
    _stream(
        _file
        ,(obj,source)->
            _source = source
            _distname = obj.name + (if not _isCombo then  '.' + obj.hash.substr(0,_hashLen) else '' ) + obj.ext
            cssMap[obj.base] = 
                hash : obj.hash
                distname : _distname
            _buildCss _distname,_source
        ,->
            _buildCssMap cssMap,->
                gutil.log color.green 'Pushed!'
                _done()
    ) 

module.exports = pushCss
