###*
# html to AMD module js function
# @date 2015-02-14 15:36:39
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
config  = require '../config'

cssBgMap = {}
try
    cssBgMap = JSON.parse fs.readFileSync(path.join(config.mapPath, config.cssBgMap), 'utf8')
catch e
    # ...
imgRoot = config.staticRoot + config.imgDistPath.replace('../','')

module.exports = (folder,cb)->
    cb = cb or ->
    return false if folder.indexOf('.') is 0 or folder is ""
    _tplPath = config.tplSrcPath + folder
    tplData = {}
    fs.readdirSync(_tplPath).forEach (file)->
        _file_path = path.join(_tplPath, file)
        if fs.statSync(_file_path).isFile() and file.indexOf('.html') != -1 and file.indexOf('.') != 0
            file_name = file.replace('.html', '')
            imgReg = /<img\s[^(src)]*\s*src="([^"]*)"/g
            _soure = fs.readFileSync(_file_path, 'utf8')
            file_soure = _soure.replace imgReg,(str,map)->
                if map.indexOf('http://') isnt -1 or map.indexOf('data:') isnt -1
                    return str
                else
                    key = map.replace('_img/', '')
                             .replace(/(^\'|\")|(\'|\"$)/g, '')
                    val = imgRoot + (if _.has(cssBgMap,key) then cssBgMap[key].distname else key + '?=t' + String(new Date().getTime()).substr(0,8))
                    return str.replace(map, val)

            file_soure = file_soure.replace(/<!--([\s\S]*?)-->/g, '')
                           .replace(/\n/g, '')
                           .replace(/\t/g, '')
                           .replace(/\r/g, '')
                           .replace(/\s+/g, ' ')
                           .replace(/>([\n\s+]*?)</g,'><')
            if file.indexOf('_') == 0
              tplData[file_name] = "<script id=\"tpl_#{folder}#{file_name}\" type=\"smcore\">#{file_soure}</script>"
            else
              tplData[file_name] = file_soure
    tpl_soure = "define(function(){return #{JSON.stringify(tplData)};});"
    fs.writeFileSync path.join(config.tplOutPath, folder + '.js'), tpl_soure, 'utf8'
    cb()
    