###*
# AMD模块依赖表的构建类
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
config  = require '../config'
# flctl   = require './flctl'
_       = require 'lodash'
amdclean = require 'amdclean'
gulp    = require 'gulp'
revall  = require 'gulp-rev-all'
uglify  = require 'uglify-js'
# _uglify = require 'gulp-uglify'
# header  = require 'gulp-header'
# pkg     = require '../package.json'
# info    = '/* <%= pkg.name %>@v<%= pkg.version %>, @description <%= pkg.description %>, @author <%= pkg.author.name %>, @blog <%= pkg.author.url %> */\n'
rjs     = require 'gulp-requirejs'
plumber = require 'gulp-plumber'
gutil   = require 'gulp-util'
color   = gutil.colors
butil       = require './butil'
errrHandler = butil.errrHandler
md5         = butil.md5
jsDistMapName = config.jsDistMapName
rootPath    = config.rootPath
GLOBALVAR = config.GLOBALVAR

### '[ ]'标志符内的依赖字符串转化为数组 ### 
tryEval = (str)-> 
    try 
        json = eval('(' + str + ')')
    catch err

jsHash = {}

_buildJsDistMap = (map)->
    mapPath = config.mapPath
    jsonData = JSON.stringify map, null, 2
    not fs.existsSync(mapPath) and butil.mkdirsSync(mapPath)
    fs.writeFileSync path.join(rootPath, mapPath, jsDistMapName), jsonData, 'utf8'

_updateJsDistMap = (newMap)->
    mapPath = config.mapPath
    _newMap = JSON.stringify newMap, null, 2
    not fs.existsSync(mapPath) and butil.mkdirsSync(mapPath)
    _oldMap = JSON.parse fs.readFileSync(path.join(rootPath, mapPath, jsDistMapName), 'utf8')
    jsonData = _.assign _oldMap,_newMap
    fs.writeFileSync path.join(rootPath, mapPath, jsDistMapName), jsonData, 'utf8' 

_buildJs = (source,outName,cb)->
    _jsHash = {}
    outPath = path.join rootPath, config.jsDistPath
    not fs.existsSync(outPath) and butil.mkdirsSync(outPath)
    _content = amdclean.clean({
            code:source
            wrap:
                start: if outName is config.coreJsName then GLOBALVAR else ';(function() {\n'
                end: if outName is config.coreJsName then '' else '\n}());'
        })
    # console.log _content
    # 生成combo后的源码
    
    _oldPath = path.join outPath, outName + '.js'
    fs.writeFileSync _oldPath, _content, 'utf8'

    # 生成带Hash的生产码
    mangled = uglify.minify _content,{fromString: true}
    _source = mangled.code
    _hash = md5(_source)
    _distname = outName + '.' + _hash.substring(0,config.hashLength) + '.js'
    _jsHash[outName + ".js"] = 
        hash: _hash
        distname: _distname
    _devPath = path.join outPath, _distname
    fs.writeFileSync _devPath, _source, 'utf8'
    cb(_jsHash)

### 过滤依赖表里的关键词，排除空依赖 ### 
filterDepMap = (depMap)->
    depMap = depMap.filter (dep)->
        ["require", "exports", "module",""].indexOf(dep) == -1
    return depMap.map (dep) -> 
                return dep.replace(/\.js$/,'')

