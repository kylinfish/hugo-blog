---
title: "AMP 教學入門 - Convert HTML to AMP"
description: "AMP 入門教學，從 HTML 到 AMP"
date: "2018-04-20T10:35:12+08:00"
draft: false
tags:  [ "AMP" ]
categories: ["技術"]

featuredImage: "/img/post/amp.jpg"
images: [ "/img/post/amp.jpg"]

---

Accelerated Mobile Pages (AMP) 正夯，來看一下如何把基本的 HTML 轉成 AMP 吧!!
<!--more-->

你可以跟著[AMP 官方文件](https://www.ampproject.org/docs/fundamentals/converting) 走，或者看我幫你整理好的文章內容做練習，簡易入門 AMP。

## [Setting up <i class="fa fa-external-link-square"></i>](https://www.ampproject.org/docs/fundamentals/converting/setting-up)
1. 下載範例包，放到 Downloads 資料夾
{{< highlight bash>}}
cd ~/Downloads
git clone https://github.com/googlecodelabs/saccelerated-mobile-pages-foundations.git
{{< / highlight >}}

2. 把範例程式放到 Local Web Server。如果你的 Mac 已經預設有 Apache Server，你可以這樣做
{{< highlight bash>}}
cd /Library/WebServer/Documents
ln -s ~/Downloads/AMP-Foundations-Practice ./amp
run localhost/amp/article.html
{{< / highlight >}}
    如果沒有，可以參考官網提供 [Chrome/Python/Apache/nginx 作法](https://www.ampproject.org/docs/fundamentals/converting/setting-up)

建議在開始建立之前，如果你對網頁渲染有概念，或許可以快速看一下 git log 會幫助你快速了解

> Clone 我演練的 repository:
{{< highlight bash>}}
git clone git@github.com:kylinfish/AMP-Foundations-Practice.git
{{< / highlight >}}

{{< figure src="/img/post/amp/git_log.png" title="git log history" >}}

----

正式開始：
## [Building a regular HTML page <i class="fa fa-external-link-square"></i>](https://www.ampproject.org/docs/fundamentals/converting/building-page)

1. 複製一份新的 article.html，並 rename 成 article.amp.html
{{< highlight bash>}}
cp article.html ./article.amp.html
{{< /highlight >}}
2. 加入 AMP Library
{{< highlight diff>}}
commit 66c8b0afaf75648c29e25c121c48060c9367dd92
diff --git a/article.amp.html b/article.amp.html
index c6fa38e..c6df106 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -7,6 +7,7 @@
         <link href="base.css" rel="stylesheet" />

+        <script async src="https://cdn.ampproject.org/v0.js"></script>
         <script src="base.js"></script>
     </head>
     <body>

{{< /highlight >}}
使用 _AMP Validator_ 來做檢測，把網址加上 `#development=1` 參數
{{<admonition info >}}
http://localhost/amp/article.amp.html#development=1
{{</admonition >}}

    > console log 會顯示  __Powered by AMP ⚡ HTML__

{{< figure src="/img/post/amp/show_amp_message.png" title="inspect the JavaScript console will see AMP work" >}}

## [Resolving validation errors <i class="fa fa-external-link-square"></i>](https://www.ampproject.org/docs/fundamentals/converting/resolving-errors)

1. Include charset

    加入 HTML5 必備的編碼標準指定 charset
{{< highlight diff>}}
commit e3f902beded022af8381705f622254a1bede9bb7
diff --git a/article.amp.html b/article.amp.html
index c6df106..2720922 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -1,6 +1,7 @@
 <!doctype html>
 <html lang="en">
     <head>
+        <meta charset="utf-8" />
         <link rel="shortcut icon" href="amp_favicon.png">

         <title>News Article</title>
{{< /highlight >}}

2. Include canonical link

    為 Google SEO 判斷指標之一，主要是要把網頁權重指回原本的 article.html
{{< highlight diff>}}
commit bf4d0b8997fd71d16f2ad1c94571992a739d8a61
diff --git a/article.amp.html b/article.amp.html
index 2720922..eb68b61 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -3,6 +3,7 @@
     <head>
         <meta charset="utf-8" />
         <link rel="shortcut icon" href="amp_favicon.png">
+        <link rel="canonical" href="/article.html">

         <title>News Article</title>
{{< /highlight >}}

3. Specify the AMP attribute

    AMP 必要條件，可以用 ⚡  也可以單寫 amp
{{< highlight diff>}}
commit 608c5836ca6be90f18e193408c88583117c0b7e1
diff --git a/article.amp.html b/article.amp.html
index eb68b61..7c6db0f 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -1,5 +1,5 @@
 <!doctype html>
-<html lang="en">
+<html amp lang="en">
     <head>
         <meta charset="utf-8" />
         <link rel="shortcut icon" href="amp_favicon.png">
{{< /highlight >}}

4. Specify a viewport

    RWD 網頁的基礎標準 [ref.](https://developers.google.com/web/fundamentals/design-and-ux/responsive/#set-the-viewport)
{{< highlight diff>}}
diff --git a/article.amp.html b/article.amp.html
index 7c6db0f..46d451a 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -2,6 +2,7 @@
 <html amp lang="en">
     <head>
         <meta charset="utf-8" />
+        <meta name="viewport" content="width=device-width,minimum-scale=1,initial-scale=1">
         <link rel="shortcut icon" href="amp_favicon.png">
         <link rel="canonical" href="/article.html">
{{< /highlight >}}

5. Replace external stylesheets

    移除外部引入的 css 改用 inline 的方式。簡言之，inline 讀取比載入外部資源快
{{<admonition primary>}}
<b>NOTE</b> inline style 有 50 Kb 限制，記得要做 Minify
{{</admonition>}}

{{< highlight diff>}}
commit aeafb1a34c130db379c5178b25447615c1946312
diff --git a/article.amp.html b/article.amp.html
index 46d451a..c25018f 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -8,7 +8,9 @@
         <title>News Article</title>

-        <link href="base.css" rel="stylesheet" />
+        <style amp-custom>
+body { width: auto; margin: 0; padding: 0; } header { background: Tomato; color: white; font-size: 2em; text-align: center; } h1 { margin: 0; padding: 0.5em; background: white
+        </style>

         <script async src="https://cdn.ampproject.org/v0.js"></script>
         <script src="base.js"></script>

{{< /highlight >}}

6. Exclude third-party JavaScript

    JS  資源在 AMP 限制中只有兩種情形可以使用：
    1. 帶有 async (非同步載入) 屬性的資源
    2. AMP Library 和 AMP Components

{{<admonition primary >}}
<b>NOTE</b> user-generated third-party scripts 限制對 json 與 json-ld 例外
{{</admonition >}}
{{< highlight diff>}}
commit 9f69ee429ad31f2142830b8cca4f7e132fe3ac44
diff --git a/article.amp.html b/article.amp.html
index c25018f..e30ded1 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -13,7 +13,6 @@ body { width: auto; margin: 0; padding: 0; } header { background: Tomato; color:
         </style>

         <script async src="https://cdn.ampproject.org/v0.js"></script>
-        <script src="base.js"></script>
     </head>
     <body>
         <header>
{{< /highlight >}}
7. Include AMP CSS boilerplate

    AMP 規定要加
{{< highlight diff>}}
commit 76b88de65238d4f802b50c38337fbbe2ab658926
diff --git a/article.amp.html b/article.amp.html
index e30ded1..7593944 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -8,6 +8,7 @@

         <title>News Article</title>

+        <style amp-boilerplate>body{-webkit-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-moz-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-ms-animation:-amp
         <style amp-custom>
 body { width: auto; margin: 0; padding: 0; } header { background: Tomato; color: white; font-size: 2em; text-align: center; } h1 { margin: 0; padding: 0.5em; background: white
         </style>

{{< /highlight >}}

8. Replace `<img>` with `<amp-img>`

    記得補上 end tag `</amp-img>`
{{< highlight diff>}}
commit 3822e0f0e8364fc8712d95517d09363d80ea1016
diff --git a/article.amp.html b/article.amp.html
index 7593944..d7fddf4 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -24,7 +24,7 @@ body { width: auto; margin: 0; padding: 0; } header { background: Tomato; color:
             <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam egestas tortor sapien, non tristique ligula accumsan eu.</p>

-            <img src="mountains.jpg">
+            <amp-img src="mountains.jpg"></amp-img>
         </article>
     </body>
 </html>

{{< /highlight >}}

9. AMP layout system
    - 簡言之，你必須要事先指定 width/height 讓 Browser 在 Layout 的時候可以預留空間
    - 加上 `layout="responsive"` AMP 會自動幫你算圖片縮放比

    {{< highlight diff>}}
commit bc76ba19ff370a7a7d4111f54781e9f2eb956331
diff --git a/article.amp.html b/article.amp.html
index d7fddf4..3a476ea 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -24,7 +24,7 @@ body { width: auto; margin: 0; padding: 0; } header { background: Tomato; color:

             <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam egestas tortor sapien, non tristique ligula accumsan eu.</p>

-            <amp-img src="mountains.jpg"></amp-img>
+            <amp-img src="mountains.jpg" width="266" height="150"></amp-img>
         </article>
     </body>
 </html>
{{< /highlight >}}
{{< highlight diff>}}
commit 55b9d36d73768baa493dca2ef695a8c3cc0e41f5
diff --git a/article.amp.html b/article.amp.html
index 3a476ea..e4d6587 100755
--- a/article.amp.html
+++ b/article.amp.html
@@ -24,7 +24,7 @@ body { width: auto; margin: 0; padding: 0; } header { background: Tomato; color:

             <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam egestas tortor sapien, non tristique ligula accumsan eu.</p>

-            <amp-img src="mountains.jpg" width="266" height="150"></amp-img>
+            <amp-img src="mountains.jpg" layout="responsive" width="266" height="150"></amp-img>
         </article>
     </body>
 </html>
{{< /highlight >}}
10. Success
    AMP validation successful.
{{< figure src="/img/post/amp/amp_validation_successful.png" title="AMP validation successful message in console" >}}


## 小結

AMP 快是因為 `限制` ，其實是為了讓便於手機瀏覽以及網頁渲染(Critical Rendering Path) 的良好實踐

- RWD 必備的元素 viewport, responsive image
- 讓 css 資源可以快速被載入所以移除 external 作法
- 移除會 Blocking 網頁渲染的 JS 資源，除非你用 async 非同步的方式作加載
- 指定圖片寬高，幫助 Layout 預留位置
等等....

其實有很多項目在加速網頁載入的時候就可以隨手做起來，不一定是只有在 AMP 中才需要這樣做。

雙手迎向未來 - Accelerated Mobile Pages (AMP)，優劣還要讓大家一起評估觀望








