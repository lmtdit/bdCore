###
# FE build config
# @date 2014-12-2 15:10:14
# @author pjg <iampjg@gmail.com>
# @link http://pjg.pw
# @version $Id$
###

path  = require 'path'
butil = require './lib/butil'

st_root = path.join __dirname

viewsDir = 'html/'
cfg   = butil.getJSONSync('config.json')
srcPath = cfg.srcPathName
distPath = cfg.distPathName

# html模板路径
htmlTplDist = cfg.htmlTplDist

# 开发环境下，请求静态资源的域名
cndDomain = cfg.cndDomain

module.exports = 
  # 开发环境
  evn: cfg.evn

  # 是否开启在线combo
  isCombo: cfg.isCombo

  # 项目的主目录
  rootPath: st_root
  theme: srcPath

  # PHP的模板路径
  views: viewsDir
  htmlTplSrc: path.join "..",srcPath,viewsDir
  htmlTplDist: htmlTplDist

  # js文件前缀
  prefix: cfg.jsPrefix
  # 生产文件的hash长度
  hashLength: cfg.hashLength

  # 核心js
  coreJsName: cfg.jsPrefix + cfg.coreJs.name
  coreJsMods: cfg.coreJs.mods

  staticRoot: "http://" + cndDomain + "/"
  staticPath: "http://" + cndDomain + "/" + srcPath + "/"
  cndStaticPath: "http://" + cndDomain + "/" + distPath + "/"
  GLOBALVAR: "var STATIC_PATH='http://#{cndDomain}/" + (if cfg.evn is "dev" then srcPath else distPath) + "',VARS=window['VARS']={},_VM_=window['_VM_']={};\n"
  # 一些gulp构建配置
  dataPath: './data'
  spriteDataPath: './data/sp.map.json'
  spriteHasPath: './data/sp.has.json'

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
  jsMapName : 'jsmap.json'
  cssMapName : 'cssmap.json'
  # spMapName : 'spmap.json'
  cssBgMap : 'cssbgmap.json'
  jsLibsMapName : 'jslibs.json'
  jsDistMapName : 'jslibs.json'

  # 一个大坑啊。。。
  watchFiles: [
      '../' + srcPath + '/js/**/*.js'
      '../' + srcPath + '/sprite/**/*.png'
      '../' + srcPath + '/less/**/*.less'
      '../' + srcPath + '/tpl/**/*.html'
      '../' + srcPath + '/'+ viewsDir + '**/*.html'
      '!../' + srcPath + '/**/.DS_Store'
    ]
