# 前端自动化开发和部署框架说明
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
  "evn":"dev", // 申明环境变量，预设值为 `dev` 和 `debug`，如果是其他值，则为`release`
  "isCombo":false, // 是否开启`combo`机制，需要配合在线的`combo`服务器，目前此值暂未使用
  "cndDomain":"static.path", //CDN域名，不同的环境需要配置不同的域名
  "srcPathName":"_src", // 静态资源的源码目录
  "distPathName":"assets", // 静态资源的输出目录
  "htmlTplDist": "../html/", //HTML DEMO文件的输出目录
  "coreJs":{
      "mods":["jquery","smcore","cookie"], //指定js核心库的模块
      "name":"corelibs" //js核心库的文件名
  },
  "jsPrefix":"sb.", //JS模块打包后的前缀
  "hashLength":12 //静态生产文件的MD5戳的截取长度
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
 Tasks for gulpfile.js
   ├── init //用于前端项目的初始化
   ├── del.data //删除构建过程的缓存数据
   ├── del.dist //清理自动构建的静态文件[生产文件]
   ├── jslibs //生产js的第三方库列表，用户构建require.config的paths对象
   ├── cfg //生成require.config
   ├── tpl //将html模板构建成为JS模块，即html转化为AMD规范的js文件
   ├── js2dev //匿名的AMD模块构建为具名的AMD模块，并发布到源码的缓存目录[_src/_js/]，供本地调用
   ├── js2dist //按AMD规范的js模块转化为原生的js，并按依赖顺序COMBO成1个文件，然后发布到生产目录，生成2份代码
   ├── sp //合并生产雪碧图和对应了LESS
   ├── bgmap //所有css将用到背景图[包括自动生产的雪碧]生产一份hash map（json文件）
   ├── less //将less输出为css，并发布到源码的缓存目录[_src/_css/]，供本地调用
   ├── css //将缓存目录中的css压缩并自动将引用背景图加上MD5戳，然后发布到生产目录
   ├── all2dist //css和js源码的缓存目录中的文件发布到生产目录
   ├── html2dist //将模块化的静态html文件构建成一个静态可使用的html demo（img scr的引用图片替换为带MD5戳）
   ├── tool //生快速启动gulp构建工具的批处理
   ├── watch //gulp的watch任务，可快速启动开发者模式
   ├── default //默认任务，构建完成后进入开发模式
   └─┬ release //发布任务，构建完成后退出gulp
     └── del.dist
```

#### **命令使用说明**

**项目初始化**
```
gulp init
```

根据 `build/config.json` 中的配置，项目初始化后会生成如下的目录结构：

```
├── build
    ├── bin // shell执行命令目录
    ├── data // 第三方JS模块目录
    ├── lib // 核心的构建方法 
    ├── config.js // 开发配置文件
    ├── config.json // 项目构建的配置入口文件
    ├── gulpfile.js // gulp启动配置入口文件
    └── package.json // nodeJS依赖安装的包管理文件
├──_src //静态源码目录，原则上，这个目录中的所有资源是不需要发布到预发布及生产环境的
    ├──_css //本地debug的缓存目录
    ├──_js //本地debug的缓存目录
    ├──_img //本地debug的缓存目录
    ├──html //后端html模板的构建目录，支持后端模板引擎语言，如smarty
    ├──js //js源码，AMD模块规范
    ├──less //CSS的less源码目录
    ├──sprite //雪碧图的源码目录
    └──tpl //前端MVVM引擎的模板源码目录，开发维护的是html，但生产时会被封装成ADM规范的js模块
├── asset //前端资源的生产目录，根据config.json的配置来定
    ├──css  //带hash的css文件，保存压缩版和源码版两个版本
    ├──js  //带hash的css文件，保存压缩版和源码版两个版本
    ├──img //图片资源目录
    ├   ├──bg //css中用到的单个背景图的hash格式输出目录，自动构建
    ├   └──sp //css中用到的雪碧图的hash格式输出目录，自动构建
    └──map  //保存css、js以及雪碧图的hash的map
```

默认启动开发模式
```
gulp
```

发布
```
gulp release
```
