###*
# js生产文件构建类
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
amdclean = require 'amdclean'
config  = require '../config'
gulp    = require 'gulp'
gutil   = require 'gulp-util'
uglify  = require 'gulp-uglify'
plumber = require 'gulp-plumber'
# rename  = require 'gulp-rename'
header  = require 'gulp-header'
pkg     = require '../package.json'
info    = '/* <%= pkg.name %>@v<%= pkg.version %>, @author <%= pkg.author.name %>, @blog <%= pkg.author.url %> */\n'

color = gutil.colors

# CSS和雪碧图的相关path
_jsPath     = config.jsSrcPath
_jsDevPath  = config.jsOutPath
_jsDistPath = config.jsDistPath
_jsMapName  = config.jsMapName
_mapPath    = config.mapPath
_hashLen    = config.hashLength
_isCombo    = config.isCombo


butil       = require './butil'
errrHandler = butil.errrHandler
md5         = butil.md5
binit       = require './binit'

###
# js 生产文件处理函数
# @param {string} files 接收一个路径参数，同gulp.src
# @param {function} cb 处理过程中，处理一个buffer流的回调
# @param {function} cb2 所有buffer处理完成后的回调函数
###
amdReg = /;?\s*define\s*\(([^(]*),?\s*?function\s*\([^\)]*\)/
expStr = /define\s*\(([^(]*),?\s*?function/
depArrReg = /^[^\[]*(\[[^\]\[]*\]).*$/

tryEval = (str)-> 
    try 
        json = eval('(' + str + ')')
    catch err

# 过滤依赖表里的关键词，排除空依赖 
filterDepMap = (depMap)->
    depMap = depMap.filter (dep)->
        ["require", "exports", "module", ""].indexOf(dep) == -1
    return depMap.map (dep) -> 
                return dep.replace(/\.js$/,'')

# 将绝对路径转换为AMD模块ID
madeModId = (filepath)->
    return filepath.replace(/\\/g,'/')
                   .split('/js/')[1]
                   .replace(/.js$/,'')

# 将相对路径转换为AMD模块ID
madeModList = (depArr,curPath)->
    _arr = []
    if depArr.length > 0
        _.forEach depArr,(val)->
            _val = val
            if _val.indexOf('../') is 0 or _val.indexOf('./') is 0
                _filePath = path.join curPath,_val
                _val = madeModId _filePath
            _arr.push _val
    return _arr
    
# 将js数组转字符串
arrToString = (arr)->
    _str = ""
    if arr.length > 0
        _.forEach arr,(val,n)->
            _str += (if n > 0 then "," else "") + "'#{val}'"
    return "[#{_str}]"

_stream = (files,cb,cb2)->
    gulp.src [files]
    .pipe plumber({errorHandler: errrHandler})
    # .pipe uglify()
    # .pipe header(info, { pkg : pkg })
    .on 'data',(source)->
        _list = []
        _filePath = source.path.replace(/\\/g,'/')
        _nameObj = path.parse _filePath
        _nameObj.hash = md5(source.contents)
        _modId = madeModId(_filePath)
        _source = String(source.contents)
        if _filePath.indexOf("/vendor/") is -1
            _source = _source.replace amdReg,(str,map)->
                _depStr = map.replace depArrReg, "$1"
                if /^\[/.test(_depStr)
                    _arr = tryEval _depStr
                    try 
                        _list = madeModList(filterDepMap(_arr),_nameObj.dir)
                        _str = arrToString _list
                        return str.replace(expStr, "define('#{_modId}',#{_str},function")
                    catch error
                else
                    return str.replace(expStr, "define('#{_modId}',function")
            # _source = amdclean.clean({
            #         code:_source
            #         wrap:null
            #     })
            # console.log _source

        cb(_nameObj,_source)
    .on 'end',cb2

# 生成js的生产文件
_buildJs = (name,source)->
    _file = path.join(_jsDevPath, name)
    butil.mkdirsSync(path.dirname(_file))
    fs.writeFileSync _file, source, 'utf8'

# 生成js的Hash Map
_buildPaths = binit.paths

###
# js生产文件构建函数
# @param {string} file 同gulp.src接口所接收的参数，默认是js debug目录中的所有js文件
# @param {function} done 回调函数
###
module.exports = (file,done)->
    gutil.log "Build AMDmodule with ID"
    if typeof file is 'function'
        _done = file
        _file = _jsPath + '**/*.js'
    else
        _file = file or _jsPath + '**/*.js'
        _done = done or ->
    _num = 0
    _stream(
        _file
        (obj,source)->
            _source = source
            _dir = obj.dir.split("/js/")[1]
            # _distname = obj.name + (if not _isCombo then  '.' + obj.hash.substr(0,_hashLen) else '' ) + obj.ext
            _distname = obj.name + obj.ext
            _dir && (_distname = _dir + '/' + _distname)
            if _num%5 == 0 and _num > 4
                gutil.log 'Building...'
            _buildJs _distname,_source
            _num++
        ->
            _buildPaths '.js',->
                gutil.log color.green 'Build success!'
                _done()
    )
