// Generated by CoffeeScript 1.9.1

/*
 * @date 2014-12-2 15:57:21
 * @author pjg <iampjg@gmail.com>
 * @link http://pjg.pw
 * @version $Id$
 */
var build, color, config, cp, exec, fs, gulp, gutil, path;

gulp = require('gulp');

fs = require('fs');

path = require('path');

build = require('./lib/build');

config = require('./config');

gutil = require('gulp-util');

color = gutil.colors;

cp = require('child_process');

exec = cp.exec;


/*
 * Initialization program
 */

gulp.task('init', function() {
  build.init();
  return exec("gulp -T", function(error, stdout, stderr) {
    return console.log(stdout);
  });
});


/*
 * clean files
 */

gulp.task('del.data', function() {
  return build.files.delJson();
});

gulp.task('del.dist', function() {
  return build.files.delDistFiles();
});


/*
 * build sprite,less,css,js,tpl...
 */

gulp.task('jslibs', function() {
  return build.jsLibs();
});

gulp.task('jspaths', function() {
  return build.jsPaths();
});

gulp.task('cfg', function() {
  return build.config();
});

gulp.task('tpl', function() {
  return build.tpl2dev();
});

gulp.task('js2dev', function() {
  return build.js2dev();
});

gulp.task('js2dist', function() {
  return build.js2dist(function() {
    return build.noamd(function() {});
  });
});

gulp.task('noamd', function() {
  return build.noamd();
});

gulp.task('corejs', function() {
  return build.corejs();
});

gulp.task('sprite', function() {
  return build.sprite();
});

gulp.task('bgmap', function() {
  return build.bgMap();
});

gulp.task('less', function() {
  return build.less2css();
});

gulp.task('css', function() {
  return build.bgMap(function() {
    return build.css2dist();
  });
});

gulp.task('map', function() {
  return build.json2dist(function() {
    return build.json2php();
  });
});


/*
 * push all files to dist
 */

gulp.task('all', function() {
  return build.all2dist();
});


/*
 * html demo files
 */

gulp.task('html', function() {
  return build.htmlctl();
});


/*
 * build bat tool
 */

gulp.task('tool', function() {
  var cmd, disk, rootPath, sh, shFile;
  rootPath = path.join(__dirname);
  disk = rootPath.split('')[0];
  if (disk !== '/') {
    cmd = [disk + ':'];
    cmd.push('cd ' + rootPath);
    cmd.push('start gulp');
    return fs.writeFileSync(path.join(__dirname, '..', 'startGulp.cmd'), cmd.join('\r\n'));
  } else {
    sh = ['#!/bin/sh'];
    shFile = path.join(__dirname, '..', 'startGulp.sh');
    sh.push('cd ' + __dirname);
    sh.push('gulp');
    fs.writeFileSync(shFile, sh.join('\n'));
    return fs.chmodSync(shFile, '0755');
  }
});


/*
 * watch tasks
 */

gulp.task('watch', function() {
  return build.autowatch(function() {
    var _gitTimer;
    if (_gitTimer) {
      clearTimeout(_gitTimer);
    }
    return _gitTimer = setTimeout(function() {
      var disk, rootPath;
      rootPath = path.join(__dirname);
      disk = rootPath.split('')[0];
      if (disk !== '/') {
        return exec('cmd ./bin/autogit.bat', function(error, stdout, stderr) {
          return console.log(stdout);
        });
      } else {
        return exec('sh ./bin/autogit.sh', function(error, stdout, stderr) {
          return console.log(stdout);
        });
      }
    }, 3000);
  });
});


/*
 * release
 */

gulp.task('clean', function() {
  build.files.delDistFiles();
  return build.corejs();
});


/*
 * dev task
 */

gulp.task('default', [], function() {
  return setTimeout(function() {
    return build.less(function() {
      return build.js(function() {
        return build.htmlctl(function() {
          var _Timer;
          if (_Timer) {
            clearTimeout(_Timer);
          }
          return _Timer = setTimeout(function() {
            return gulp.start(['watch']);
          }, 2000);
        });
      });
    });
  }, 100);
});


/*
 * release all
 */

gulp.task('release', [], function() {
  return setTimeout(function() {
    return build.less(function() {
      return build.js(function() {
        return build.css2dist(function() {
          return build.js2dist(function() {
            return build.noamd(function() {
              return build.demoAndMap(function() {
                return gutil.log(color.green('Release finished!'));
              });
            });
          });
        });
      });
    });
  }, 100);
});


/*
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
 */
