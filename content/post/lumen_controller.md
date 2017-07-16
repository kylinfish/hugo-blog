+++
draft = false
date = "2017-07-14T18:05:50+50:00"
description = "Lumen 入門筆記 - Middleware, Lumen 介紹, Lumen 中文"
tags = [ "Lumen", "Controller" ]
categories = [ "技術" ]
title = "初探 Lumen Micro Framework - Controller"
relative_banner = "post/lumen.jpg"
og_images = ["https://kylinyu.win/img/post/lumen.jpg"]
+++

## 簡介

與一般 Framework 提供的方式大同小異，在 routes 的 clouser 裡面指定 ___Controller `@` method___ 名稱即可
<!--more-->

#### Naming
一樣可以使用 `as` 來進行命名，並且使用 `route` helper 來產生被 naming 的 controller route

#### 把 Middleware 指定進 Controller
除了在 route 可以指定要過哪個 middleware 檢查之外，也可以直接在 Controller 裡面使用 `$this->middleware()` 來取得相關的方法操作

#### DI & Controller
Lumen 提供我們直接對於整支 Controller 以及 Method 都可以直接注入，並且讓我們使用 Type-hint 進行檢查與限制。

甚至是 route 設定所傳進來的 Http GET 參數也可以直接在 Controller 方法參數中使用 Type-hint 的 `Illuminate\Http\Request` 來接所有參數


#### 參考資料
* [🔗  Lumen Controller](https://lumen.laravel.com/docs/5.4/controllers)
