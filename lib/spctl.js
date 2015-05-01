// Generated by CoffeeScript 1.9.1

/**
 * 构建雪碧图的操作类库
 * @date 
 * @author pjg <iampjg@gmail.com>
 * @link http://pjg.pw
 * @version $Id$
 */
var _, __spBaseFn, _spBuilder, _spStatus, config, error, fs, path, spriteHasData, spriteMapData,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

fs = require('fs');

path = require('path');

config = require('../config');

_ = require('lodash');


/*
#上一次构建的雪碧图Map和hash
 */

spriteMapData = {};

spriteHasData = {};

try {
  spriteMapData = JSON.parse(fs.readFileSync(config.spriteDataPath, 'utf8'));
  spriteHasData = JSON.parse(fs.readFileSync(config.spriteHasData, 'utf8'));
} catch (_error) {
  error = _error;
}


/* 单个雪碧图的状态检查类库 */

_spStatus = (function() {
  function _spStatus(name1) {
    this.name = name1;
    this.getBuildMethod = bind(this.getBuildMethod, this);
    this.getSpPngSrcList = bind(this.getSpPngSrcList, this);
    this.spHasIsBuild = bind(this.spHasIsBuild, this);
    this.spPngIsBuild = bind(this.spPngIsBuild, this);
    this.spLessIsBuild = bind(this.spLessIsBuild, this);
  }

  _spStatus.prototype.spLessIsBuild = function() {
    var _spLessFile;
    _spLessFile = path.join(config.spriteLessOutPath, '_' + this.name + ".less");
    try {
      return fs.statSync(_spLessFile).isFile();
    } catch (_error) {
      error = _error;
      return false;
    }
  };

  _spStatus.prototype.spPngIsBuild = function() {
    var _sp_png;
    _sp_png = path.join(config.spriteImgOutPath, this.name + '.png');
    try {
      return fs.statSync(_sp_png).isFile();
    } catch (_error) {
      error = _error;
      return false;
    }
  };

  _spStatus.prototype.spHasIsBuild = function() {
    return _.has(spriteHasData, this.name);
  };

  _spStatus.prototype.getSpPngSrcList = function() {
    var _list, _pngPath;
    _list = [];
    _pngPath = path.join(config.spriteSrcPath, this.name);
    if (_pngPath.indexOf('.DS_Store') > -1) {
      return _list;
    }
    fs.readdirSync(_pngPath).forEach(function(file) {
      var pngFile;
      pngFile = path.join(_pngPath, file);
      if (file.indexOf('.') !== 0 && file.indexOf('.png') !== -1 && fs.statSync(pngFile)) {
        return _list.push(file);
      }
    });
    return _list;
  };


  /*
   * 返回雪碧图的生成算法 共三个：
   * 默认 binary-tree
   * 目录名的最后包含'_y'，即为Y轴，则为top-down
   * 目录名的最后包含'_x'，即为X轴，则为left-right
   */

  _spStatus.prototype.getBuildMethod = function() {
    var method;
    method = (function() {
      switch (false) {
        case !/_x$/.test(this.name):
          return 'left-right';
        case !/_y$/.test(this.name):
          return 'top-down';
        default:
          return 'binary-tree';
      }
    }).call(this);
    return method;
  };

  return _spStatus;

})();

