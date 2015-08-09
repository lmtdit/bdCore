###
# 服务端PHP模板构建和压缩模块
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
gulp    = require 'gulp'
plumber = require 'gulp-plumber'
gutil   = require 'gulp-util'
config  = require './config'
butil   = require './butil'
getJSONSync = butil.getJSONSync
errrHandler = butil.errrHandler
color   = gutil.colors
# include = require './include'
common  = require './common'
# minifyHTML = require('gulp-minify-html')

_hashMaps = common.hashMaps
_replaceImg = common.replaceImg
_htmlMinify = common.htmlMinify

# 构建模板
_buildTpl = (data)->
    try
        _path = String(data.path).replace(/\\/g,'/')
        return false if _path.indexOf("#{config.srcPath}/tpl_php") == -1
        _name = _path.split("#{config.srcPath}/tpl_php")[1]
        _outputPath = path.join(config.phpTplPath, _name)

        # 给html中的图片链接加上Hash
        _source = _replaceImg(String(data.contents))

        # 如果不是开发环境，则压缩html
        # if config.env isnt 'local'
        _source = _htmlMinify(_source)
        # gutil.log color.cyan("'#{_name}'"),"combined."
                           
        butil.mkdirsSync(path.dirname(_outputPath))
        fs.writeFileSync path.join(_outputPath), _source, 'utf8'
    catch e
        console.log e

module.exports = (file,cb)->
    if typeof file is 'function'
        files = "#{config.phpSrcPath}**/*.php"
        cb = file
    else
        files = file or "#{config.phpSrcPath}**/*.php"
        cb = cb or ->

    gutil.log color.yellow "Combine php templates..."
    # html模板引擎配置
    opts = 
        prefix: '@@'
        basepath: '@file'
        staticPaths:
            css:
                src: config.cssOutPath
                dist: config.cssDistPath
            js:
                src: config.jsOutPath
                dist: config.jsDistPath
        hashmap: _hashMaps

    gulp.src([files])
        .pipe plumber({errorHandler: errrHandler})
        # .pipe include(opts)
        # .pipe minifyHTML()
        .on "data",(_data)->
            _buildTpl(_data)
        .on "end",->
            gutil.log color.green "Php templates done!"
            cb()