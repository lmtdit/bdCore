###*
# 生产文件控制类：队列、删除、生成hash map等
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
config  = require './config'
gutil   = require 'gulp-util'

jsMap = {}
cssMap = {}
bgMap = {}

try
    jsMap = JSON.parse fs.readFileSync(path.join(config.mapPath, config.jsDistMapName), 'utf8')
    cssMap = JSON.parse fs.readFileSync(path.join(config.mapPath, config.cssMapName), 'utf8')
    bgMap = JSON.parse fs.readFileSync(path.join(config.mapPath, config.cssBgMap), 'utf8')
catch e
    # ...
    # cssBgMap
    # jsDistMapName


###生产文件的控制基类###
class filesController
    constructor: (@ext) ->
    path: ->
        switch @ext
            when '.js'
                config.jsDistPath
            when '.css'
                config.cssDistPath
            when '.png'
                config.spriteDistPath
            when '.json'
                config.mapPath
    # 获取文件队列
    getList : ->
        try
            _ext = @ext
            _path = @path()
            _list = []        
            fs.readdirSync(_path).forEach (v)->
                if v.indexOf(_ext) != -1
                    _list.push v
            return _list
        catch e
            # ...

    # 检查CSS/JS文件可否删除
    checkList : ->
        try
            _ext = @ext
            _list = @getList()
            _new_list = []
            if _ext isnt ".js" and _ext isnt ".css"

                return _list
            else
                _temp = []
                _curMap = if _ext is '.js' then jsMap else cssMap
                # console.log _curMap
                for file,val of _curMap
                    _temp.push file
                    _temp.push val.distname

                for file in _list
                    if file not in _temp
                        _new_list.push file
                return _new_list

        catch e
            # ...
    # 删除文件
    delList : ->
        try
            _ext = @ext
            _list = @checkList()
            console.log _list
            if _list.length == 0 
                console.log "Nothing need delete!"
                return false
            _path = @path()
            for f in _list
                _file = path.join(_path, f)
                gutil.log "delete --> #{_file}"
                fs.unlinkSync _file
        catch e
    # 清空Map
    delMap: =>
        try
            _ext = @ext 
            return false if _ext isnt '.json'
            _mapFiles = @getList()
            _path = @path()
            for file in _mapFiles
                fs.writeFileSync path.join(_path, file), '{}', 'utf8'
        catch e

module.exports = filesController
