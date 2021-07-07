---
title: "初探 Lumen Micro Framework - Middleware"
description: "Lumen 入門筆記 - Middleware, Lumen 介紹, Lumen 中文"
date: "2017-07-14T12:14:50+08:00"
draft: false
tags: [ "Lumen", "Controller" ]
categories: ["技術"]

featuredImage: "/img/post/lumen.jpg"
images: [ "/img/post/lumen.jpg" ]
---

Middleware 是介於 Http 跟 Application 之間的中間層，Lumen 與 Laravel 一樣有提供 Middleware 的中繼層
<!--more-->

## 簡介

Lumen 提供 Middleware 替 HTTP 進行過濾機制。例如 Auth Middleware 可以進行登入身份驗證。

目前有被實作的 middleware 都放在 `app/Http/Middleware` 路徑底下

## 定義自己的 Middleware

可以使用 __ExampleMiddleware__ 來建立自己的 middleware

當然在實際的應用中，如果每個 HTTP request 都可以在進入 Application 之前都通過 middleware 每層檢查，甚至可以拒絕給予進入。

#### Before / After Middleware

middleware 可以在進入 Application 之前跟之後分別被處理


## 註冊 Middleware

#### Global Middleware
如果想要在所有的 HTTP Request 到 Application 這段可以經過 Middleware 機制，只要在 `bootstrap/app.php` 檔案中
使用 `$app->middleware()` 進行註冊即可。

#### 特定的 Routes 過 Middleware
* 先在 `bootstrap/app.php` 給一個特定的 short-hand key
* 指定完名字後就會在 Http kernel 中被定義，接著在 __route__ 中使用 middleware 的 option 傳入即可
* option 參數也可以指定多組 middleware

#### 參考資料
* [🔗  Lumen Middleware](https://lumen.laravel.com/docs/5.4/middleware)

