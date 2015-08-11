// Generated by CoffeeScript 1.9.3

/*
 * 服务端PHP模板构建和压缩模块
 */
var _, _buildTpl, _hashMaps, _htmlMinify, _replaceImg, butil, color, common, config, errrHandler, fs, getJSONSync, gulp, gutil, path, plumber;

fs = require('fs');

path = require('path');

_ = require('lodash');

gulp = require('gulp');

plumber = require('gulp-plumber');

gutil = require('gulp-util');

config = require('./config');

butil = require('./butil');

getJSONSync = butil.getJSONSync;

errrHandler = butil.errrHandler;

color = gutil.colors;

common = require('./common');

_hashMaps = common.hashMaps;

_replaceImg = common.replaceImg;

_htmlMinify = common.htmlMinify;

_buildTpl = function(data) {
  var _name, _outputPath, _path, _source, e;
  try {
    _path = String(data.path).replace(/\\/g, '/');
    if (_path.indexOf(config.srcPath + "/tpl_php") === -1) {
      return false;
    }
    _name = _path.split(config.srcPath + "/tpl_php")[1];
    _outputPath = path.join(config.phpTplPath, _name);
    _source = _replaceImg(String(data.contents));
    _source = _htmlMinify(_source);
    butil.mkdirsSync(path.dirname(_outputPath));
    return fs.writeFileSync(path.join(_outputPath), _source, 'utf8');
  } catch (_error) {
    e = _error;
    return console.log(e);
  }
};

module.exports = function(file, cb) {
  var files, opts;
  if (typeof file === 'function') {
    files = config.phpSrcPath + "**/*.php";
    cb = file;
  } else {
    files = file || (config.phpSrcPath + "**/*.php");
    cb = cb || function() {};
  }
  gutil.log(color.yellow("Combine php templates..."));
  opts = {
    prefix: '@@',
    basepath: '@file',
    staticPaths: {
      css: {
        src: config.cssOutPath,
        dist: config.cssDistPath
      },
      js: {
        src: config.jsOutPath,
        dist: config.jsDistPath
      }
    },
    hashmap: _hashMaps
  };
  return gulp.src([files]).pipe(plumber({
    errorHandler: errrHandler
  })).on("data", function(_data) {
    return _buildTpl(_data);
  }).on("end", function() {
    gutil.log(color.green("Php templates done!"));
    return cb();
  });
};