+++
title = "Workshop1 - 用 GCP 自架 Web server"
description = "使用 Google Cloud Platform(GCP) 自架 Web server."
date = "2017-09-14T12:04:50+08:00"
tags = [ "GCP", "Apache2" ]
categories = [ "技術" ]
relative_banner = "post/workshop/workshop-1.jpg"
+++

[PIXNET](https://www.pixnet.net/career) 內部開了 SA Workshop，學習自架網頁 Server 服務。練習時間一小時。

第一課，學習在 [Google Cloud Platform (GCP)](https://cloud.google.com/?hl=zh-tw) 上開機器，並安裝 Apache Server。

<!--more-->

## Agenda:
1. Sign up GCP (Google Cloud Platform)
2. Add SSK Key
3. Boot your first server
4. Install Apache
5. Homework


## 1. Sign up GCP
第一先準備一張信用卡，註冊 GCP 帳號。但別緊張，今天的練習基本上不會花到錢，根據他的步驟先把信用卡設定完畢之後。 我們要進行的是，建立一個新的 GCP 專案

<img src="/img/post/workshop/1/1.png" width="100%">

## 2. Add your SSH key
選擇你建立的 Project，在該專案中來建立自己的 Web Server 之前，先把自己本機電腦中的 SSH Key 加到專案中，選擇對應的專案
<img src="/img/post/workshop/1/2.png" width="100%">
接著設定 SSH Key 讓我們待會可以透過本機的 Terminal 連線上 GCP 的機器

選擇 <b class="text-primary">Compute Engine -> 中繼資料 -> 新增 SSH Key</b>
<img src="/img/post/workshop/1/3.png" width="100%">


## 3. Boot your first server
接著要在專案中開啟機器

選擇 <b class="text-primary">Compute Engine -> VM 執行個體 -> 建立</b>

說好的免費玩玩，所以選擇上要注意幾點：

- `名稱`：機器名稱 <small class="text-warning"> (名稱決定之後，除了重新建立 instance 以外不能從機器內部修改)</small>
- `區域`：選擇美國東區 <small class="text-info">(e.g. us-west1-b)</small> 或者其他區域，並且在右邊會顯示 <small class="text-info">本月 f1-micro 執行個體 720 小時完全免費 代表 30 天 * 12 小時 = 720 (即該月免費) </small>
- `機器類型` : 微型(1 個共用 vCPU) <small class="text-warning">其餘類型收費標準會顯示於右邊</small>
- `防火牆`: 開啟 HTTP, HTTPS 流量 (詳見下圖)

<img src="/img/post/workshop/1/4.png" width="100%">

過幾秒鐘後，會看見你開的 instance 已經 on 起來了，你的第一台 GCP 機器就開好了

<img src="/img/post/workshop/1/5.png" width="100%">

## 4. Install Apache
Connect to your VM.

使用 ssh 連線剛剛列表頁面中的外部 IP

<img src="/img/post/workshop/1/6.png" width="100%">

使用 __apt-get__ 把 Apache Server 安裝起來，記得要先成為 root，安裝 apache2  之後重開 apache2。
```
$ sudo apt-get install apache2
$ sudo service apache2 restart
```

```
root 可以對 server 作任何修改，包含安裝軟體，或是 rm -rf /
務必小心使用！
```

完成之後，可以看到在 GCP 的專案列表上的 instance 外部 IP 點選下去，會發現網頁出現 _拒絕連線_

由於目前還沒有 SSL 憑證，所以會連不上，請手動取消 `https` 的 `s`，改用 http 連線，就可以看到你的 Apache2 Server 起來了

<img src="/img/post/workshop/1/7.png" width="100%">


## 本節最後
安裝完之後，讓你剛起來的 server 上的套件都更新一下：
```
$ sudo apt-get upgrade
```

安裝各種你需要開發的環境工具 e.g. git, tmux, any shell, ...，但由於你開的是 Micro 的 instance 記憶體只有 0.6 M，有時候操作起來會頓是正常的 XD

### 安裝環境延伸閱讀
[在 Terminal 環境下的開發配置](https://kylinyu.win/%E5%9C%A8-terminal-%E7%92%B0%E5%A2%83%E4%B8%8B%E7%9A%84%E9%96%8B%E7%99%BC%E9%85%8D%E7%BD%AE/)
