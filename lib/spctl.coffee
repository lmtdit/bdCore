###*
# 构建雪碧图的操作类库
# @date 
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
config  = require '../config'
_       = require 'lodash'
###
#上一次构建的雪碧图Map和hash
###
spriteMapData = {} 
spriteHasData = {}
try
    spriteMapData = JSON.parse fs.readFileSync(config.spriteDataPath, 'utf8')
    spriteHasData = JSON.parse fs.readFileSync(config.spriteHasData, 'utf8')             
catch error


### 单个雪碧图的状态检查类库 ###  
class _spStatus
    constructor: (@name) ->

    # 检查雪碧图less是否存在
    spLessIsBuild : =>
        _spLessFile = path.join config.spriteLessOutPath, '_' + @name + ".less"
        try
            fs.statSync(_spLessFile).isFile()
        catch error
            false

    # 检查雪碧图是否生成
    spPngIsBuild : =>
        _sp_png = path.join(config.spriteImgOutPath, @name + '.png')
        try
            fs.statSync(_sp_png).isFile()
        catch error
            false 

    # 检查雪碧图的hash是否生成
    spHasIsBuild : =>
        _.has(spriteHasData,@name)

    # 获取目录下的雪碧图队列
    getSpPngSrcList : =>
        _list = []
        _pngPath = path.join( config.spriteSrcPath, @name )
        return _list if _pngPath.indexOf('.DS_Store') > -1
        fs.readdirSync(_pngPath).forEach (file)->
            pngFile = path.join(_pngPath, file)
            if file.indexOf('.') != 0 and file.indexOf('.png') != -1 and fs.statSync(pngFile)
                _list.push file
        return _list

    ###
    # 返回雪碧图的生成算法 共三个：
    # 默认 binary-tree
    # 目录名的最后包含'_y'，即为Y轴，则为top-down
    # 目录名的最后包含'_x'，即为X轴，则为left-right
    ###
    getBuildMethod : =>
        method = switch 
                when (/_x$/).test(@name) then 'left-right'
                when (/_y$/).test(@name) then 'top-down'
                else 'binary-tree'
        return method      
# 基础库
class __spBaseFn
    # 源目录
    src_dir: config.spriteSrcPath
    # 输出目录
    png_dist_dir: config.spriteImgOutPath
    less_dist_dir: config.spriteLessOutPath
    ###
    # 获取所有雪碧图的源目录
    ###
    getAllSpFolders : ->
        _list = []
        fs.readdirSync(@src_dir).forEach (v)->
            if v.indexOf('.') != 0
                _list.push v
                return
        return _list

    ###
    # 获取已合成的雪碧图
    ###
    getAllSpPngFiles : ->
        _list = []
        fs.readdirSync(@png_dist_dir).forEach (v)->
            if v.indexOf('.png') != -1
                name = v.replace( /^_/ , '')
                            .replace('.png', '')
                _list.push name
                return
        return _list
    ###
    # 获取已生成的雪碧图LESS
    ###
    getAllSpLessFiles : ->
        _list = []
        fs.readdirSync(@less_dist_dir).forEach (v)->
            if v.indexOf('.less') != -1
                name = v.replace( /^_/ , '')
                            .replace('.less', '')
                _list.push name
                return
        return _list   

# 继承库
class _spBuilder extends __spBaseFn
    ###
    # 获取需要生成雪碧图的目录
    ###
    getNewBuildPngFolders : =>
        _list = []
        newList = @getAllSpFolders()
        oldList = @getAllSpPngFiles()
        for folder_name in newList
            if folder_name.indexOf('.') != 0
                if not spriteMapData.hasOwnProperty(folder_name) or folder_name not in oldList
                    _list.push folder_name
                else
                    ### 获取当前目录下的所有png文件 ###
                    _getPngs = new _spStatus(folder_name).getSpPngSrcList()
                    if spriteMapData[folder_name].length != _getPngs.length
                        _list.push folder_name
        return _list
    ###
    # 获取需要生成LESS的目录
    ###
    getNewBuildLessFloders : =>
        _list = []
        newList = @getAllSpFolders()
        oldList = @getAllSpLessFiles()
        for folder_name in newList
            if folder_name not in oldList
                 _list.push folder_name
        return _list
    ###
    # 获取需要生成雪碧图和LESS的目录
    ###
    getAllNewBuildList : =>
        _buildLessFolders = @getNewBuildLessFloders()
        _buildSpPngFolders = @getNewBuildPngFolders()
        # 队列排重
        _allFolders = _buildLessFolders.concat(_buildSpPngFolders)
        _allFolders = _allFolders.sort()
        _list = []
        for file in _allFolders
            if file not in _list
                _list.push file
        return _list
    ###
    # 生成雪碧图的目录结构地图
    ###
    buildSpriteMap : =>
        _mapData = {}
        _allSpFolders = @getAllSpFolders() 
        for folder in _allSpFolders
            _mapData[folder] = new _spStatus(folder).getSpPngSrcList()
        return _mapData 

exports.status = _spStatus
exports.builder = _spBuilder