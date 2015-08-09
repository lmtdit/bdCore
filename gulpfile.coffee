###*
# gulpfile
# @date 2014-12-2 15:57:21
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###


fs      = require 'fs'
path    = require 'path'
gulp    = require 'gulp'
jsdoc   = require 'gulp-jsdoc'
gutil   = require 'gulp-util'
color   = gutil.colors
cp      = require 'child_process'
exec    = cp.exec

taskCtrl= require './lib/taskCtrl'

helper = ->
    gutil.log color.yellow.bold "前端开发框架使用说明："
    gutil.log color.cyan "以gulp命令启动程序，它可接收两个参数，分别是"
    gutil.log color.cyan "参数1： --env 或者 --e"
    gutil.log color.cyan "此参数是环境参数，默认值为'local'，其他值分别为test、rc、www"
    gutil.log color.cyan "参数1： --debug 或者 --d"
    gutil.log color.cyan "此参数为调试开关，默认值为false"
    gutil.log color.yellow.bold "eg: "
    gutil.log color.cyan "1、local开发环境的watch命令："
    gutil.log color.cyan "gulp 或者 gulp --e local 或者 gulp --env local"
    gutil.log color.cyan "2、local开发环境的debug命令："
    gutil.log color.cyan "gulp --d 或者 gulp --env local --d"
    gutil.log color.cyan "3、test环境下发布代码："
    gutil.log color.cyan "gulp --e test 或者 gulp --env test"

# 帮助
gulp.task 'helper', ->
    helper()

# 判断config.json是否存在，存在则重建
_cfgFile = path.join process.env.INIT_CWD,'config.json'
if !fs.existsSync(_cfgFile)
    gutil.log color.yellow "config.json is missing!"
    _cfg = require './data/default.json'
    _cfgData = JSON.stringify _cfg, null, 4
    fs.writeFileSync _cfgFile, _cfgData, 'utf8'
    gutil.log color.yellow "config.json rebuild success!"
    gutil.log color.green "Run Gulp Task again! Plzzzzz..."
    gulp.task 'default',[], ->
        helper()
    return false


cfg     = require './lib/config'
build   = require './lib/build'


# 环境判断
env     = cfg.env
isDebug = cfg.isDebug


###
# Initialization program
###
gulp.task 'init', ->
    build.init()
    exec "gulp -T",(error, stdout, stderr)->
        console.log stdout
        gulp.start ['helper']

###
# clean files
###
gulp.task 'del.data', ->
    build.files.delJson()

gulp.task 'clean', ->
    build.files.delDistFiles()

###
# build sprite,less,css,js,tpl...
###
gulp.task 'jslibs', -> 
    build.jsLibs()

gulp.task 'jspaths', -> 
    build.jsPaths()

gulp.task 'cfg', ->
    build.cfg()

gulp.task 'tpl', ->
    build.tpl2dev()

gulp.task 'js2dev', ->
    build.js2dev()

gulp.task 'js2dist', ->
    build.js2dist()

gulp.task 'noamd', ->
    build.noamd()

gulp.task 'corejs', ->
    build.corejs()

gulp.task 'sprite', ->
    build.sprite()

gulp.task 'bgmap', -> 
    build.bgMap()

gulp.task 'less', ->
    build.less2css()

gulp.task 'css', ->
    build.bgMap ->
        build.css2dist()

gulp.task 'map', ->
    #build.json2dist ->
        build.json2php()

###
# push all files to dist
###

gulp.task 'all', ->
    build.all2dist()

###
# html demo files
###
gulp.task 'html', ->
    build.htmlctl()
###
# php Tpl
###
gulp.task 'php', ->
    build.phpctl()

###
# build bat tool
###
gulp.task 'doc', ->
    gulp.src([cfg.jsSrcPath + '**/*.js','./README.md'])
        .pipe(jsdoc.parser({
            plugins: ['plugins/markdown']
            markdown: 
                "parser": "gfm"
        }))
        .pipe(jsdoc.generator(cfg.docOutPath,{
            path            : 'ink-docstrap'
            theme           : 'Cerulean'
            systemName      : 'v.Builder'
            linenums        : true
            collapseSymbols : true
            inverseNav      : false
        },{
            private: false
            monospaceLinks: false
            cleverLinks: true
            outputSourceFiles: true
        }))

