###
# js Lib库插件构建模块
# 公共的Lib库，挂载在 window.Lib 对象下的扩展插件库
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
gutil   = require 'gulp-util'
color   = gutil.colors
butil   = require './butil'
config  = require './config'
errrHandler = butil.errrHandler
objMixin    = butil.objMixin
md5         = butil.md5



_buildLibs = (cb)->
    jslibsJson = require(config.dataPath + config.jsDistMapName)
    jsonData = {}
    _jsLibs = config.jsLibs
    fs.readdirSync(_jsLibs).forEach (v)->
        _paths = path.join(_jsLibs, v, 'dist/paths.json')
        if fs.statSync(_paths).isFile() and v.indexOf('.') isnt 0
            _json = require(_paths)
            jsonData = _.assign jslibsJson,_json
                
    jsonData = JSON.stringify namePaths, null, 2
    gutil.log jsonData
    not fs.existsSync(config.dataPath) and butil.mkdirsSync(config.dataPath)
    fs.writeFileSync path.join(config.dataPath, config.jsDistMapName), jsonData, 'utf8'
    gutil.log color.green "#{config.jsDistMapName} build success"
    _cb()