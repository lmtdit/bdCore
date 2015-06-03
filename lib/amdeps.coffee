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
_       = require 'lodash'
gutil   = require 'gulp-util'
color   = gutil.color

### '[ ]'标志符内的依赖字符串转化为数组 ### 
tryEval = (str)-> 
    try 
        json = eval('(' + str + ')')
    catch err

### 过滤依赖表里的关键词，排除空依赖 ### 
filterDepMap = (depMap)->
    depMap = depMap.filter (dep)->
        ["require", "exports", "module", "jquery", ""].indexOf(dep) == -1
    return depMap.map (dep) -> 
                return dep.replace(/\.js$/,'')

### AMD模块的依赖构建工具类库 ###
class jsDepBuilder
    srcPath: config.jsSrcPath
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
            if fs.statSync(jsPath).isDirectory()
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

        return {
            allDeps: _allDeps
            depLibs: _depLibs
        }
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

exports.bder = jsDepBuilder