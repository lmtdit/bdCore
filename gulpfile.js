// Generated by CoffeeScript 1.9.1

/*
#
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
  return build.js2dist();
});

gulp.task('sp', function() {
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


/*
 * push all files to dist
 */

gulp.task('all2dist', function() {
  return build.all2dist();
});


/*
 * Injecting static files relative to PHP-tpl files
 */

gulp.task('html2dist', function() {
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
    cmd.push('start gulp dev');
    return fs.writeFileSync(path.join(__dirname, '..', 'startGulp.cmd'), cmd.join('\r\n'));
  } else {
    sh = ['#!/bin/sh'];
    shFile = path.join(__dirname, '..', 'startGulp.sh');
    sh.push('cd ' + __dirname);
    sh.push('gulp dev');
    fs.writeFileSync(shFile, sh.join('\n'));
    return fs.chmodSync(shFile, '0755');
  }
});


/*
 * watch tasks
 */

gulp.task('watch', function() {
  return build.autowatch(function() {});
});


/*
 * dev task
 */

gulp.task('default', [], function() {
  return setTimeout(function() {
    return build.sprite(function() {
      return build.less2css(function() {
        return build.bgMap(function() {
          return build.jsLibs(function() {
            return build.config(function() {
              return build.tpl2dev(function() {
                return build.js2dev(function() {
                  return build.htmlctl(function() {
                    return setTimeout(function() {
                      return gulp.start(['watch']);
                    }, 2000);
                  });
                });
              });
            });
          });
        });
      });
    });
  }, 100);
});


/*
 * release
 */

gulp.task('release', ['del.dist'], function() {
  return setTimeout(function() {
    return build.sprite(function() {
      return build.less2css(function() {
        return build.bgMap(function() {
          return build.css2dist(function() {
            return build.jsLibs(function() {
              return build.config(function() {
                return build.tpl2dev(function() {
                  return build.js2dev(function() {
                    return build.js2dist(function() {
                      return build.htmlctl(function() {
                        return gutil.log(color.green('Finished Release!'));
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  }, 100);
});
