+++
description = "設定 Apache2 Server 的 Virtual Host"
date = "2017-09-30T23:46:50+08:00"
categories = [ "技術" ]
title = "GCP Workshop3 - My Virtual Host"
tags = [ "GCP", "Apache2", "workshop-sre" ]
relative_banner = "post/workshop/workshop-3.jpg"
+++

[PIXNET](https://www.pixnet.net/career) 內部開了 SA Workshop，學習自架網頁 Server 服務。練習時間半小時。

[第一課: 用 GCP 自架 Web server](/workshop1---用-gcp-自架-web-server/) 安裝了 Apache Server

[第二課: 安裝 PHP, MySQL, phpMyAdmin](/workshop2---安裝-php-mysql-phpmyadmin/) 安裝了 Apache Server

第三堂，我們將來設定自己 Server 上的 Virtual Host

<!--more-->

#### Agenda:
1. Write Your Virtual Host Config
2. Configure Virtual Host
3. Configure PHP Error Log
4. Upload Your Application
5. Homework

## 1. Write Your Virtual Host Config

假設今天我們擁有自己的域名(domain)，我們可以透過 Apache 的 Virtual Hosting 來使得網域指向機器的位置來提供服務。

> 何謂 Virtual Hosting?

> Virtual Hosting 就是同一台伺服器可以同時處理超過一個網域 (domain)。即是說，假設 www.example1.net 和 www.example2.net
兩個網域都指向同一部電腦，如果電腦上的網頁伺服器 (WWW Server) 支援 Virtual Hosting，那您用 www.example1.net 和 www.example2.net
去訪問同一個伺服器就可以取得不同的網站。
> ref. http://wiki.linux.org.hk/w/Virtual_hosting_with_Apache


為了方便做 demo 我們先在自己的家目錄建立一個叫做 `production` 的資料夾
{{< alert "alert-info" >}}
$ mkdir ~/production
{{< /alert >}}

接著進入撰寫 Virtual Host 設定正題：

{{< alert "alert-info" >}}
$ cd /etc/apache2/ <br>
$ sudo cp sites-available/000-default.conf sites-available/win.blah.tw.conf <br>
$ sudo vim sites-available/win.blah.tw.conf <br>
{{< /alert >}}

在 Apache _sites-available_ 裡面放的是該台 Apache2 會讀取的 Virtualhost 設定，建議檔案名稱以 <b class="text-primary">網域</b> 來做命名

以上述的例子，我擁有一個 `win.blah.tw` 的域名要來設定，複製預設的範本改名為 `win.blah.tw.conf`

- 接著要修改的項目有：
    1. DocumentRoot 之上增加 `ServerName win.blah.tw`
    2. DocumentRoot 改成 `DocumentRoot /home/win/production`
    3. 在 Virtual Host Tag 之內增加以下內容：

```
<Directory /home/win/production/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
```

- 名詞解釋：
    - `ServerName`: 指定設定的網站名稱
    - `DocumentRoot`: 存放網站內容的目錄路徑

## 2. Configure Virtual Host
接著必須讓 Apache2 能讀到你剛剛撰寫的配置檔，所以要把剛剛在 `/etc/apache2/sites-available` 底下撰寫的檔案建立連結到
 `/etc/apache2/sites-enabled`

方法有二種：

1. 手動建立：
{{< alert "alert-info" >}}
$ ln -s /etc/apache2/sites-available/win.blah.tw /etc/apache2/sites-enabled/win.blah.tw
{{< /alert >}}

2. 透過 `a2ensite` 工具，這是 apache 2 enable site 的縮寫，等同於 _1. 手動建立_ 的做法
{{< alert "alert-info" >}}
$ a2ensite win.blah.tw
{{< /alert >}}

完成以上步驟之後，重新啟動 Apache server 來進行測試
{{< alert "alert-info" >}}
$ sudo service apache2 reload
{{< /alert >}}

## 3. Configure PHP Error Log


編輯 `/etc/php/7.0/apache2/php.ini` 檔案設定 Error 的回報層級，以及錯誤 Log 的寫入位置，調整：

- add Error Reporting Level： `error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT`
- add error_log： `error_log=/var/log/php-err.log`

接著先開立一個空白錯誤檔案，並且調整該檔案的權限後再行測試即可

{{< alert "alert-info" >}}
$ sudo touch /var/log/php-err.log <br>
$ sudo chown www-data /var/log/php-err.log <br>
$ sudo service apache2 restart
{{< /alert >}}


測試時你可以故意把 PHP Code 寫錯使得請求時回報錯誤，看錯誤訊息是否有進入該目錄檔案中。

可以透過 `tail -f ` 來自動 watch

{{< alert "alert-info" >}}
$ tail -f /var/log/php-err.log
{{< /alert >}}


## 4. Upload Your Application

在上述設定完畢之後，我們試著把你的網頁應用程式上傳到家目錄底下的 production 資料夾看看

在[上週練習](/workshop2---安裝-php-mysql-phpmyadmin/)中，我們已經有提供 PHP 的範例程式了，如果還沒有實作也可以下載我提供的 [自家
API 練習範本程式](https://github.com/kylinfish/pixnet-emma-demo)

除了可以使用 wget 之外，我們已經可以利用 scp or rsync 指定網域的方式來傳送：

{{< alert "alert-info" >}}
$ scp -r myprogram/ win@win.blah.tw:production/
{{< /alert >}}
<i class="text-warning">只有檔案不同才上傳</i>


{{< alert "alert-info" >}}
$ rsync -a myprogram/ win@win.blah.tw:production/
{{< /alert >}}
<i class="text-warning">Server 與 Client 都要裝 rsync，但如果你是 mac user 太好了! 內建就有</i>

ps. 如果要停用這個 Virtual Host
{{< alert "alert-info" >}}
$ sudo a2dissite win.blah.tw <br>
$ sudo service apache2 restart
{{< /alert >}}

## 5. Homework: Set Staging Virtual Host
- 試著建立 staging.win.blah.tw 的 Staging Virtual Host 看看



#### 參考資料
[配置 Apache 支援多個網域](http://wiki.linux.org.hk/w/Virtual_hosting_with_Apache)

### <span class="text-success">__See more__</span>
1. [GCP Workshop1 - 用 GCP 自架 Web server](/sre-workshop1-gcp-vm-server/)
2. [GCP Workshop2 - 安裝 PHP, MySQL, phpMyAdmin](/sre-workshop2-php-configure/)
3. <span class="text-info">_GCP Workshop3 - My Virtual Host_</span>

