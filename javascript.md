# JavaScript编程规范


`BY Pang.J.G`

------------------
[TOC]

##一、javascript项目的目录结构
AMD的模块定义是和目录结构相结合的，因此书写AMD模块必须清楚javascript项目的目录结构。

  原则：带 `_`前缀的模块目录，内部的AMD模块都必须是一个接口。

``` js
  _src // DEMO的前端源码目录
  ├──_js //本地debug的缓存目录
  ├──js //js源码，AMD模块规范
     ├──_base //smcore.js的扩展功能库
       ├──animate.js
       ├──class.js
       └── ...
     ├──_data //对端API输出数据进行二次封装的接口模块
       ├──ibar.js
       └── ...
     ├──_lib //jQuery的常用插件模块，必须进行AMD规范改造
       ├──lazyload.js
       ├──slide.js
       └── ...
     ├──_tpl //前端MVVM需要用到的经过js化的模板 [自动生成]
       ├──ggmod.js
       ├──header.js
       ├──ibar.js
       └── ...
     ├──_utils //自主扩展的一些功能插件
       ├──doajax.js
       └── ...
     ├──mods //项目的功能模块，以目录形式扩展
       ├──common //公共模块
         ├──header.js
         └── ...
       ├──ggmod //广告模块 [可能会用到tpl]
         ├──poptips.js
         └── ...
       ├──ibar //DEMO的侧边栏模块
         ├──main.js
         └──tplinit.js
       ├──index //DEMO的主模块
         ├──slider.js
         └──vmctrl.js
       └──index.js //DEMO主模块的入口文件
     └──vendor
       ├──cookie/cookie.js
       ├──jquery/jquery.js
       ├──require/require.js
       ├──smcore/smcore.js
       ├──underscore/underscore.js
       └── ...
  └──config.js //requireJS的config配置文件
```

##二、AMD模块的书写规范

由于在前端自动化构建过程中，javascript部分的开发均基于AMD规范，所有的javascript代码的书写均在AMD规范的基础上展开。因此，我们先了解清楚在开发中如何定义AMD模块。

###1. AMD 模块的 define
```js
define(id?, dependencies?, factory);

id - string，非必须
dependencies - Array，非必须
factory - Function | Object
```
从 define 的签名可以看到，id 和 dependencies 是可选的。扩展一下，define 总共有下面 4 种形式：
```js
define(factory);
define(id, factory);
define(dependencies, factory);
define(id, dependencies, factory);
```
###2. AMD模块 ID 的形式

模块 ID 可能会被用在 define 和 require 时。它是一个 string literal。在 AMD 里，对 ID 形式的要求和 CommonJS 是一样的。我列一些关键点（不全）：

- ID使用 `/` 分隔
- ID不包含文件的扩展名，比如 `.js`
- `.` 或 `..` 开头的叫做 `Relative` ID（相对ID）， 否则叫做 `Top-Level` ID（顶级ID）
- `define` 时，模块ID只允许使用 `Top-Level ID`，而模块的dependencies 
- `require` 时，可以使用 `Relative ID`，也可以使用 `Top-Level ID`

###3.我们的AMD模块书写规范

我们项目中将采用第1和3种 `define` 形式来定义 AMD 模块，并且不再使用 `require` 接口来执行模块的初始化，而是通过入口文件的形式来初始化。
```js
//Good
define(factory);
define(dependencies, factory);

//Bad
define(id, factory);
define(id, dependencies, factory);
```
####入口模块的书写格式

  1. define闭包内完成逻辑的执行
  2. 默认的初始化函数关键词是 init
  
```js
//Good
/*
 * mods/index: index模块的入口
 */
define(['../_lib/lazyload','./index/slider','./index/vmctrl'], function(lazyload, Slider, vmctrl) {
  var init;
  init = function() {
    //code..
  };
  init();
});

//Good
define(['../_lib/lazyload','./index/slider','./index/vmctrl'], function(lazyload, Slider, vmctrl) {
  (function() {
    //code..
  })();
});

//Bad
define(['../_lib/lazyload','./index/slider','./index/vmctrl'], function(lazyload, Slider, vmctrl) {
  var explorts = {};
  explorts.init = function() {
    //code..
  };
  //向外曝露接口
  return explorts;
});
require(['mods/index'],function(index){
  index.init();
});
```
####接口模块的书写格式

  1. difine闭包的最后返回一个对象
  2. 默认的接口对象关键词是 exports
  3. 如果是ViewModel接口，关键词则为 _VM_
  
