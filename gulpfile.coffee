###
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
# Promise = require 'bluebird'
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

gulp.task 'jspaths', -> 
    build.jsPaths()

gulp.task 'cfg', ->
    build.config()

gulp.task 'tpl', ->
    build.tpl2dev()

gulp.task 'js2dev', ->
    build.js2dev()

gulp.task 'js2dist', ->
    build.js2dist ->
        build.noamd ->

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
    build.json2dist ->
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
# build bat tool
###
gulp.task 'tool', ->
    rootPath = path.join __dirname
    disk = rootPath.split('')[0]
    if disk != '/' 
        cmd = [disk + ':']
        cmd.push 'cd ' + rootPath
        cmd.push 'start gulp'
        fs.writeFileSync(path.join(__dirname,'..','startGulp.cmd'), cmd.join('\r\n'))
    else 
        sh = ['#!/bin/sh']
        shFile = path.join __dirname,'..','startGulp.sh'
        sh.push 'cd ' + __dirname
        sh.push 'gulp'
        fs.writeFileSync shFile, sh.join('\n')
        fs.chmodSync shFile, '0755'

###
# watch tasks
###
gulp.task 'watch', ->
    build.autowatch ->
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
# release
###
gulp.task 'clean', ->
    build.files.delDistFiles()
    build.corejs()

###
# dev task
###
gulp.task 'default',[], ->
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
# release all
###
gulp.task 'release',[], ->
    setTimeout ->
        build.less ->
            build.js ->
                build.css2dist ->
                    build.js2dist ->
                        build.noamd ->
                            build.demoAndMap ->
                                gutil.log color.green 'Release finished!'
    ,100


###
gulp.task 'test', ->
    clearTimeout _gitTimer if _gitTimer
    _gitTimer = setTimeout ->
        rootPath = path.join __dirname
        disk = rootPath.split('')[0]
        if disk != '/' 
            exec 'cmd ./bin/autogit.bat',(error, stdout, stderr)->
                console.log stdout
                console.log stderr
        else
            console.log 'mac'
            exec 'sh ./bin/autogit.sh',(error, stdout, stderr)->
                console.log stdout
                console.log stderr
    ,3000
###        