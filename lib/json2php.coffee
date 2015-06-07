###*
# json to php function
# @date 2015-02-14 14:10:22
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
config  = require './config'

jsonToPhp = (cb)->
    _cb = cb or ->
    _srcPath = config.mapPath
    _distPath = config.phpMapPath
    _temp = []
    fs.readdirSync(_srcPath).forEach (file)->
        if file.indexOf(".json") != -1
            file_name = file.replace(".json","")
            php_file_path = path.join(_distPath, file_name + ".php")
            _jsonData = JSON.parse fs.readFileSync(path.join(_srcPath, file), 'utf8')
            _tempArr = []
            for name,val of _jsonData
                _name = val.distname
                _hash = val.hash
                
                _tempArr.push "'#{name}' => array('distname' => '#{_name}', 'hash' => '#{_hash}')"
            _temp[file_name] = _tempArr.join()
            fs.writeFileSync php_file_path, '<?php' + '\r\n' + 'return array(' + _tempArr + ');' + '\r\n' + '?>', 'utf8'

    _cb()

module.exports = jsonToPhp 
