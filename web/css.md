

[toc]

# 0x00 插入样式表

**外部样式表(External style sheet)**

```html
<head>
<link rel="stylesheet" type="text/css" href="mystyle.css">
</head>
```



**内部样式表(Internal style sheet)**

```html
<head>
<style>
hr {color:sienna;}
p {margin-left:20px;}
body {background-image:url("images/back40.gif");}
</style>
</head>
```



**内联样式(Inline style)**

```html
<p style="color:sienna;margin-left:20px">这是一个段落。</p>
```



!important 表示在规则例外



# 0x01 css语法

CSS 规则由两个主要的部分构成：选择器，以及一条或多条声明:

![](https://cdn.jsdelivr.net/gh/eaok/img/web/css/cssSyntax.jpg)

## 选择器

### 1. id选择器(ID selector)

`#id{}`，例如：`#firstname{}`表示选择所有id="firstname"的元素

```html
<style>
    #name{
      color:red;
    }
</style>

<p id="name">red text</p>
```



### 2. 类选择器(class selector)

`.class{}`，例如：`.intro{}`表示选择所有class="intro"的元素

```html
<style>
    .value{
      text-align:center;
    }
</style>

<!--下面的文字是居中对齐的-->
<p class="value">center text</p>
```



### 3. 元素选择器(element selector)

`element{}`，例如：`p{}`表示选择所有<p>元素

```html
<style>
    p{
      font-style:italic;
    }
</style>

<!--下面所有p标签下的文字都是是斜体的-->
<p>italic text</p>
<p>italic text</p>
```



### 4. 包含选择器(package selector)

`element element{}`，例如：`div p{}`表示选择<div>元素内的所有<p>元素

```html
<style>
    div p{
      color:red;
    }
</style>

<p>no red text</p>
<div>
  <p>red text</p>
  <table>
    <tr>
      <td>
        <p>red text</p>
      </td>
    </tr>
  </table>
</div>
```

还可以有这种形式：`.class element{}` 

```html
<style>
    .dd p{
      color:red;
    }
</style>

<p>no red text</p>
<div class="dd">
  <p>red text</p>
  <table>
    <tr>
      <td>
        <p>red text</p>
      </td>
    </tr>
  </table>
</div>
```



### 5. 子选择器(sub-selector)

`element>element{}`，例如：`div>p{}`表示选择所有父级是 <div> 元素的 <p> 元素

```html
<style>
    div>p{
      color:red;
    }
</style>

<p>no red text</p>
<div>
  <p>red text</p>
  <table>
    <tr>
      <td>
        <p>no red text</p>
      </td>
    </tr>
  </table>
</div>
```

还可以有这种形式：`.class>element{}`

```html
<style>
    .dd>p{
      color:red;
    }
</style>

<p>no red text</p>
<div class="dd">
  <p>red text</p>
  <table>
    <tr>
      <td>
        <p>no red text</p>
      </td>
    </tr>
  </table>
</div>
```



### 6. 兄弟选择器(brother selector)

`element~element{}`，例如：`div~p`表示选择div元素之后的每一个p元素

```html
<style>
    div~p{
      color:red;
    }
</style>

<div>
  <p>no red text</p>
  <div>no red text</div>
  <p>red text</p>
  <p>red text</p>
</div>
```



### 7. 相邻选择器

`element+element{}`，例如：`div+p`表示选择所有紧接着<div>元素之后的<p>元素

```html
<style>
   div+p{
     color: red;
   }
</style>

<div>
   <p>not red text</p>
</div>
<p>red text</p>
<p>not red text</p>
```



更多可以参考https://www.runoob.com/cssref/css-selectors.html



## 背景属性

css背景属性有

```css
background-color
background-image
background-repeat
background-attachment
background-position
```



例如：

```css
body
{
    background-color:#b0c4de;
    background-image:url('img_tree.png');
    background-repeat:no-repeat;
    background-position:right top;
}
```

可以简写：

```css
body
{
	background:#b0c4de url('img_tree.png') no-repeat right top;
}
```



## 文本属性

| 属性                                                         | 描述                       |
| ------------------------------------------------------------ | -------------------------- |
| [color](https://www.runoob.com/cssref/pr-text-color.html)    | 设置文本颜色               |
| [text-align](https://www.runoob.com/cssref/pr-text-text-align.html) | 用来设置文本的对齐方式     |
| [text-decoration](https://www.runoob.com/cssref/pr-text-text-decoration.html) | 用来设置或删除文本的装饰   |
| [text-transform](https://www.runoob.com/cssref/pr-text-text-transform.html) | 转换元素中的字母的大小写   |
| [text-indent](https://www.runoob.com/cssref/pr-text-text-indent.html) | 缩进文本的首行             |
| [line-height](https://www.runoob.com/cssref/pr-dim-line-height.html) | 设置行高                   |
| [letter-spacing](https://www.runoob.com/cssref/pr-text-letter-spacing.html) | 设置字符间距，可以用于中文 |
| [word-spacing](https://www.runoob.com/cssref/pr-text-word-spacing.html) | 设置字间距，仅英文有效     |
| [text-shadow](https://www.runoob.com/cssref/css3-pr-text-shadow.html) | 设置文本阴影               |



## 字体属性

| 属性                                                         | 描述                                 |
| ------------------------------------------------------------ | ------------------------------------ |
| [font](https://www.runoob.com/cssref/pr-font-font.html)      | 在一个声明中设置所有的字体属性       |
| [font-family](https://www.runoob.com/cssref/pr-font-font-family.html) | 指定文本的字体系列                   |
| [font-size](https://www.runoob.com/cssref/pr-font-font-size.html) | 指定文本的字体大小                   |
| [font-style](https://www.runoob.com/cssref/pr-font-font-style.html) | 指定文本的字体样式                   |
| [font-variant](https://www.runoob.com/cssref/pr-font-font-variant.html) | 以小型大写字体或者正常字体显示文本。 |
| [font-weight](https://www.runoob.com/cssref/pr-font-weight.html) | 指定字体的粗细。                     |

font-family属性应该设置几个字体名称作为一种"后备"机制，如果浏览器不支持第一种字体，他将尝试下一种字体。

**注意**: 如果字体系列的名称超过一个字，它必须用引号，如Font Family："宋体"。

```html
<style>
p.serif{font-family:"Times New Roman",Times,serif;}
p.sansserif{font-family:Arial,Helvetica,sans-serif;}
</style>

<h1>CSS font-family</h1>
<p class="serif">这一段的字体是 Times New Roman </p>
<p class="sansserif">这一段的字体是 Arial.</p>
```



## 链接属性

链接有四个状态：

- a:link - 正常，未访问过的链接
- a:visited - 用户已访问过的链接
- a:hover - 当用户鼠标放在链接上时
- a:active - 链接被点击的那一刻

这四个是有顺序规则的，可以记为`L(link)OV(visited)E  and  H(hover)A(active)TE`

```html
<style>
a:link {color:#000000;}      /* 未访问链接*/
a:visited {color:#00FF00;}  /* 已访问链接 */
a:hover {color:#FF00FF;}  /* 鼠标移动到链接上 */
a:active {background-color:#FF704D;}  /* 鼠标点击时 */
</style>

<p><b><a href="/css/" target="_blank">This is a link</a></b></p>
```



创建链接框

```html
<style>
a:link,a:visited
{
	display:block;
	font-weight:bold;
	color:#FFFFFF;
	background-color:#98bf21;
	width:120px;
	text-align:center;
	padding:4px;
	text-decoration:none;
}
a:hover,a:active
{
	background-color:#7A991A;
}
</style>

<a href="/css/" target="_blank">这是一个链接</a>
```



## 列表属性

| 属性                                                         | 描述                                               |
| ------------------------------------------------------------ | -------------------------------------------------- |
| [list-style](https://www.runoob.com/cssref/pr-list-style.html) | 简写属性。用于把所有用于列表的属性设置于一个声明中 |
| [list-style-type](https://www.runoob.com/cssref/pr-list-style-type.html) | 设置列表项标志的类型。                             |
| [list-style-position](https://www.runoob.com/cssref/pr-list-style-position.html) | 设置列表中列表项标志的位置。                       |
| [list-style-image](https://www.runoob.com/cssref/pr-list-style-image.html) | 将图像设置为列表项标志。                           |

```html
<style>
ul.a {list-style-type:circle;}
ul.b {list-style-type:square;}
ol.c {list-style-type:upper-roman;}
ol.d {list-style-type:lower-alpha;}
</style>


<p>无序列表实例:</p>
<ul class="a">
  <li>Coffee</li>
  <li>Tea</li>
  <li>Coca Cola</li>
</ul>

<ul class="b">
  <li>Coffee</li>
  <li>Tea</li>
  <li>Coca Cola</li>
</ul>

<p>有序列表实例:</p>
<ol class="c">
  <li>Coffee</li>
  <li>Tea</li>
  <li>Coca Cola</li>
</ol>

<ol class="d">
  <li>Coffee</li>
  <li>Tea</li>
  <li>Coca Cola</li>
</ol>
```

简写形式：

```html
<style>
ul 
{
	list-style:square url("sqpurple.gif");
}
</style>

<ul>
<li>Coffee</li>
<li>Tea</li>
<li>Coca Cola</li>
</ul>
```