```js
//Good
define(function() {
    var exports;
    exports = {};
    exports.get = function(url, datas, cb) {
        //code...
    };
    exports.post = function(url, datas, cb) {
        //code...
    };
    return exports;
});

//Bad
define(function() {
    var exports;
    exports = {};
    exports.doSome = function(){
      //code...
  };
  exports.doSome();
  
    exports.get = function(url, datas, cb) {
        //code...
    };
    exports.post = function(url, datas, cb) {
        //code...
    };
    return exports;
});

//Bad
define(function() {
    (function() {
        //code..
    })();

    get = function(url, datas, cb) {
        //code...
    };
    post = function(url, datas, cb) {
        //code...
    };
    return {
        get: get,
        post: post
    };
});
```

####为什么我们不要使用 `require` ？

所谓入口，就是页面的js逻辑由此进入就能完成执行，而不再向外曝露接口（不用return）。
如果我们采用由于入口文件也是一个曝露接口，那么页面中还需要通过 `require` 的回调中执行init方法才能完成逻辑的执行；

这个时候 `require` 请求的模块必须指定ID，不管相对的还是绝对的ID，都需要弄清楚 config.baseUrl的位置；

在生产端如果要把文件combo在一起的，如果采用这种通过require初始化页面逻辑的方案，一需要需要在页面或再建立一个单独文件来处理模块的初始化问题，为了避免这样的问题，因此我们采用 `define` 一个入口文件来启动页面逻辑的初始化工作。

###4. AMD模块依赖表的书写规范

- 除了 `vendor` 目录下的第三模块以`Top-Level ID`引入外，其他AMD模块的依赖模块统一使用相对路径，即`Relative ID`。
-  `vendor` 目录下的第三方模块的引入规则是每个目录允许放置一个文件，其 模块ID 就是它的目录名，构建工具会自动生成。 
-  `vendor` 引入第三模块必须谨慎，必须是支持AMD规范的第三库或框架。

```js
//Good
define(['../_lib/lazyload','./index/slider','./index/vmctrl'], function(lazyload, Slider, vmctrl) {
  var init;
  init = function() {
    //code..
  };
  init();
});

//Bad
define(['_lib/lazyload','mods/index/slider','../mods/index/vmctrl'], function(lazyload, Slider, vmctrl) {
  var init;
  init = function() {
    //code..
  };
  init();
});

//Bad
define('mods/index',['_lib/lazyload', './index/slider', './index/vmctrl'], function(lazyload, Slider, vmctrl) {
  var init;
  init = function() {
    //code..
  };
  init();
});
```

###6.AMD模块构建结果演示
```js
//mods_index模块的生产文件
;(function() {
  var lib_lazyload, lib_easing, lib_slide, mods_index_slider, utils_doajax, data_ibar, base_class, tpl_header, mods_common_header, tpl_ibar, mods_ibar_tplinit, mods_ibar_main, mods_index_vmctrl, mods_index;
  lib_lazyload = function() {
      //code..
  }();
  lib_easing = function() {
      //code..
  }();
  lib_slide = function(easing) {
      //code..
  }(lib_easing);
  mods_index_slider = function(slide) {
      //code..
  }(lib_slide);
  utils_doajax = function() {
      //code..
  }();
  data_ibar = function(doAjax) {
      //code..
  }(utils_doajax);
  base_class = function() {
      //code..
  }();
  tpl_header = {
      //code..
  };
  mods_common_header = function(smcore, Class, hdTpl) {
      //code..
  }(smcore, base_class, tpl_header);
  tpl_ibar = {
      //code..
  };
  mods_ibar_tplinit = function(Class, Tpl) {
      //code..
  }(base_class, tpl_ibar);
  mods_ibar_main = function(smcore, ibarTpl, getData) {
      //code..
  }(smcore, mods_ibar_tplinit, data_ibar);
  mods_index_vmctrl = function(smcore, getData, header, iBar) {
      //code..
  }(smcore, data_ibar, mods_common_header, mods_ibar_main);
  mods_index = function(lazyload, Slider, vmctrl) {
      //code..
  }(lib_lazyload, mods_index_slider, mods_index_vmctrl);
}());
```

