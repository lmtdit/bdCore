###*
# json to php function
# @date 2015-02-14 14:10:22
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
config  = require '../config'

jsonToPhp = (cb)->
    _cb = cb or ->
    _srcPath = config.mapPath
    _distPath = config.phpMapPath
    _temp = []
    fs.readdirSync(_srcPath).forEach (file)->
        if file.indexOf(".json") != -1
            file_name = file.replace(".json","")
            php_file_path = path.join(_distPath, file_name + ".php")
            _jsData = JSON.parse fs.readFileSync(path.join(_srcPath, file), 'utf8')
            _tempArr = []
            for name,hash of _jsData
                _name = name.split(".")[0]
                _hash = hash.replace("/","")
                            .split(".")[1]
                _tempArr.push '"' + name + '" => "' + _hash + '"'
            _temp[file_name] = _tempArr.join(',')
            fs.writeFileSync php_file_path, '<?php' + '\r\n' + 'return array(' + _tempArr + ');' + '\r\n' + '?>', 'utf8'
    
    _soure = ""
    for key,val of _temp
        _soure += "\"" + key + "\" => array(\r\n" + val + "\r\n)" + ",\r\n"       
    fs.writeFileSync path.join(_distPath, 'allhash.php'), '<?php' + "\r\n" + "return array(\r\n" + _soure + ");\r\n" + "?>", "utf8"

    _cb()

module.exports = jsonToPhp 
