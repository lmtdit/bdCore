# sm前端自动化开发和部署框架说明
--------------------------
by Pang.J.G


## 1.前端开发工具的安装和使用说明
----------------------

本项目基于nodejs环境下的Gulp.JS


### 安装

* 前往 [http://nodejs.org/](http://nodejs.org/) 安装nodeJS
   - 注意系统是32位还是64位的，选择对应的版本
   - 如果是windows系统，需自行设置好环境变量，将nodejs的路径加入到系统的 `path` 环境变量中

* 安装 `gulp` 全局支持，在终端执行 `npm install -g gulp`

* 安装build的依赖：进入build的目录，执行 `npm install`

* 升级自动化工具：进入build的目录，执行 `npm update`



### 前端开发工具的目录结构
```html
├── build
    ├── bin // shell执行命令目录
    ├── data // 第三方JS模块目录
    ├── lib // 核心的构建方法 
    ├── config.js // 开发配置文件
    ├── config.json // 项目构建的配置入口文件
    ├── gulpfile.js // gulp启动配置入口文件
    ├── package.json // nodeJS依赖安装的包管理文件
```

项目构建的配置入口文件 `build/config.json` 说明
```json
{
    "evn":"debug", // 申明环境变量，预设值为 `dev` 和 `debug`，如果是其他值，则为`release`
    "isCombo":false, // 是否开启`combo`机制，需要配合在线的`combo`服务器，目前此值暂未使用
    "cndDomain":"static.local", // CDN的服务器静态资源的路径
    "theme":"asset", // 项目构建的资源目录
    "htmlTplPath": "../demo", // 给后端使用的html模板目录
    "phpHashMapPath": "../demo/hashmap",  // 静态文件hash表的输出目录，暂未使用
    "jsPrefix":"sm.",
    "coreJsName":"core_libs",
    "indexJsName":"index_mod",
    "indexJsModuleID":"mods/index/main",
    "hashLength":10
}
```


### 自动化命令使用说明

> 以下操作，需进入 `build` 目录下执行

**查看自动化框架支持的项目构建命令**
```
$ gulp -T
```

本前端开发框架支持的命令如下
```log
Using gulpfile ~/www/v.builder/build/gulpfile.js
Tasks for ~/www/v.builder/build/gulpfile.js
  ├── init
  ├── del.data
  ├── del.dist
  ├── build.jslib
  ├── build.cfg
  ├── build.tpl
  ├── build.js
  ├── build.sp
  ├── build.less
  ├── build.map
  ├── css2dist
  ├── js2dist
  ├── all2dist
  ├── html2dist
  ├── tool
  ├── git
  ├── watch
  ├── default
  └─┬ release
    └── del.dist
```

#### **命令使用说明**

**项目初始化**
```
gulp init
```

根据 `build/config.json` 中的 "theme":"asset", 项目构建的资源目录
初始化后会生成如下的目录结构
```
├── build
    ├── bin // shell执行命令目录
    ├── data // 第三方JS模块目录
    ├── lib // 核心的构建方法 
    ├── config.js // 开发配置文件
    ├── config.json // 项目构建的配置入口文件
    ├── gulpfile.js // gulp启动配置入口文件
    └── package.json // nodeJS依赖安装的包管理文件
├── asset //前端的资源目录，根据config.json的配置来定
    ├──dist  //生产文件输出目录，内部的文件均自动构建而成，不需要开发人员手工维护
        ├──css  //带hash的css文件，保存最新的两个版本
        ├──js  //带hash的css文件，保存最新的两个版本
        └──map  //保存css、js以及雪碧图的hash的map
    ├──img //图片资源目录
        ├──bg //css中用到的单个背景图的hash格式输出目录，自动构建
        └──sp //css中用到的雪碧图的hash格式输出目录，自动构建
    ├──src //前端静态源码目录，原则上，这个目录中的所有资源是不需要发布到预发布及生产环境的
        ├──_css //本地debug的缓存目录
        ├──_js //本地debug的缓存目录
        ├──_img //本地debug的缓存目录
        ├──html //后端html模板的构建目录，支持后端模板引擎语言，如smarty
        ├──js //js源码，AMD模块规范
        ├──less //CSS的less源码目录
        ├──sprite //雪碧图的源码目录
        └──tpl //前端MVVM引擎的模板源码目录，开发维护的是html，但生产时会被封装成ADM规范的js模块

```

默认启动开发模式
```
gulp
```

发布
```
gulp release
```


