###*
# html to AMD module js function
# @date 2015-02-14 15:36:39
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs = require 'fs'
path = require 'path'
_ = require 'lodash'
config = require './config'
common = require './common'

# # 环境判断
# env     = config.env
# isDebug = config.isDebug

# cssBgMap = {}
# try
#     cssBgMap = JSON.parse fs.readFileSync(path.join(config.mapPath, config.cssBgMap), 'utf8')
# catch e
#     # ...
# imgRoot = config.staticRoot + (if isDebug or env != 'local' then config.imgDistPath else config.imgSrcPath).replace('../','')

_replaceImg = common.replaceImg
_htmlMinify = common.htmlMinify

module.exports = (folder,cb)->
    cb = cb or ->
    return false if folder.indexOf('.') is 0 or folder is ""
    _tplPath = config.tplSrcPath + folder
    tplData = {}
    fs.readdirSync(_tplPath).forEach (file)->
        _file_path = path.join(_tplPath, file)
        if fs.statSync(_file_path).isFile() and file.indexOf('.html') != -1 and file.indexOf('.') != 0
            file_name = file.replace('.html', '')
            _source = fs.readFileSync(_file_path, 'utf8')

            # 给html中的图片链接加上Hash
            file_source = _replaceImg(_source)
            # 压缩html
            file_source = _htmlMinify(file_source)

            if file.indexOf('_') == 0
              tplData[file_name] = "<script id=\"tpl_#{folder}#{file_name}\" type=\"text/html\">#{file_source}</script>"
            else
              tplData[file_name] = file_source
    tpl_soure = "define(function(){return #{JSON.stringify(tplData)};});"
    fs.writeFileSync path.join(config.tplOutPath, folder + '.js'), tpl_soure, 'utf8'
    cb()
