###
# 项目初始化
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
gulp    = require 'gulp'
gutil   = require 'gulp-util'
color   = gutil.colors

imgmin  = require 'gulp-imagemin'
rename  = require 'gulp-rename'
butil   = require './butil'
config  = require '../config'
errrHandler = butil.errrHandler
objMixin    = butil.objMixin
md5         = butil.md5
hashLength  = config.hashLength
mapPath     = config.mapPath


Imagemin = require('imagemin')

###
# init dist, cache and watch DIRS
###
exports.dir = ->
    init_dir = [
        config.rootPath
        config.lessPath
        config.jsSrcPath
        config.tplSrcPath
        config.htmlTplSrc
        config.spriteSrcPath
        config.spriteLessOutPath
        config.cssDistPath
        config.jsDistPath
        config.tplDistPath
        config.mapPath
        config.spriteDistPath
        config.cssBgDistPath
        config.jsOutPath
        config.tplOutPath
        config.cssOutPath
        config.spriteImgOutPath
    ]

    for _dir in init_dir
        butil.mkdirsSync(_dir)
        gutil.log "#{_dir} made success!"
###
# init map file 
###
exports.map = ->       
    init_file = [
        config.jsMapName
        config.cssMapName
    ]
    for _file in init_file
        _dirpath = path.dirname(_file)
        not fs.existsSync(_dirpath) and butil.mkdirsSync(_dirpath)

        new_file = path.join config.mapPath, _file
        not fs.existsSync(new_file) and fs.writeFileSync new_file, "{}", 'utf8'
        
        gutil.log "#{config.mapPath}#{_file} made success!"


###
# build images
###
exports.bgmap = (cb)->
    _cb = cb or ->
    _map = {}
    
    _imgSrcPath = path.join config.rootPath, config.imgSrcPath

    # 递归输出文件的路径Tree和hash
    makePaths = (sup_path)->
        _sup_path = sup_path or _imgSrcPath
        _ext = ['.png','.jpg','.gif']
        fs.readdirSync(_sup_path).forEach (v)->
            sub_Path = path.join(_sup_path, v)
            if fs.statSync(sub_Path).isDirectory()
                makePaths(sub_Path)
            else if fs.statSync(sub_Path).isFile() and v.indexOf('.') != 0 and path.extname(sub_Path) in _ext
                _name = sub_Path.replace(_imgSrcPath,'')
                                .replace(/\\\\/g,'/')
                                .replace(/\\/g,'/')
                _this_ext = path.extname(_name)
                _str = String fs.readFileSync(sub_Path, 'utf8')
                _hash = md5(_str)
                _distname = _name.replace(_this_ext,'.') + _hash.substring(0,hashLength) + _this_ext
                _map[_name] = {}
                _map[_name].hash = _hash
                _map[_name].distname = _distname.replace(/\\\\/g,'/')
                                                .replace(/\\/g,'/')
                _imgmin = new Imagemin()
                    .src(sub_Path)
                    .dest(config.imgDistPath)
                    .use(rename(_distname))

                _imgmin.run (err, files) ->
                        err and throw err
                        # console.log(files[0].path)

    makePaths(_imgSrcPath)
    jsonData = JSON.stringify _map, null, 2
    
    not fs.existsSync(mapPath) and butil.mkdirsSync(mapPath)
    fs.writeFileSync path.join(mapPath, config.cssBgMap), jsonData, 'utf8'
    gutil.log color.green "#{config.cssBgMap} build success"
    _cb()

