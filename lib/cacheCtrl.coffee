###*
# 模块缓存
# @author yy
###
config  = require './config'
butil   = require './butil'
fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
Buffer  = require("buffer").Buffer

md5     = butil.md5
_oldHash = {}
_hashFile = path.join(config.mapPath, config.jsHash)

if not fs.existsSync(_hashFile)
    fs.writeFileSync _hashFile,'{}','utf8'

try
    _oldHash = JSON.parse fs.readFileSync(_hashFile, 'utf8')
catch e
    # ...


exports = 
    #缓存对象
    _cache: {}

    #md5 缓存对象
    _hash: _oldHash

    #检测md5
    checkHash: (id,source) ->
        #使用二进制转换  处理中文问题
        buf = new Buffer(source)
        str = buf.toString "binary"
        _md5 = md5 str
        _flag = false

        if @_hash[id] and @_hash[id] is _md5
            _flag = true
        else
            @_hash[id] = _md5

        return _flag

    #保存到文件
    saveHash: ->
        jsonData = JSON.stringify @_hash, null, 2
        fs.writeFileSync _hashFile, jsonData, 'utf8'

    #读取缓存
    _readCache: (id) ->
        return @_cache[id]

    #保存到缓存
    _saveCache: (id, source) ->
        @_cache[id] = source
        return @_cache

module.exports = exports