##三、编程风格

### 1. 行末逗号对行首逗号


```js
//Good: 行末引号
var foo = 1,
    bar = 2,
    baz = 3;

var obj = {
    foo: 1,
    bar: 2,
    baz: 3
};

//Bad: 行首引号
var foo = 1
  , bar = 2
  , baz = 3;

var obj = {
    foo: 1
  , bar: 2
  , baz: 3
};
```


###2. 缩进使用空格和Tab

请将IDE或文本编辑器的缩进设置为4个空格

  使用空格缩进可以保证不同的开发者、不同的编辑器设置下看到的结果是一样的。


###3. 函数后是否添加空格

```js
//Good: 无空格

function foo() {
  return "bar";
}

//Bad: 有空格
function foo () {
  return "bar";
}
```

###4. 参数与括号间是否有空格

```js
//Good: 无空格

function fn(arg1, arg2) {
  //  ...
}
if (true) {
  //  ...
}

//Bad: 有空格
function fn( arg1, arg2 ) {
   // ...
}
if ( true ) {
   // ...
}
```


###5. 对象字面量中冒号周围是否有空格

```js
//Good: 冒号后有空格

{
  foo: 1,
  bar: 2,
  baz: 3
}

//Bad: 冒号后无空格
{
  foo:1,
  bar:2,
  baz:3
}
//Bad: 冒号前后均有空格
{
  foo : 1,
  bar : 2,
  baz : 3
}
```

###6. 条件语句关键词与条件之间是否有空格

```js
// Good: 有空格
if (true) {
  //...
}
while (true) {
  //...
}
switch (v) {
  //...
}

//Bad: 无空格
if(true) {
  //...
}
while(true) {
  //...
}
switch(v) {
  //...
}
```


###7. 单引号、双引号

```js
//Good: 单引号
var str = 'test';
var el = $('.el');
if (a === 'b'){
}


//Bad: 双引号
var str = "test";
var el = $(".el");
if (a === "b"){
}
```

###小结

  1. 行末逗号
  2. 空格缩进
  3. 函数名称后无空格
  4. 函数参数与括号间无空格
  5. 对象字面量的冒号后加空格，冒号前不加
  6. 条件语句关键字后加空格


##四、命名规范


###1. 基本原则

  1. 尽量避免潜在冲突，见名知意；
  2. 如非无法避免，不能随意定义全局的变量；
  3. 请将闭包内用到的外部变量挂载在全局的对象下，即命名空间下。


###2. 命名通则

####常量全部大写，单词以下划线分隔
```js
//Good
var STATIC_PATH = 'http://pcs.shenba.com/_src';
var SB_DOMAIN = 'www.shenba.com';

//Bad
var staticPath = 'http://pcs.shenba.com/_src';
var sb_domain = 'www.shenba.com';
```

 ####类名首字母大写
```js
//Good
var ClassA = function(){};
var ClassB = function(){};
//Bad
var classA = function(){}
var classB = function(){}
```

####普通变量、方法和函数，采用驮峰式写法，首字母小写
```js
//Good
var userName = $('#user_name');
var msgCode = $('#msg_code');
 
//Bad
var username = $('#user_name');
var msgcode = $('#msg_code');

//Bad
var user_name = $('#user_name');
var msg_code = $('#msg_code');
```

####局部变量、私有变量、 私有属性和私有方法，名字以下划线开头
```js
var ClassFrom = function(){
  var _from = $('.reg-from');
  this.getUserName = function(){
    var _userName = _from.find('#user_name');
    return _userName;
  };
  this.getCode = function(){
    var _code = _from.find('#check_code');
    return _code;
  };
  //more code...
};
var newFrom = new ClassFrom();
var code = newFrom.getCode();
```

