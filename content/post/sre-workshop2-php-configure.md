+++
title = "Workshop2 - 安裝 PHP, MySQL, phpMyAdmin"
description = "在 Google Cloud Platform(GCP) Web server. 安裝 PHP"
date = "2017-09-16T12:04:50+08:00"
tags = [ "Apache2", "workshop-sre"]
categories = [ "技術" ]
relative_banner = "post/workshop/workshop-2.jpg"
+++

[PIXNET](https://www.pixnet.net/career) 內部開了 SA Workshop，學習自架網頁 Server 服務。練習時間半小時。

[第一課: 用 GCP 自架 Web server](/workshop1---用-gcp-自架-web-server/) 安裝了 Apache Server。

接著，我們要在該台機器安裝 PHP 及相關作業，捲起袖子 ...

<!--more-->

#### Agenda:

1. Install & Configure PHP 7.0
2. Install & Configure MySQL 8
3. Install phpMyAdmin
4. Build your staging
5. Homework


## 1. Install & Configure PHP 7.0

與上節相同採用 apt-get 安裝工具來安裝，當然可以試著自行編譯不同的 PHP 版本
{{< alert "alert-info" >}}
$ sudo apt-get install php7.0 <br>
$ php -v
{{< /alert >}}

{{< figure src="/img/post/workshop/2/1.jpg" title="install php7 via command line" >}}

安裝完之後檢查 PHP 版本...

{{< figure src="/img/post/workshop/2/2.jpg" title="check your php7 via command line" >}}

## 2. Install & Configure MySQL 8

這裏我們試著安裝 MySQL8.0 來玩看看

#### 2.1 到 MySQL 官網複製 Package 網址
[mysql-apt-config_0.8.7-1_all.deb 檔案下載頁面](https://dev.mysql.com/downloads/file/?id=472393)

{{< figure src="/img/post/workshop/2/3.jpg" title="Copy MySQL 8 deb url" >}}

#### 2.2 使用 wget 下載到你的 Server
{{< alert "alert-info" >}}
$ wget https://dev.mysql.com/get/mysql-apt-config_0.8.7-1_all.deb
{{< /alert >}}

#### 2.3 解壓縮下載後的檔案
{{< alert "alert-info" >}}
$ sudo dpkg -i  {package}.deb
{{< /alert >}}

{{< figure src="/img/post/workshop/2/4.jpg" title="wget and dpkg Mysql 8 deb file in command line" >}}

#### 2.4 設定你要安裝的 Database

##### 2.4.1 設定 apt-get 來安裝 MySQL
該流程有三種 options:
{{< figure src="/img/post/workshop/2/5.jpg" title="MySqL install process." >}}


我們選 `mysql-8.0 preview`，其餘兩個設定就使用 default 即可

- MySQL Server: mysql-8.0 preview
- MySQL Tools & Connectors: Enabled
- MySQL Preview Packages: Disabled
ok 之後，我們要透過 apt-get 進行更新抓到我們的設定檔，並且進行安裝

##### 2.4.2 安裝 MySQL
使用 apt-get 指令接著安裝
{{< alert "alert-info" >}}
$ sudo apt-get update <br>
$ sudo apt-get install mysql-server
{{< /alert >}}
{{< figure src="/img/post/workshop/2/6.jpg" >}}

設定 root 密碼，接著進行一連串的安裝動作

{{< figure src="/img/post/workshop/2/7.jpg" title="set your mysql root password" >}}

#### 2.5 測試安裝結果
{{< alert "alert-info" >}}
$ mysql --version <br>
$ mysql -uroot -p <br>
$ show databases;
{{< /alert >}}
- mysql -uroot -p
    - -u: 使用 root 帳號
    - -p: 接著會進入輸入密碼模式
- show databases; <span class="text-info">// 顯示目前的 Database 清單</span>

{{< figure src="/img/post/workshop/2/8.jpg" title="Connect your via with shell" >}}

影片部分可以參考[這裏](https://www.youtube.com/watch?v=G7F89QS5G3g)

## 3. Install phpMyAdmin
- 選擇安裝在 Apache 上
- 選擇使用 dbconfig-common 安裝
- 按 Enter 讓設定一個亂數密碼
- 可以直接對 root 帳號設定你的密碼

{{< alert "alert-info" >}}
$ sudo apt-get install phpmyadmin
{{< /alert >}}

安裝完後

1. 建立 phpmyadmin 的 Apache conf 連結到 Apache2 server 底下
    - <span class="text-info">(conf-enabled) Apache2 允許連線的目錄設定</span>
2. 重新開啟 Apache Server

{{< alert "alert-info" >}}
$ ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-enabled/phpmyadmin.conf <br>
$ sudo service apache2 restart
{{< /alert >}}

{{< figure src="/img/post/workshop/2/9.jpg" title="phpMyAdmin demo page" >}}
{{< figure src="/img/post/workshop/2/10.jpg" title="login to phpMyAdmin to check your version" >}}


## 4. Build your staging
最後我們來建立自己的測試區:

- 建立測試目錄 staging
- 建立 staging 目錄連結到 Apache2 網頁根目錄底下
- 新增一個 index.php 檔案印出 PHP 設定 (`phpinfo();`)

{{< alert "alert-info" >}}
$ mkdir ~/staging <br>
$ sudo ln -s /home/`whoami`/staging /var/www/html/staging  <br>
$ echo '<?php phpinfo(); ?>' > ~/staging/index.php
{{< /alert >}}

拜訪 <a href="">http://{YOUR IP ADDRESS}/staging/</a>
<img src="/img/post/workshop/2/11.jpg" width="100%">


## 5. Homework: put your PHP example for staging

這裡提供一包使用 PHP Emma API 的範例可以放到你自己建立的 Server 可以玩看看

[PIXNET Emma API Example Source Code](https://github.com/kylinfish/pixnet-emma-demo)

<img src="/img/post/workshop/2/12.jpg" width="100%">
