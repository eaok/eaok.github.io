---
title: about
type: about
date: 2016-10-24 14:42:17
---

<div class="ds-recent-visitors" data-num-items="39" data-avatar-size="40" id="ds-recent-visitors"></div>


#ds-reset .ds-avatar img,
#ds-recent-visitors .ds-avatar img {
width: 54px;
height: 54px;     /*设置图像的长和宽，这里要根据自己的评论框情况更改*/
-moz-border-radius: 27px;
box-shadow: inset 0 -1px 0 #3333sf;     /*设置图像阴影效果*/
}

#ds-reset .ds-avatar img:hover,
#ds-recent-visitors .ds-avatar img:hover {

/*设置鼠标悬浮在头像时的CSS样式*/    box-shadow: 0 0 10px #fff;
rgba(255, 255, 255, .6), inset 0 0 20px rgba(255, 255, 255, 1);
-webkit-box-shadow: 0 0 10px #fff;
rgba(255, 255, 255, .6), inset 0 0 20px rgba(255, 255, 255, 1);
transform: rotateZ(360deg);     /*图像旋转360度*/
-webkit-transform: rotateZ(360deg);
-moz-transform: rotateZ(360deg);
}

#ds-recent-visitors .ds-avatar {
float: left
}
/*隐藏多说底部版权*/
#ds-thread #ds-reset .ds-powered-by {
display: none;
}