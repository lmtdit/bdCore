###*
# CSS自动化构建模块
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

fs      = require 'fs'
path    = require 'path'
config  = require '../config'
gulp    = require 'gulp'
sprite  = require 'gulp.spritesmith'
less    = require 'gulp-less'
mincss   = require 'gulp-minify-css'
plumber = require 'gulp-plumber'
# imagemin = require 'gulp-imagemin'
gutil   = require 'gulp-util'
color   = gutil.colors

spctl   = require './spctl'
spStatus = spctl.status
spBuilder = spctl.builder

# 错误报警,beep响两声
butil      = require './butil'
errrHandler = butil.errrHandler

###
# PNGs combine to one image and build LESS demo
###
_pngsToOneImg = (floder,callback) -> 
    _floder = floder
    _pngSrc = path.join(config.spriteSrcPath, _floder, '*.png')
    #雪碧图最终生成的完整路径
    _sp_png = path.join(config.spriteImgOutPath, _floder + '.png')
    # 雪碧图在css中相对路径
    _sp_bg_url = '../_img/sp/' + _floder + '.png'
    # 获取雪碧图合成算法
    _method = new spStatus(_floder).getBuildMethod()
    option =
        # engine: 'pngsmith'
        algorithm: _method
        padding: 10
        imgName: "#{_floder}.png"
        cssName: "_#{_floder}.less"
        cssFormat: 'css'
        imgPath: _sp_bg_url
        cssOpts:
            cssSelector: (item)->
                return ".icon-#{_floder}-#{item.name}()"  
    spriteData = gulp.src(_pngSrc).pipe(sprite(option))

    try 
        spriteData.img.pipe gulp.dest(config.spriteImgOutPath)
            .on 'end',->
                spriteData.css.pipe gulp.dest(config.spriteLessOutPath)
                    .on 'end',->                                                            
                        callback()
    catch error
            gutil.log "Error: #{_sp_png}"
            gutil.log error
    return

###
# 生成雪碧图和雪碧图map
# @param  _type 1:所有未生成LESS或PNG的目录  2: 未生成PNG的目录   3: 未生成LESS的目录  默认所有目录
###
_spToLess = (type,cb)->
    if typeof type  is 'function'
        _cb = type
        cb = null
        _type = 0
    else
        _type = type
        _cb = cb or ->

    # 实例化雪碧图的构建对象 
    _bder = new spBuilder()

    # 本次构建的雪碧图Map
    spmapData = _bder.buildSpriteMap()

    # 生成新的雪碧图结构Map
    _buildMap = (callback)->
        mapDataStr = JSON.stringify(spmapData, null, 4)
        fs.writeFileSync config.spriteDataPath, mapDataStr, 'utf8'
        callback()

    # 本次构建的雪碧图队列
    _newBuildFolders = 
        switch _type
            when 1 then _bder.getAllNewBuildList()  
            when 2 then _bder.getNewBuildPngFolders()
            when 3 then _bder.getNewBuildLessFloders()
            else _bder.getAllSpFolders()

    # 生成新的sp图和Less
    total = _newBuildFolders.length
    _num = 0
    if total > 0
        gutil.log 'Conbine PNG images into one image!'
        for folder in _newBuildFolders
            _pngsToOneImg folder, ->
                _num++
                _num%10 == 1 and gutil.log 'Waitting...'
                if _num == total
                    _buildMap -> 
                    	gutil.log color.green 'Sprite IMG and LESS build success'
                    	_cb()

###
# 从less生成css源码
###
_lessToCss = (cb)->
    _cb = cb or ->
    _src = [
        path.join(config.lessPath, '*.less'),
        "!#{path.join(config.lessPath, '_*.less')}"
    ]
    lessOutPush = gulp.src(_src)
        .pipe plumber({errorHandler: errrHandler})
        .pipe less
                compress: false
                paths: [config.lessPath]
        .pipe gulp.dest(config.cssOutPath)
        .on 'end',-> 
            _cb()

            
exports.png2img = _pngsToOneImg                  
exports.sp2less = _spToLess
exports.less2css = _lessToCss
