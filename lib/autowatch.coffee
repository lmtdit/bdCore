###*
# 开发模式下的监控模块
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###
fs      = require 'fs'
path    = require 'path'
config  = require '../config'
watch   = require 'gulp-watch'
gutil   = require 'gulp-util'
cssbd   = require './cssbd'
css2dist = require './cssto'
htmlToJs  = require './html2js'
htmlCtl   = require './htmlctl'
jsto    = require './jsto'
color   = gutil.colors

# 错误报警,beep响两声
butil       = require './butil'
errrHandler = butil.errrHandler


# JS语法检测
jshint  = require 'jshint'
JSHINT  = jshint.JSHINT
jsError = (file)->
    try 
        gutil.log color.magenta("jshint.JS语法检测开始----->")
        _source = fs.readFileSync(file, 'utf8')
        # console.log _source
        !!JSHINT(_source)
        JSHINT.errors.filter (error)->
            if error
                gutil.log color.cyan(file)," error in line #{error.line}==>"
                gutil.log color.yellow(error.reason)
        gutil.log color.magenta("----->jshint.JS语法检测结束")
    catch e
        console.log e

###
# 检查监控的文件类型和路径的工具类
###

class watchChecker
    constructor: (@file)->
    getParse: ->
        _file = @file
        _str =  _file.split("#{config.theme}/")[1] + ""
        _pathObj = path.parse(_str)
        return _pathObj
    type: ->
        _file = @file
        _ext = @getParse().ext.replace('.','')
        if _ext is 'html'
            _ext = if _file.indexOf(config.views) is -1 then 'tpl' else 'html'
        return _ext
    folder: ->
        return @getParse().dir
###
# 检查文件，并根据检测结构选择对应的文件构建方法
###
class checkFile extends watchChecker
    js: (cb)=>
        _type = @type()
        return false if _type isnt 'js'
        # jshint语法检测
        _file = @file
        jsError(_file)
        # 合并相关模块
        gutil.log "Conbine",'\'' + color.cyan(_file.split('/js/')[1]) + '\'',"..."
        jsto _file,->
            gutil.log color.cyan(_file.split('/js/')[1]),"Conbined!!!"
            cb()
    tpl:(cb)=>
        _type = @type()
        return false if _type isnt 'tpl'
        _folder = @folder().replace('tpl/','')
        gutil.log color.yellow "Convert html to js"       
        htmlToJs _folder
        gutil.log color.green "Convert success!"
        cb()
    html:(cb)=>
        _type = @type()
        return false if _type isnt 'html'
        gutil.log "Injecting HTML source files relative to HTML Template."
        htmlCtl()

    less: (cb)=>
        _type = @type()
        return false if _type isnt 'less'
        gutil.log color.yellow "Compiling Less into CSS"
        cssbd.less2css ->
            gutil.log color.green "Less compile success!"
            css2dist ->
                cb()
    sprite: (cb)=>
        _type = @type()
        return false if _type isnt 'png'
        sp_folder = @folder().replace('sprite/','')
        cssbd.png2img sp_folder,->
            gutil.log color.green "#{sp_folder} sprite build success!"
            cb()
    build: (cb)=>
        _type = @type()
        __js = @js
        __tpl = @tpl
        __html = @html  
        __sp = @sprite
        __less = @less
        switch _type
            when 'js'
                __js -> cb()
            when 'tpl'
                __tpl -> cb()
            when 'html'
                __html -> cb()
            when 'png'
                __sp -> cb()
            when 'less'
                __less -> cb()
            else
                return cb()
###
# 开发的监控API
###
_autowatch = (cb)->
    _cb = cb or ->
    _list = {}
    _folder = []
    _path = config.watchFiles
    watch _path,(file)->
        try
            _event = file.event
            return false if _event is 'undefined' or _event is 'unlink'
            _file_path = file.path.replace(/\\/g,'/')

            # 检测文件
            _checkfile = new checkFile(_file_path)
            _file_type = _checkfile.type()
            _file_folder = _checkfile.folder()
            _list[_file_type] = []
            # 队列去重
            if _file_path not in _list[_file_type]
                gutil.log '\'' + color.cyan(file.relative) + '\'',"was #{_event}"
                _list[_file_type].push _file_path
                return false if (_file_type is 'tpl' or _file_type is 'png') and _file_folder in _folder
                _folder.push _file_folder  

                # 执行文件的合并
                _checkfile.build -> _cb()

                # 清理队列
            clearTimeout watch_timer if watch_timer
            watch_timer = setTimeout ->
                # clear the list after 3 seconds
                _list = {}
                _folder = []
            ,3000
        catch err
            console.log err         

module.exports = _autowatch
