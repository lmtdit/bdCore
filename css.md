# CSS开发规范

> **为了使我们的代码风格统一，便于大家阅读，以及代码的复用，在此约定一下CSS的开发规范**

-------------------

[TOC]


### 文件编码约定
 - **所有文件一律采用utf-8编码**

### id 和 class 命名约定
 - id 和 class 的命名总规则为： **内容优先,表现为辅. 首先根据内容来命名, 比如 m-nav. 如果根据内容找不到合适的命名, 可以再结合表现来定, 比如 m-blue, m-tab, m-main.**
 - class 名称一律小写, 多个单词用连字符连接, 比如 recommend-presents.
 - class 名称中只能出现小写的 26 个英文字母、数字和连字符(-), 任何其它字符都严禁出现.
 - id的命名采用驼峰命名法，首字母小写，如：mainNav
 - 仅在 JavaScript 代码中当作 hook 用的 id 或 class, 命名规则为 J_UpperCamelCase``(请注意, ``J_ 后的首字母也大写！), 其中字母 J 代表 JavaScript, 也是钩子(hook)的象形.
    - *注意：如果在 JavaScript 和 CSS 中都需要用到, 则不用遵守本约定*
 - id 和 class 尽量用英文单词命名.确实找不到合适的单词时, 可以考虑使用产品的中文拼音。
    - 比如 wangwang, dating. 对于中国特色词汇可以使用拼音, 比如 xiaobao, daigou.
    - 除了产品名称和特色词汇, 其它任何情况下都严禁使用拼音.
 - 在不影响语义的情况下, id 和 class 名称中可以适当采用英文单词缩写, 比如 col, nav, hd, bd, ft 等, 但切忌自造缩写.（常用缩写总结在css规范部分）
 - id 和 class 名称中的第一个词必须是单词全拼或语义非常清晰的单词缩写, 比如 present, col.
 - 在自动化测试脚本中当作 hook 用的 class, 命名规则为 T_UpperCamelCase, 其中字母 T 代表 Test.

### 基本规范
 - 模块命名要注意带上模块名，下面尽可能的简写，页面级（app应用级）命名应该尽量简洁;
 - 尽可能地使用css-sprite
 - 尽量通过class属性定义样式,将id留给hook
 - 尽量不要在css中使用expression
 - 组件开发中，可以先不考虑性能，尽量使用选择符组以方便html调用，如.table-ctrl tbody tr td.selected{}；
 - font中的字体用英文或unicode代替,如黑体可写成SimHei：font: 12px/1.5 SimHei ,tahoma,arial,\5b8b\4f53,sans-serif;
 
 -------
 
**省略值为0时的单位**

 - 为节省不必要的字节同时也使阅读方便，我们将0px、0em、0%等值缩写为0。
```css
.m-box{margin:0 10px;background-position:50% 0;}
```
**私有在前，标准在后**
- 先写带有浏览器私有标志的，后写W3C标准的。
```css
.m-box{-webkit-box-shadow:0 0 0 #000;-moz-box-shadow:0 0 0 #000;box-shadow:0 0 0 #000;}
```

**建议并适当缩写值**

- “建议并适当”是因为缩写总是会包含一系列的值，而有时候我们并不希望设置某一值，反而造成了麻烦，那么这时候你可以不缩写，而是分开写。
- 当然，在一切可以缩写的情况下，请务必缩写，它最大的好处就是节省了字节，便于维护，并使阅读更加一目了然。
如：
```css
/*背景*/
background:#FFF url('divcss5.gif') repeat-x bottom;
/*外补白属性*/ 
margin:8px 6px 7px 5px;
/*内补白属性*/
padding:8px 6px 7px 5px;
/*边框属性*/
border:1px solid #000;
/*字体属性*/
font:italic small-caps bold 12px/22px "黑体";
```

### CSS引用
 - 统一以link形式引入
 - 不推荐内嵌形式引入css
 - 不推荐<style></style>标签出现在body中，特定页面（比如404错误页）除外。
 - 不推荐内联CSS，请尽量放在head标签内

### 常用CSS属性顺序建议
遵循横向顺序即可，先显示定位布局类属性，后盒模型等自身属性，最后是文本类修饰类属性
| 显示属性   | 自身属性  |文本属性和其它修饰 |
| :-------- | :--------| :-----------  |
| display   | width    | font          |
| position  | height   | text-align    |
| float     | margin   | text-decoration|
| visibility| padding  | vertical-align|
| clear     | border   | white-space   |
| list-style| overflow | color         |
| top       | min-width| background    |

