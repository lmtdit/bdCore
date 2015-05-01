// Generated by CoffeeScript 1.9.1

/**
 * FEbuild
 * @date 2014-12-2 15:10:14
 * @author pjg <iampjg@gmail.com>
 * @link http://pjg.pw
 * @version $Id$
 */
var autowatch, binit, butil, color, config, cssToDist, cssbd, flctl, fs, gutil, htmlCtl, htmlToJs, jsCtl, jsToDev, path;

fs = require('fs');

path = require('path');

config = require('../config');

gutil = require('gulp-util');

color = gutil.colors;


/*引入自定义模块 */

binit = require('./binit');

butil = require('./butil');

flctl = require('./flctl');

cssbd = require('./cssbd');

cssToDist = require('./cssto');

jsToDev = require('./jsto');

jsCtl = require('./jsctl');

htmlToJs = require('./html2js');

htmlCtl = require('./htmlctl');

autowatch = require('./autowatch');


/*
 * ************* 构建任务函数 *************
 */


/*初始化目录 */

exports.init = function() {
  binit.dir();
  return binit.map();
};


/*文件删除操作 */

exports.files = {
  delJson: function() {
    var file, files, i, json_file, len, results;
    files = ['jslib.paths', 'sp.map'];
    results = [];
    for (i = 0, len = files.length; i < len; i++) {
      file = files[i];
      json_file = path.join(config.dataPath, file + '.json');
      if (fs.existsSync(json_file)) {
        results.push(fs.unlinkSync(json_file));
      } else {
        results.push(void 0);
      }
    }
    return results;
  },
  delDistCss: function() {
    var _ctl;
    _ctl = new flctl('.css');
    return _ctl.delList();
  },
  delDistSpImg: function() {
    var _ctl;
    _ctl = new flctl('.png');
    return _ctl.delList();
  },
  delDistJs: function() {
    var _ctl;
    _ctl = new flctl('.js');
    return _ctl.delList();
  },
  delMap: function() {
    var _ctl;
    _ctl = new flctl('.json');
    return _ctl.delMap();
  },
  delDistFiles: (function(_this) {
    return function() {
      exports.files.delDistCss();
      exports.files.delDistSpImg();
      return exports.files.delDistJs();
    };
  })(this)
};


/*
 * Pngs combine into less and one image
 */

exports.sprite = cssbd.sp2less;


/*
 * 生成背景图的map
 */

exports.bgMap = binit.bgmap;


/*
 * LESS into CSS
 */

exports.less2css = cssbd.less2css;


/*
 * 生成css的生产文件
 */

exports.css2dist = cssToDist;


/*
 * 生成js模块路径
 */

exports.cssPaths = function(cb) {
  cb = cb || function() {};
  return binit.paths('.css', cb());
};


/*
 * 生成第三方模块路径
 */

exports.jsLibs = binit.libs;


/*
 * 生成js模块路径
 */

exports.jsPaths = function(cb) {
  cb = cb || function() {};
  return binit.paths('.js', cb());
};


/*
 * 生成require config 和 ve_cfg
 */

exports.config = binit.cfg;


/*
 * 将html生成js模板
 */

exports.tpl2dev = function(cb) {
  var _cb;
  _cb = cb || function() {};
  gutil.log(color.yellow("Convert html to js"));
  fs.readdirSync(config.tplSrcPath).forEach(function(v) {
    var tplPath;
    tplPath = path.join(config.tplSrcPath, v);
    if (fs.statSync(tplPath).isDirectory() && v.indexOf('.') !== 0) {
      return htmlToJs(v);
    }
  });
  gutil.log(color.green("Convert success!"));
  return _cb();
};


/*
 * 合并AMD js模块到debug目录(./src/_js/)
 */

exports.js2dev = jsToDev;


/*
 * 将debug目录中AMD js包文件push到生产目录
 */

exports.js2dist = new jsCtl.dist().init;


/*
 * all file to dist
 */

exports.all2dist = function(cb) {
  var _cb;
  _cb = cb || function() {};
  return exports.css2dist(function() {
    gutil.log(color.green('CSS pushed!'));
    return exports.js2dist(function() {
      gutil.log(color.green('JS pushed!'));
      return _cb();
    });
  });
};

exports.htmlctl = htmlCtl;


/*
 * Auto watch API
 */

exports.autowatch = autowatch;