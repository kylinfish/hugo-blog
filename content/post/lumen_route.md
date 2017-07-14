+++
description = "Lumen 入門筆記 - Routing, Lumen 介紹, Lumen 中文"
date = "2017-07-12T18:21:50+08:00"
tags = [ "Lumen" ,"Routing"]
categories = ["技術"]
title = "初探 Lumen Micro Framework - Routing"
relative_banner = "post/lumen_route.jpg"
+++

筆記一下 Lumen 提供的 Route 功能
<!--more-->

## HTTP Route 功能

#### ❋ 基礎 Routing

支援基本的 HTTP 動詞

```
 get()
 post()
 put()
 patch()
 delete()
 options()
```

#### ❋ Route 參數

* Required parameter:
__基礎的 required 參數__ 使用 `{...}` 包裹

* Optional Parameters:
__可有可無參數__ 使用 `[...]` 包裹

* Regular Expression Constraints:
__正規表示式__ 條件設定 使用 `{...}` 包裹

#### ❋ 命名 Routes
用 `as` 對 route 命名

可以利用名字的參數，在 controller 中使用 `route('name')` 來取得 $url
```
// Generating Redirects...
return redirect()->route('profile');
```

#### ❋ Route 群組
替你的 route 設定 group，群組可以有以下三種應用介紹

##### 1. Middleware
指定特定 route 群組內的 url 都過某一個 middleware 的執行

##### 2. Namespaces
指定相同的 Namespaces 到同一個 route 群組內

##### 3. Route Prefixes
替 route 群組內都做 prefix 的 uri 設定
```
$app->group(['prefix' => 'admin'], function () use ($app) {
    $app->get('users', function ()    {
    // Matches The "/admin/users" URL
    });
});
```

#### 參考資料
* [🔗  Lumen Routing](https://lumen.laravel.com/docs/5.4/routing)