###
# watch tasks
###
gulp.task 'watch', ->
    build.autowatch ->
        ###
        clearTimeout _gitTimer if _gitTimer
        _gitTimer = setTimeout ->
            rootPath = path.join __dirname
            disk = rootPath.split('')[0]
            if disk != '/' 
                exec 'cmd ./bin/autogit.bat',(error, stdout, stderr)->
                    console.log stdout
            else
                exec 'sh ./bin/autogit.sh',(error, stdout, stderr)->
                    console.log stdout
        ,3000
        ###



###
# release function
###
release = ()->
    #css主线任务
    cssFn = (mainCb) ->
        ###css相关任务 start###
        cssTask = new taskCtrl
            drain: ->
                build.css2dist ->
                    mainCb()

        ###less任务###
        cssTask.add 
            name: 'less'
            task: (cb) ->
                build.less ->
                    cb()#通知任务完成
        ,(err) ->
            gutil.log err if err
            gutil.log 'task:less is finished'

        ###bgMap任务###
        cssTask.add 
            name: 'bgMap'
            task: (cb) ->
                build.bgMap ->
                    cb()#通知任务完成
        ,(err) ->
            gutil.log err if err
            gutil.log 'task:bgMap is finished'

        ###css相关任务 end###

    #js主线任务
    jsFn = (mainCb) ->
        build.js ->
            ###js相关任务 start###
            jsTask = new taskCtrl
                drain: ->
                    build.js2dist ->
                        mainCb()

            ###corejs任务###
            jsTask.add 
                name: 'corejs'
                task: (cb) ->
                    build.corejs ->
                        cb()#通知任务完成
            ,(err) ->
                gutil.log err if err
                gutil.log 'task:corejs is finished'

            ###noamd任务###
            jsTask.add 
                name: 'noamd'
                task: (cb) ->
                    build.noamd ->
                        cb()#通知任务完成
            ,(err) ->
                gutil.log err if err
                gutil.log 'task:noamd is finished'


        ###js相关任务 end###

    _startTime = (new Date()).getTime()
    releaseTask = new taskCtrl
        drain: ->#结束后执行监听
            gutil.log color.cyan "构建map..."
            setTimeout ->
                #build.json2dist ->
                    #build.phpctl ->
                        build.json2php()
                        gutil.log color.cyan "构建完成，可以发版了..."
                        _endTime = (new Date()).getTime()
                        gutil.log color.cyan "耗时："+(_endTime-_startTime)/1000 +'s...'
            ,2000
    
    #css主线任务
    releaseTask.add 
        name: 'mainCss'
        task: (cb) ->
            cssFn cb
    ,(err) ->
        gutil.log err if err
        gutil.log 'task:mainCss is finished'

    #js主线任务
    releaseTask.add 
        name: 'mainJs'
        task: (cb) ->
            jsFn cb
    ,(err) ->
        gutil.log err if err
        gutil.log 'task:mainJs is finished'

    ###
    build.less ->
        build.bgMap ->
            build.css2dist ->
                build.js ->
                    build.corejs ->
                        build.noamd ->
                            build.js2dist ->
                                gutil.log color.cyan "构建map..."
                                setTimeout ->
                                    build.json2dist ->
                                        build.json2php()
                                        gutil.log color.cyan "构建完成，可以发版了..."
                                ,2000
    ###

gulp.task 'default',[], ->
    # 开发环境的构建命令
    if env == 'local' and !isDebug
        debugTask = new taskCtrl
            drain: ->#结束后执行监听
                build.htmlctl ->
                    build.phpctl() # 生成php模板
                    clearTimeout _Timer if _Timer
                    _Timer = setTimeout ->
                        gulp.start ['watch']
                    ,2000

        ###less任务###
        debugTask.add 
            name: 'less'
            task: (cb) ->
                build.less ->
                    cb()#通知任务完成
        ,(err) ->
            gutil.log err if err
            gutil.log 'task:less is finished'

        ###js任务###
        debugTask.add 
            name: 'js'
            task: (cb) ->
                build.js ->
                    cb()#通知任务完成
        ,(err) ->
            gutil.log err if err
            gutil.log 'task:js is finished'


        ###
        setTimeout ->
            build.less ->
                build.js ->
                    build.htmlctl ->
                        clearTimeout _Timer if _Timer
                        _Timer = setTimeout ->
                            gulp.start ['watch']
                        ,2000
        ,100
        ###
        
    # 测试环境代码的发布任务
    else
        release()

gulp.task 'release',[], ->
    release()