__spBaseFn = (function() {
  function __spBaseFn() {}

  __spBaseFn.prototype.src_dir = config.spriteSrcPath;

  __spBaseFn.prototype.png_dist_dir = config.spriteImgOutPath;

  __spBaseFn.prototype.less_dist_dir = config.spriteLessOutPath;


  /*
   * 获取所有雪碧图的源目录
   */

  __spBaseFn.prototype.getAllSpFolders = function() {
    var _list;
    _list = [];
    fs.readdirSync(this.src_dir).forEach(function(v) {
      if (v.indexOf('.') !== 0) {
        _list.push(v);
      }
    });
    return _list;
  };


  /*
   * 获取已合成的雪碧图
   */

  __spBaseFn.prototype.getAllSpPngFiles = function() {
    var _list;
    _list = [];
    fs.readdirSync(this.png_dist_dir).forEach(function(v) {
      var name;
      if (v.indexOf('.png') !== -1) {
        name = v.replace(/^_/, '').replace('.png', '');
        _list.push(name);
      }
    });
    return _list;
  };


  /*
   * 获取已生成的雪碧图LESS
   */

  __spBaseFn.prototype.getAllSpLessFiles = function() {
    var _list;
    _list = [];
    fs.readdirSync(this.less_dist_dir).forEach(function(v) {
      var name;
      if (v.indexOf('.less') !== -1) {
        name = v.replace(/^_/, '').replace('.less', '');
        _list.push(name);
      }
    });
    return _list;
  };

  return __spBaseFn;

})();

_spBuilder = (function(superClass) {
  extend(_spBuilder, superClass);

  function _spBuilder() {
    this.buildSpriteMap = bind(this.buildSpriteMap, this);
    this.getAllNewBuildList = bind(this.getAllNewBuildList, this);
    this.getNewBuildLessFloders = bind(this.getNewBuildLessFloders, this);
    this.getNewBuildPngFolders = bind(this.getNewBuildPngFolders, this);
    return _spBuilder.__super__.constructor.apply(this, arguments);
  }


  /*
   * 获取需要生成雪碧图的目录
   */

  _spBuilder.prototype.getNewBuildPngFolders = function() {
    var _getPngs, _list, folder_name, i, len, newList, oldList;
    _list = [];
    newList = this.getAllSpFolders();
    oldList = this.getAllSpPngFiles();
    for (i = 0, len = newList.length; i < len; i++) {
      folder_name = newList[i];
      if (folder_name.indexOf('.') !== 0) {
        if (!spriteMapData.hasOwnProperty(folder_name) || indexOf.call(oldList, folder_name) < 0) {
          _list.push(folder_name);
        } else {

          /* 获取当前目录下的所有png文件 */
          _getPngs = new _spStatus(folder_name).getSpPngSrcList();
          if (spriteMapData[folder_name].length !== _getPngs.length) {
            _list.push(folder_name);
          }
        }
      }
    }
    return _list;
  };


  /*
   * 获取需要生成LESS的目录
   */

  _spBuilder.prototype.getNewBuildLessFloders = function() {
    var _list, folder_name, i, len, newList, oldList;
    _list = [];
    newList = this.getAllSpFolders();
    oldList = this.getAllSpLessFiles();
    for (i = 0, len = newList.length; i < len; i++) {
      folder_name = newList[i];
      if (indexOf.call(oldList, folder_name) < 0) {
        _list.push(folder_name);
      }
    }
    return _list;
  };


  /*
   * 获取需要生成雪碧图和LESS的目录
   */

  _spBuilder.prototype.getAllNewBuildList = function() {
    var _allFolders, _buildLessFolders, _buildSpPngFolders, _list, file, i, len;
    _buildLessFolders = this.getNewBuildLessFloders();
    _buildSpPngFolders = this.getNewBuildPngFolders();
    _allFolders = _buildLessFolders.concat(_buildSpPngFolders);
    _allFolders = _allFolders.sort();
    _list = [];
    for (i = 0, len = _allFolders.length; i < len; i++) {
      file = _allFolders[i];
      if (indexOf.call(_list, file) < 0) {
        _list.push(file);
      }
    }
    return _list;
  };


  /*
   * 生成雪碧图的目录结构地图
   */

  _spBuilder.prototype.buildSpriteMap = function() {
    var _allSpFolders, _mapData, folder, i, len;
    _mapData = {};
    _allSpFolders = this.getAllSpFolders();
    for (i = 0, len = _allSpFolders.length; i < len; i++) {
      folder = _allSpFolders[i];
      _mapData[folder] = new _spStatus(folder).getSpPngSrcList();
    }
    return _mapData;
  };

  return _spBuilder;

})(__spBaseFn);

exports.status = _spStatus;

exports.builder = _spBuilder;