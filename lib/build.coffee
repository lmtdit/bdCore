###*
# FEbuild
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
config  = require '../config'
gutil   = require 'gulp-util'
color   = gutil.colors

###引入自定义模块###
binit     = require './binit'
butil     = require './butil'
flctl     = require './flctl'
cssbd     = require './cssbd'
cssToDist = require './cssto'
jsToDev  = require './jsto'
jsCtl     = require './jsctl'
htmlToJs  = require './html2js'
htmlCtl   = require './htmlctl'
autowatch = require './autowatch'


###
# ************* 构建任务函数 *************
###

###初始化目录###

exports.init = ->
    binit.dir()
    binit.map()

###文件删除操作###
exports.files = 
    delJson: ->
        files = ['jslib.paths','sp.map',]
        for file in files
            json_file = path.join(config.dataPath, file + '.json')
            if fs.existsSync json_file
                fs.unlinkSync json_file
    # 删除旧的文件
    delDistCss: ->
        #创建实例化对象
        _ctl = new flctl '.css'
        _ctl.delList()
    delDistSpImg: ->
        #创建实例化对象
        _ctl = new flctl '.png'
        _ctl.delList()
    delDistJs: ->
        #创建实例化对象
        _ctl = new flctl '.js'
        _ctl.delList()
    delMap: ->
        #创建实例化对象
        _ctl = new flctl '.json'
        _ctl.delMap()
    delDistFiles: =>
        exports.files.delDistCss()
        exports.files.delDistSpImg()
        exports.files.delDistJs()
        # exports.files.delMap()

###
# Pngs combine into less and one image
###
exports.sprite  = cssbd.sp2less

###
# 生成背景图的map
###
exports.bgMap = binit.bgmap

###
# LESS into CSS
###
exports.less2css = cssbd.less2css
    
###
# 生成css的生产文件
###
exports.css2dist = cssToDist

###
# 生成js模块路径
###
exports.cssPaths = (cb)->
    cb = cb or ->
    binit.paths '.css',cb()

###
# 生成第三方模块路径
###
exports.jsLibs = binit.libs

###
# 生成js模块路径
###
exports.jsPaths = (cb)->
    cb = cb or ->
    binit.paths '.js',cb()

###
# 生成require config 和 ve_cfg
###
exports.config = binit.cfg

###
# 将html生成js模板
###
exports.tpl2dev = (cb)->
    _cb = cb or ->
    gutil.log color.yellow "Convert html to js" 
    fs.readdirSync(config.tplSrcPath).forEach (v)->
        tplPath = path.join(config.tplSrcPath, v)
        if fs.statSync(tplPath).isDirectory() and v.indexOf('.') != 0
            htmlToJs v
    gutil.log color.green "Convert success!"
    _cb()





# jsToDist  = jsCtl.bder
###
# 合并AMD js模块到debug目录(./src/_js/)
###
exports.js2dev = jsToDev

###
# 将debug目录中AMD js包文件push到生产目录
###
exports.js2dist = new jsCtl.dist().init


###
# all file to dist
###
exports.all2dist = (cb)->
    _cb = cb or ->
    exports.css2dist ->
        gutil.log color.green 'CSS pushed!'
        exports.js2dist ->
            gutil.log color.green 'JS pushed!'
            # exports.json2php ->
            #     gutil.log color.green 'phpMap done!!!!!!!!!'
            _cb()

# 将静态资源注入到php模板文件中
exports.htmlctl = htmlCtl


###
# Auto watch API
###
exports.autowatch = autowatch
