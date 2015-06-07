###
# v.build config
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

path  = require 'path'
butil = require './butil'

cfg = require '../config.json'

args   = require('yargs').argv

st_root = process.env.INIT_CWD
viewsDir = 'html/'

_env = (args.e or args.env) ? 'local'
_isDebug = (args.d or args.debug) ? false
_envs = cfg.envs

srcPath = cfg.srcPathName
distPath = cfg.distPathName

# 开发环境下，请求静态资源的域名
SiteUrl = _envs[_env].SiteUrl
cndDomain = _envs[_env].cndDomain
WapSiteUrl = _envs[_env].WapSiteUrl

module.exports =
  # 开发环境 
  env: _env 

  # 是否开启debug模式
  isDebug: _isDebug

  # 是否开启在线combo
  isCombo: cfg.isCombo

  # 项目的主目录
  rootPath: st_root
  srcPath: cfg.srcPathName
  distPath: cfg.distPathName

  # PHP的模板路径
  views: viewsDir
  htmlTplSrc: path.join "..",srcPath,viewsDir

  # html模板路径
  htmlTplDist: cfg.htmlTplDist

  # PHP版本map输出路径
  phpMapPath: cfg.phpMapPath

  # js文件前缀
  prefix: cfg.jsPrefix
  # 生产文件的hash长度
  hashLength: cfg.hashLength

  # 核心js
  coreJsName: cfg.jsPrefix + cfg.coreJs.name
  coreJsMods: cfg.coreJs.mods

  # 静态路径
  staticRoot: "http://#{cndDomain}/"
  staticPath: "http://#{cndDomain}/" + (if _isDebug or _env != "local" then "#{distPath}/" else "#{srcPath}/")
  imgPath: "http://#{cndDomain}/" + (if _isDebug or _env != "local" then "#{distPath}/img/" else "#{srcPath}/_img/")
  cssPath: "http://#{cndDomain}/" + (if _isDebug or _env != "local" then "#{distPath}/css/" else "#{srcPath}/_css/")
  jsPath: "http://#{cndDomain}/" + (if _isDebug or _env != "local" then "#{distPath}/js/" else "#{srcPath}/_js/")

  # 插入到页面中的全局变量
  GLOBALVAR: "var STATIC_PATH='http://#{cndDomain}/" + (if cfg.evn is "local" then srcPath else distPath) + "',VARS=window['VARS']={},_VM_=window['_VM_']={};"

  # 一些gulp构建配置
  dataPath: './data'
  spriteDataPath: './data/sp.map.json'
  # spriteHasPath: './data/sp.has.json'

  jsLibPath: '../' + srcPath + '/js/vendor/'
  docOutPath: '../' + srcPath + '/doc/'
  imgSrcPath: '../' + srcPath + '/_img/'

  # 文件构建的生产目录
  cssDistPath: '../' + distPath + '/css/'
  jsDistPath: '../' + distPath + '/js/'
  tplDistPath: '../' + distPath + '/js/'
  imgDistPath: '../' + distPath + '/img/'
  spriteDistPath: '../' + distPath + '/img/sp/'
  cssBgDistPath: '../' + distPath + '/img/bg/'

  # 文件构建的Debug目录
  cssOutPath: '../' + srcPath + '/_css/'
  jsOutPath: '../' + srcPath + '/_js/'
  tplOutPath: '../' + srcPath + '/js/_tpl/'
  
  # 文件构建的源码目录
  lessPath: '../' + srcPath + '/less/'
  jsSrcPath: '../' + srcPath + '/js/'
  tplSrcPath: '../' + srcPath + '/tpl/'
  # tplJsSrcPath: path.join(st_root, 'tpl/')
  spriteSrcPath: '../' + srcPath + '/sprite/'
  spriteLessOutPath: '../' + srcPath + '/less/sprite/'
  spriteImgOutPath: '../' + srcPath + '/_img/sp/'

  # Hash Map path
  mapPath: '../' + distPath + '/map/'
  jsMapName: 'jsmap.json'
  jsDistMapName: 'jslibs.json'
  cssMapName: 'cssmap.json'
  cssBgMap: 'cssbgmap.json'
  
  # 一个大坑啊。。。
  watchFiles: [
      '../' + srcPath + '/js/**/*.js'
      '../' + srcPath + '/sprite/**/*.png'
      '../' + srcPath + '/less/**/*.less'
      '../' + srcPath + '/tpl/**/*.html'
      '../' + srcPath + '/'+ viewsDir + '**/*.html'
      '!../' + srcPath + '/**/.DS_Store'
    ]