####条件表达式、正则表式式，如果很复杂，给其命名
```js
//Good
_stream = function(files, cb, cb2) {
  var _amdReg = /;?\s*define\s*\(([^(]*),?\s*?function\s*\([^\)]*\)/;
  var _depArrReg = /^[^\[]*(\[[^\]\[]*\]).*$/;
  //code...
  _source = _source.replace(_amdReg, function(str, map) {
    _depStr = map.replace(_depArrReg, "$1")
    //code...
  )}
};

//Bad
_stream = function(files, cb, cb2) {
  //code...
  _source = _source.replace(/;?\s*define\s*\(([^(]*),?\s*?function\s*\([^\)]*\)/, function(str, map) {
    _depStr = map.replace(/^[^\[]*(\[[^\]\[]*\]).*$/, "$1")
    //code...
  )}
};
```
  
###3. 三个全局的变量及其作用

本项目将自动在核心类库前自动插入以下几个变量：
```js
var STATIC_PATH = 'http://pcs.shenba.com/_src',
  VARS = window['VARS'] = {},
  _VM_ = window['_VM_'] = {};
```

#### ① STATIC_PATH
这是一个全局的常量，构建工具会根据环境的不同，自动生成对应环境的静态路径
```js
/* 
 * 比如我们本地的静态域名为 pcs.shenba.com，
 * 并且是开发模式（build/config.json的evn='dev'），那么
 */
var STATIC_PATH = 'http://pcs.shenba.com/_src';

/* 否则 */
var STATIC_PATH = 'http://pcs.shenba.com/assets'；
```

STATIC_PATH的使用方法：
```js
/* 
 * @desc
 * 在javascript中方便开发人员拼接需要请求的静态资源路径，比如图片；
 * 开发人员在拼接静态资源的地址，只需要考虑开发环境的地址，
 * 构建工具将自动将开发环境的地址替换为生产环境的地址
 * 例如：
 */
var indexMainBg = STATIC_PATH + '/_img/bg/mainbg.jpg'
var indexFooterBg = STATIC_PATH + '/_img/bg/footbg.jpg';

/*
 * 那么，release之后则是：
 */
var indexMainBg = STATIC_PATH + '/img/bg/mainbg.7ds2f2oui232.jpg';
var indexFooterBg = STATIC_PATH + '/img/bg/footbg.i837hue7nuf4.jpg';
```
#### ② VARS : 给局部变量预留的全局命名空间
VARS是一个全局对象变量，是给局部变量预留的全局命名空间。一般情况下，请将闭包内用到的外部变量挂载在这个全局的对象下。

比如，我们经常需要用到的各个AJAX地址：
```js
// Bad
var addCartUrl = 'http://www.xxx.com/?m=doajax&a=addcart';
var delGoodsUrl = 'http://www.xxx.com/?m=doajax&a=delgoods';

//Good
VARS.addCartUrl = 'http://www.xxx.com/?m=doajax&a=addcart';
VARS.delGoodsUrl = 'http://www.xxx.com/?m=doajax&a=delgoods';
```

#### ③ \_VM_ : 预留给前端MVVM的ViewModel对象的全局命名空间
由于前端将引入前端MVVM框架（smcore.js，二次开发自avalon），此MVVM框架引入了一个核心概念——ViewModel（用于控制视图的Model），由于以下的原因：

  1. 在一个页面中可能存在很多个不同的ViewModel；
  2. 同一个ViewModel可能需要在不同的AMD模块中重新进行赋值操作；
  3. 不同的ViewModel可能需要共享一些数据，甚至相互监控和数据绑定等。
  
因此，为了便于查找和操作页面中存在的ViewModel，我们约定将所有的ViewModel都挂载在一个全局的命名空间上，即 “\_VM_” 下。

\_VM_使用示例：

**定义\_VM_**
```js
define(['smcore', '../../_base/class', '../../_tpl/header', '../ggmod/poptips'], function(smcore, Class, hdTpl, Tips) {

    //此处省略一些 code...

    /*header_user的vm模型 */
    _VM_.header_user = smcore.define({
        $id: "header_user",
        //此处省略一些 code...
    });

    /*header_cart按钮的vm模型 */
    _VM_.header_cart = smcore.define({
        $id: "header_cart",
        //此处省略一些 code...
    });

    // 返回的是全局对象，那么在全局环境下均可访问此对象
    return _VM_;
});

```