###
# build the three part's js/css paths map
###
exports.paths = (ext,cb)->
    if typeof ext is 'function'
        _ext = '.js'
        _cb = ext
        
    else
        _ext = ext or '.js'
        _cb = cb or ->
    
    _map = {}
    _jsPath = path.join config.rootPath, config.jsSrcPath
    _cssPath = path.join config.rootPath, config.cssOutPath
    _path = if _ext is '.js' then _jsPath else _cssPath
    _mapName = if _ext is '.js' then config.jsMapName else config.cssMapName
    _isCombo = config.isCombo
    # 递归输出文件的路径Tree和hash
    makePaths = (sup_path)->
        _sup_path = sup_path or _path
        fs.readdirSync(_sup_path).forEach (v)->
            sub_Path = path.join(_sup_path, v)
            if fs.statSync(sub_Path).isDirectory()
                # 递归
                makePaths(sub_Path)
            else if fs.statSync(sub_Path).isFile() and v.indexOf('.') != 0 and path.extname(sub_Path) is _ext
                _str = String fs.readFileSync(sub_Path, 'utf8')
                _basename = sub_Path.replace(_path,'')
                                .replace(/\\\\/g,'/')
                                .replace(/\\/g,'/')
                _hash = md5(_str)
                _name = _basename
                if not _isCombo
                    _nameObj = path.parse sub_Path.replace(_path,'')
                    _nameObj.hash = md5(_str)
                    _name = _nameObj.dir + '/' + _nameObj.name + '.' + _hash.substring(0,hashLength) + _nameObj.ext

                _map[_basename] = 
                    hash:_hash
                    distname:_name.replace(/\\\\/g,'/')
                                  .replace(/\\/g,'/')

    makePaths(_path)
    jsonData = JSON.stringify _map, null, 2
    not fs.existsSync(mapPath) and butil.mkdirsSync(mapPath)
    fs.writeFileSync path.join(mapPath, _mapName), jsonData, 'utf8'
    gutil.log color.green "#{_mapName} build success"
    _cb()

###
# build the three part's js libs paths
###
exports.libs = (cb)->
    _cb = cb or ->
    namePaths = {}
    fs.readdirSync(config.jsLibPath).forEach (v)->
        jsLibPath = path.join(config.jsLibPath, v)
        if fs.statSync(jsLibPath).isDirectory()
            fs.readdirSync(jsLibPath).forEach (f)->
                jsPath = path.join(jsLibPath, f)
                if fs.statSync(jsPath).isFile() and f.indexOf('.') != 0 and f.indexOf('.js') != -1
                    namePaths[v] = "vendor/#{v}/#{f.replace('.js', '')}"
    jsonData = JSON.stringify namePaths, null, 2
    # gutil.log jsonData
    not fs.existsSync(config.dataPath) and butil.mkdirsSync(config.dataPath)
    fs.writeFileSync path.join(config.dataPath, config.jsLibsMapName), jsonData, 'utf8'
    gutil.log color.green "#{config.jsLibsMapName} build success"
    _cb()
###
# build require.config
###

exports.cfg = (cb)->
    _cb = cb or ->

    # 读取json配置
    shimData = JSON.parse fs.readFileSync(path.join(config.dataPath, 'shim.json'), 'utf8')
    jsLibPaths = JSON.parse fs.readFileSync(path.join(config.dataPath, config.jsLibsMapName), 'utf8')

    # 预留给第三方的js插件的接口
    jsPaths = JSON.parse fs.readFileSync(path.join(config.dataPath, 'paths.json'), 'utf8') 

    # 过滤核心库
    newPaths = {}
    for key,val of jsLibPaths
        if key isnt 'require' and key isnt 'almond'
            newPaths[key] = val

    rCfg_dev =
        baseUrl: config.staticPath + 'js'
        paths: _.extend newPaths,jsPaths
        shim: shimData

    rCfg =
        baseUrl: config.staticPath + '_js'
        paths: _.extend newPaths,jsPaths
        shim: shimData

    jsSrcPath = config.jsSrcPath
    
    configStr_dev = "
        require.config(#{JSON.stringify(rCfg_dev, null, 2)});\n
    "
    configStr = "
        require.config(#{JSON.stringify(rCfg, null, 2)});\n
    "

    fs.writeFileSync path.join(jsSrcPath, "config.dev.js"), configStr_dev, 'utf8'
    fs.writeFileSync path.join(jsSrcPath, "config.js"), configStr, 'utf8'

    gutil.log color.green "config.js build success!"
    _cb()