###命名规则
- 重置（reset）: 消除默认样式和浏览器差异
- 布局（grid）``(.g-)`` : 将页面分割成几大块，通常有头部、主体、侧栏目、尾部等
- 模块（module）``(.m-)``：通常是一个语义化的可能重复使用较大的整体。比如导航、登录、注册、各种列表、搜索等
- 元件（unit）``(.u-) ``： 通常是一个不可再分的较小巧的个体，能被重复用于各种模块中！比如按钮、输入框、loading、图标等
- 功能（function）``(.f-)`` ：为方便一些常用样式的使用，我们将这些使用率较高的样式剥离出来，按需要使用，通常这些可作为组件存在
- 状态``（.z-）``为状态类样式加入前缀，统一标识，方便识别。它只能组合使用或者作为后代出来（.m-list .z-dn）

-----------
**分类命名方法: 使用单个字母+"-"为前缀**
- 在你的样式中的选择器总是要以上面命名规则命名，然后在里面使用后代选择器
- 如果这上面的类别不能满足你，你可以另外定义一个或多个大类，但必须符合单个字母+"-"为前缀的命名规则，即 .x- 的格式
- 特殊：.J_被用于JS获取节点，请勿使用.J_定义样式

**后代选择器命名**
-  约定不以单个字母+"-"为前缀且长度大于等于2的类选择器为后代选择器，如：.item为m-list模块里的每一个项，.text为m-list模块里的文本部分：``.m-list .item{}.m-list .text{}``。
-  一个语义化的标签也可以是后代选择器，比如：``.m-list li{}``。
-  不允许单个字母的类选择器出现，原因详见下面的“模块和元件的后代选择器的扩展类”。
- 通过使用后代选择器的方法，``不需要考虑他的命名是否已被使用``，因为他只在当前模块中生效，同样的样式名可以在不同的模块中重复使用，互不干扰；在多人协作或者分模块协作的时候效果尤为明显！如最常用的``.btn、.hd、.bd`` 在页面中多次使用，但又想不互相影响，那么只能使用后代选择器的方式对它进行样式操作如：``.m-tab .hd{} 、.m-tab .bd{}``

**防止污染和被污染**
- 当模块之间互相嵌套，且使用了相同的标签选择器或其他后代选择器，那么里面的选择器就会被外面相同的选择器所影响。
-  所以，如果你的模块可能嵌套或被嵌套于其他模块，那么要慎用标签选择器，必要时采用类选择器，并注意命名方式，可以采用``.m-layer .layerxxx、.m-list2 .list2xxx``的形式来降低后代选择器的污染性。

### 统一语义理解和命名
可使用直接语义命名或者简写方式
- 布局 (.g-)   
| 语义    | 命名  |  简写  |
| :------| :-----| :----- |
|文档  |doc    | doc    |
|头部  |head   | hd     |
|主体  |body   | bd     |
|尾部  |foot   |ft      |
|主栏  |main   |mn      |
|主栏子容器|mainc     |mnc     |
|侧栏  |side   |sd      |
|侧栏子容器|sidec     |sdc     |
|盒容器     |container/wrap/box|container/wrap/box|

-  模块（.m-）、元件（.u-）
| 语义    | 命名  |  简写  |
| :------| :-----| :-----|
| 导航    |nav    |nav    |
| 子导航  |subnav |snav   |
|面包屑   |crumb  |crm    |
|菜单     |menu   |menu   |
|选项卡   |tab    |tab    |
|标题区   |head/title| hd/tt |
|内容区   |body/content|bd/ct|
|列表    |list    |list|
|表格    |table   |tb     |
|表单    |form   |fm     |
|热点    |hot     |hot    |
|排行    |top     |top    |
|登录    |login   |log    |
|注册    |regist  |reg    |
|标志    |logo    |logo   |
|广告    |advertise|ad    |
|搜索    |search  |sch    |
|幻灯    |slide   |sld    |
|提示    |tips    |tips   |
|帮助    |help    |help   |
|新闻    |news    |news   |
|下载    |download |dld   |
|结果    |result   |rst   |
|版权    |copyright|cprt  |
|按钮    |button   |btn   |
|输入    |input    |ipt   |

-  状态（.z-）
|语义  |命名   |简写   |
|:------ |:------  |:------  |
|选中  |selected|sel  |
|当前  |current |crt  |
|显示  |show    |show |
|隐藏  |hide    |hide |
|打开  |open    |open |
|关闭  |close   |close|
|出错  |error   |err  |
|不可用|disabled|dis  |

### 注释风格
```css
    /*头注释*/
    /*------------------------------------------------
    @Filename:  main.css
    @Description:   全局css定义
    @Version:   1.0.0(2014-7-4)YYYY-MM-DD
    @author:    someone
    @updatatime:
    ------------------------------------------------*/

    /*区块*/

    /*__header
    ------------------------------------------------*/

    /*__menu
    ------------------------------------------------*/
```
