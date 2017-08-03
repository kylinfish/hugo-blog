+++
draft = false
description = "phpMyAdmin 瀏覽 JSON 的錯誤案例，及 Sequel Pro 匯出與 phpMyAdmin 的差異"
date = "2017-08-03T17:45:50+50:00"
tags = [ "phpMyAdmin", "JSON", "Sequel Pro"]
categories = [ "技術" ]
title = "phpMyAdmin 與 JSON 的小雷踩坑"
relative_banner = "post/phpmadminwithjson.jpg"
og_images = ["post/phpmadminwithjson.jpg"]
+++

MySQL5.7 之後開始支援 JSON 的格式，在新專案的開發的時候，遇到 phpMyAdmin 含有 json 格式會崩壞的情境

以下紀錄遇到的小雷小坑：

<!--more-->

## ❖ Export 匯出資料
我的情境是<span class="text-warning">本機 (Local)</span> 跟<span class="text-primary">線上 (Production)</span> 的資料庫環境是有差異的，開發初期

* <span class="text-warning">本機</span> : 利用 Migrate 跟 Seeder 開出 Table Schema 跟生出假資料
* <span class="text-primary">線上</span> : 把<span class="text-warning">本機</span>資料 Dump 出來匯入 <span class="text-primary">線上</span>資料庫做測試


#### Sequel Pro vs. phpMyAdmin
* Sequel Pro <img src="/img/post/sequel_icon.png" alt="sequel pro logo" width="50px">:
    * 預設 Export 出的 sql 檔案中註解會跟 phpMyAdmin Export 的資料有落差，試著使用 Sequel Pro 匯出的資料倒入，在 <b>phpMyAdmin </b> 版本中：
        * 2.11.x: 含有 json 的部分會卡住，其餘可以正常匯入
        * 4.7.x: 整份都會錯誤
    * (Sorry) 這裡沒有進一步紀錄兩者之間的差異，有興趣了解無法匯入的原因者，可以自行實驗。初步看來是註解方式不同
* 使用 phpMyAdmin 2.11.11.3 操作 Export ，在不同的 phpMyAdmin 操作 Import 都可以正常
    * 最後回到 phpMyAdmin 進行 Export，或者利用 CLI

## ❖ phpMyAdmin 顯示 json 資料問題
試著在匯入之後用 phpMyAdmin 看 json 資料的儲存，結果發生
```
SQL 語法:

SHOW TABLE STATUS LIKE  'stream_subscriptions';

MySQL 傳回： 說明文件
#2014 - Commands out of sync; you can't run this command now
```
<img class="col-md-offset-4 col-xs-offset-2  pull-center" src="/img/post/json_sqlerror.png">

查一下網路災情，https://github.com/phpmyadmin/phpmyadmin/issues/12364 。

這是 PHP Bug，原來我的 phpMyAdmin 機器的 PHP 版本停留在 5.5，要使 phpMyAdmin 可以瀏覽 json 的資料必須要使你的 phpMyAdmin 的 PHP 版本在 >5.6 以上才行喔。


## ❖ 解決 phpMyAdmin 在多種環境下的差異

使用 `Dcoker` <img src="/img/post/docker_icon.png" width="50px">，網路上有別人串好的資源  :

[MySQL with phpMyAdmin](http://www.andrewchen.tw/2017/05/05/20170505_NOTE_DOCKER_MYSQL/)

或者單純的 phpMyAdmin

[phpmyadmin Docker Image](https://hub.docker.com/r/phpmyadmin/phpmyadmin/)

<br>

最後的解法是統一用 `Docker` 跑 phpMyAdmin 連接 <span class="text-warning">本機</span> 與 <span class="text-primary">線上</span> 的 phpMyAdmin 使兩邊的資料庫都可以透過相同的環境來瀏覽，解決 phpMyAdmin 機器原本短時間沒辦法升到 >5.6 瀏覽 json 的錯誤狀況