### AMD模块的依赖构建工具类库 ###
class jsDepBuilder
    srcPath: config.jsOutPath
    amdRegex: /;?\s*define\s*\(([^(]*),?\s*?function\s*\([^\)]*\)/
    depArrRegex: /^[^\[]*(\[[^\]\[]*\]).*$/
    # 单个文件的依赖表
    oneJsDep: (file_path,file_name)=>
        _list = []
        _amdRegex = @amdRegex
        _depArrRegex = @depArrRegex
        _filePath = path.join(file_path, file_name)
        _jscontents = fs.readFileSync(_filePath, 'utf8').toString()
        _jscontents.replace _amdRegex, (str, map)-> 
            depStr = map.replace _depArrRegex, "$1"
            if /^\[/.test(depStr)
                arr = tryEval depStr
                try 
                    _list = filterDepMap arr
                catch error
        return _list

    # 遍历所有js文件，生成依赖关系Map表
    allJsDep: =>
        depMap = {}
        _srcPath = @srcPath
        _oneJsDep = @oneJsDep
        fs.readdirSync(_srcPath).forEach (v)->
            jsPath = path.join(_srcPath, v)
            # if fs.statSync(jsPath).isDirectory()  and v isnt 'tpl'
            if fs.statSync(jsPath).isDirectory() and v isnt 'vendor'
                fs.readdirSync(jsPath).forEach (f)->
                    if f.indexOf('.') != 0 and f.indexOf('.js') != -1
                        # filePath = path.join(jsPath, f)
                        fileDep = _oneJsDep(jsPath, f)
                        name = f.replace('.js','')
                        depMap["#{v}/#{name}"] = fileDep
                    else if f.indexOf('.coffee') == -1
                        jsPath_lv2 = path.join(jsPath, f)
                        if fs.statSync(jsPath_lv2).isDirectory()
                            fs.readdirSync(jsPath_lv2).forEach (ff)->
                                if ff.indexOf('.') != 0 and ff.indexOf('.js') != -1
                                    name_lv2 = ff.replace('.js','')
                                    # console.log "#{v}/#{f}/#{name_lv2}"
                                    fileDep = _oneJsDep(jsPath_lv2,ff)
                                    depMap["#{v}/#{f}/#{name_lv2}"] = fileDep

        return depMap

    # 生成每个文件的所有依赖列表
    makeDeps: () =>
        _allDeps = {}
        _depLibs = []
        _alljsDep = @allJsDep()
        # 计算每个文件对应的依赖，递归算法
        makeDep = (deps)-> 
            # console.log deps
            _list = []
            make = (deps) ->
                deps.forEach (dep) ->   
                    currDeps = _alljsDep[dep]         
                    if currDeps or dep.indexOf("/") != -1
                        make(currDeps)
                    _list.push(dep)
            make(deps)
            return _list

        for file,depList of _alljsDep
            _allDeps[file] = {}
            _list = [] 
            _lib = []

            if depList.length > 0
                _tempArr = makeDep(depList)
                _tempArr = _.union _tempArr
                # 依赖排重                
                for _file in _tempArr                    
                    if _file not in _list and _file.indexOf("/") isnt -1 
                        _list.push(_file)
                    else
                        _lib.push(_file) if _file not in _lib

                    _depLibs.push(_file) if _file.indexOf("/") is -1

            _allDeps[file] = {
                modList: _list
                libList: _lib 
            }
        __obj = {
            allDeps: _allDeps
            depLibs: _depLibs
        }
        return __obj
    # 生成某个模块的相关模块列表
    makeRelateList: (module_name) =>
        _module_name = module_name
        if _module_name.indexOf("/") is -1 or _module_name.indexOf('.') is 0
            gutil.log color.red(_module_name), "not an AMD module"
            return false
        _list = []
        _makeDeps = @makeDeps()
        _allDeps = _makeDeps.allDeps
        _depLibs = _makeDeps.depLibs
        # gutil.log _allDeps
        for module,deps of _allDeps
            if _module_name in deps.modList or module is _module_name
                _list.push module
        return _list


###
# 合并AMD模块到dist目录的继承类
###
class jsToDist extends jsDepBuilder
    prefix: config.prefix
    outPath: config.jsDistPath
    distPath: config.jsDistPath
    coreMods: config.coreJsMods
    configStr: "
        window['#{config.configName}'] = #{JSON.stringify(config.configDate, null, 2)}
        "
    ### AMD模块加载JS与第三方JS合并成核心JS库 ###
    rjsBuilder: (modules,cb)=>
        _cb = cb or ->
        _baseUrl = @srcPath
        _destPath = @distPath
        _outName = config.coreJsName
        _coreMods = @coreMods
        _include = _.union _coreMods.concat(modules)
        # console.log _include
        _paths = JSON.parse fs.readFileSync(path.join(config.dataPath, 'jslibs.json'), 'utf8')
        _shim = JSON.parse fs.readFileSync(path.join(config.dataPath, 'shim.json'), 'utf8')
        
        _rjs = rjs
            baseUrl: _baseUrl
            paths: _paths
            include: _include
            out: _outName + '.js'
            shim: _shim

        _rjs.on 'data',(output)->
            _source = String(output.contents)
            _buildJs _source,_outName,(map)->
                _.assign jsHash,map
                _cb()

    ### 合并核心js模块 ### 
    coreModule: (cb)=>
        gutil.log color.yellow "Combine #{config.coreJsName} module! Waitting..."
        _cb = cb or ->
        _makeDeps = @makeDeps()
        _depLibs = _makeDeps.depLibs  
        # 核心库队列
        @rjsBuilder _depLibs,-> _cb()

    ### 合并单个模块 ###
    oneModule: (name,cb)=>
        _cb = cb or ->
        _module_name = name
        # 过滤下划线的js模块
        return _cb() if _module_name.indexOf("_") is 0

        _num = 0

        if _module_name.indexOf("/") is -1 or _module_name.indexOf('.') is 0
            gutil.log "#{_module_name}not an AMD module"
        
        else 
            _tempHash = {}
            _jsData = []
            _module_path = @srcPath
            _out_path = @outPath
            _moduleDeps = @makeDeps().allDeps[_module_name].modList
            _this_js = path.join _module_path, _module_name + '.js'
            _outName = @prefix + _module_name.replace(/\//g, '_')
            # console.log _moduleDeps
            for f in _moduleDeps
                _jsFile = path.join(_module_path, f + '.js')
                if fs.statSync(_jsFile).isFile()
                    _source = fs.readFileSync(_jsFile, 'utf8')
                    _jsData.push _source + ';'
            # 追加当前模块到队列的最后
            _jsData.push fs.readFileSync(_this_js, 'utf8') + ';'
            try
                content = String(_jsData.join(''))
                _buildJs content,_outName,(map)->
                    gutil.log "Combine",color.cyan(_module_name),"----> #{_outName}.js"
                    _updateJsDistMap map
                
            catch error
                gutil.log "Error: #{_devName}"
                gutil.log error
        _cb()

    ### 合并js模块 ###
    modulesToDev: (cb)=> 
        _cb = cb or ->
        _srcPath = @srcPath
        _allDeps = @makeDeps().allDeps
        # console.log _allDeps
        _depList = _allDeps.modList
        # 生成依赖
        _num = 0
        gutil.log color.yellow "Combine javascript modules! Waitting..."
        for module,deps of _allDeps
            # 过滤下划线的js模块
            if module.indexOf("_") isnt 0
                _this_js = path.join(_srcPath, module + '.js')
                _outName = @prefix + module.replace(/\//g,'_')
                _jsData = []  
                _modList = deps.modList
                # console.log _modList
                for f in _modList
                    _jsFile = path.join(_srcPath, f + '.js')
                    if fs.statSync(_jsFile).isFile() and f.indexOf('.') != 0
                        _source = fs.readFileSync(_jsFile, 'utf8')
                        _jsData.push _source + ';'
                # 追加当前模块到队列的最后
                _jsData.push fs.readFileSync(_this_js, 'utf8') + ';'
                gutil.log "Waitting..." if _num % 10 == 0 and _num > 1
                try
                    _source = String(_jsData.join(''))
                    _buildJs _source,_outName,(map)->
                        gutil.log "Combine",color.cyan("'#{module}'"),"===> #{_outName}"
                        _.assign jsHash,map
                    _num++
                catch error
                    gutil.log "Error: #{_outName}"
                    gutil.log error
        _cb(_num)

    # build all modules to dist
    init: (cb)=>
        _cb = cb or ->
        _modulesToDev = @modulesToDev
        _coreModule = @coreModule
        _modulesToDev (num)->
            gutil.log color.cyan(num),"javascript modules combined!"
            # build core module
            _coreModule ->
                gutil.log '\'' + color.cyan("#{config.coreJsName}") + '\'',"combined!"
                _buildJsDistMap jsHash
                _cb()

# 外部接口
exports.bder = jsDepBuilder
exports.dist = jsToDist