**使用\_VM_**
```js
define(['smcore', '../../_data/ibar', '../common/header', '../ibar/main'], function(smcore, getData, header, iBar) {
    var exports = {};
    exports.run = function(cb) {
        //此处省略一些 code...
        getData.cartList(function(data) {
            //给VM的对象赋值
            return _VM_.ibar.cartInfo = _VM_.header_cart.cartInfo = data;
        });
        getData.userInfo(function(data) {
            //给VM的对象赋值
            _VM_.ibar.userInfo = _VM_.header_user.userInfo = data;
            if (data.status === 1) {
                //给VM的对象赋值
                return _VM_.ibar.isLogin = _VM_.header_user.isLogin = true;
            }
        });
    };
    //此处省略一些 code...
    return exports;
});
```


##五、注释规范

gulp自动化构建的项目，利用gulp-jsDoc插件，就可以根据段落注释自动生成可读性很好的文档，因此前端开发必须按照 jsDoc 的规范来写了注释。

JSDoc注释使用JSDoc通过JS文件中的一些特殊JSDoc标记，解析文档。下面列出了可以创建HTML文档的一些特殊JSDoc标记。如果要在最后生成的文档中包含某个注释块，所有这些注释块都 `必须以 /** 开头，并以 */ 结束`。

###1. JSDoc 命令属性
|命令名|描述| 
|:--------|:--------------------|
|@param |形参
|@property ： 属性
|@argument | 指定参数名和说明来描述一个函数参数。 
|@description| 说明
|@example | 范例
|@return | 描述函数的返回值。
|@returns | 描述函数的返回值。
|@author | 指示代码的作者。 
|@version | 指定代码的版本。
|@type | 指定函数的返回类型。
|@deprecated | 指示一个函数已经废弃，不建议使用，而且在将来版本的代码中可能会彻底删除。要避免使用这段代码。 
|@function | 表示该变量指向一个函数或方法。
|@see | 创建一个HTML链接指向指定类的描述。 
|@requires | 创建一个HTML链接，指向这个类所需的指定类。
|@throws |
|@exception | 描述函数可能抛出的异常的类型。 
|@link | 创建一个HTML链接，指向指定的类。这与@see很类似，但{@link}能嵌在注释文本中。 
|@fileoverview | 这是一个特殊的标记，如果在文件的第一个文档块中使用这个标记，则指定该文档块的余下部分将用来提供文件的一个概述。 
|@class|提供类的有关信息，用在构造函数的文档中。
|@constructor|明确一个函数是某个类的构造函数。 
|@extends | 指示一个类派生了另一个类。通常JSDoc自己就可以检测出这种信息，不过，在某些情况下则必须使用这个标记。
|@public | 说明内在变量是公开的
|@private | 指示一个类或函数是私有的。私有类和函数不会出现在HTML文档中，除非运行JSDoc时提供了—private命令行选项。　 
|@ignore | JSDoc 会忽略有这个标记的函数。


###2. 注释的样例
eg1:
```js
/**
 * @fileOverview 功能接口调用
 * @author Pang.J.G
 * @constructor BlogJava.Data
 * @description [数据结构]命名空间
 * @see The <a href="http://www.example.com">Example Project</a>.
 * @param  {NULL_PARAMETER} objNull 
 * @param  {Function} [fnCallback="null"] :如果不是函数类型,则进行同步调用
 * @return {Boolean} json ：作为回调参数返回
 * @example new KxEFileMon.Data.NULL_PARAMETER("a")
 */
```
eg2:
```js
/**
 * @fileOverview 楼主信息描述
 * @author Pang.J.G
 */

/**
 * @constructor LzInfo
 * @description 自我介绍
 * @see The <a href="http://pjg.pw/">Pang.J.G</a >.
 * @example new LzInfo();
 */
function LzInfo() {
    /**
     * @description {String} 姓名
     * @field
     */
    this.Name = "PangJinGui";
    /**
     * @description 打招呼
     * @param {String} title  说话标题
     * @param {String} content 说话内容
     * @return {Num} nResult 返回结果
     */
    this.SayHello = function() {
        alert(arguments[0] + " my name is " + this.Name + arguments[1]);
    }
}
```

##THE END.