###
#
# @date 2014-12-2 15:57:21
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

gulp    = require 'gulp'
fs      = require 'fs'
path    = require 'path'
build   = require './lib/build'
config  = require './config'
gutil   = require 'gulp-util'
color   = gutil.colors
Promise = require 'bluebird'
cp      = require 'child_process'
exec    = cp.exec
# git     = require 'gulp-git'

###
# Initialization program
###
gulp.task 'init', ->
    build.init()
    exec "gulp -T",(error, stdout, stderr)->
        console.log stdout
###
# clean files
###
gulp.task 'del.data', ->
    build.files.delJson()

gulp.task 'del.dist', ->
    build.files.delDistFiles()


###
# build sprite,less,css,js,tpl...
###
gulp.task 'jslibs', -> 
    build.jsLibs()

gulp.task 'cfg', ->
    build.config()

gulp.task 'tpl', ->
    build.tpl2dev()

gulp.task 'js2dev', ->
    build.js2dev()

gulp.task 'js2dist', ->
    build.js2dist()

gulp.task 'corejs', ->
    build.corejs()

gulp.task 'sp', ->
    build.sprite()

gulp.task 'bgmap', -> 
    build.bgMap()

gulp.task 'less', ->
    build.less2css()

gulp.task 'css', ->
    build.bgMap ->
        build.css2dist()

gulp.task 'phpmap', -> 
    build.json2php()

###
# push all files to dist
###

gulp.task 'all2dist', ->
    build.all2dist()

gulp.task 'map2dist', ->
    build.json2dist ->
       

###
# Injecting static files relative to PHP-tpl files
###
gulp.task 'html2dist', ->
    build.htmlctl()

###
# build bat tool
###
gulp.task 'tool', ->
    rootPath = path.join __dirname
    disk = rootPath.split('')[0]
    if disk != '/' 
        cmd = [disk + ':']
        cmd.push 'cd ' + rootPath
        cmd.push 'start gulp dev'
        fs.writeFileSync(path.join(__dirname,'..','startGulp.cmd'), cmd.join('\r\n'))
    else 
        sh = ['#!/bin/sh']
        shFile = path.join __dirname,'..','startGulp.sh'
        sh.push 'cd ' + __dirname
        sh.push 'gulp dev'
        fs.writeFileSync shFile, sh.join('\n')
        fs.chmodSync shFile, '0755'

###
# watch tasks
###
gulp.task 'watch', ->
    build.autowatch ->
        # clearTimeout _distTimer if _distTimer
        # _distTimer = setTimeout ->
        #     # build.all2dist ->
        #         # gulp.start ['git']
        # ,10000

###
# dev task
###
gulp.task 'default',[], ->
    setTimeout ->
        build.sprite ->
            build.less2css ->
                build.bgMap ->
                    build.jsLibs ->
                        build.config ->
                            build.tpl2dev ->
                                build.js2dev ->
                                    build.htmlctl ->
                                        setTimeout ->
                                            gulp.start ['watch']
                                        ,2000
    ,100
###
# release all
###
gulp.task 'release',[], ->
    setTimeout ->
        build.sprite ->
            build.less2css ->
                build.bgMap ->
                    build.css2dist ->
                        build.jsLibs ->
                            build.config ->
                                build.tpl2dev ->
                                    build.js2dev ->
                                        build.js2dist ->
                                            build.json2dist ->
                                                    build.htmlctl ->
                                                        build.json2php ->
                                                            gutil.log color.green 'Finished Release!'
    ,100


gulp.task 'test',[], ->

    sp = ->
        build.sprite ->
            return Promise.resolve('sp is done')

    sp.then()               
    js = ->
        build.jsLibs ->
            build.config ->
                return "js libs and config is dong"
   
    new Promise(css())
        .then(js())
        .then(coreJs())
        .then(moduleJs())
        .catch (e)->
            alertAsync("Exception " + e)


    


###
# release development
###
gulp.task 'dev',[], ->
    setTimeout ->
        build.sprite ->
            build.less2css ->
                build.bgMap ->
                    build.css2dist ->
                        build.jsLibs ->
                            build.config ->
                                build.tpl2dev ->
                                    build.js2dev ->
                                        build.htmlctl ->
                                            gutil.log color.green 'Finished Release!'
    ,100

###
# release
###
gulp.task 'clean', ->
    build.files.delDistFiles()
    build.corejs()