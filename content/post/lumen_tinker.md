+++
description = ""
date = "2017-07-12T17:21:50+08:00"
tags = [ "Lumen", "tinker", "PHP" ]
categories = ["技術"]
title = "Lumen 使用 php artisan tinker"
relative_banner = "post/lumen.jpg"
og_images = ["https://kylinyu.win/img/post/lumen.jpg"]
+++
Lumen 沒有像 Laravel 一樣可以直接使用 Tinker。

如果想要使用 psysh shell 必須要自己安裝。

<!--more-->

#### 安裝步驟
1. 使用 composer 載入 tinker
```
composer require vluzrmos/tinker --dev
```

2. 註冊在 lumen 的  service providers
 > lumen\bootstrap\app.php
```
$app->register(Vluzrmos\Tinker\TinkerServiceProvider::class);
```

3. 在 shell console 使用 tinker
```
php artisan tinker
```

#### 參考資料
* [🔗  Where is 'php artisan tinker' in Lumen?](https://laracasts.com/discuss/channels/general-discussion/where-is-php-artisan-tinker-in-lumen)
* [🔗  Github: vluzrmos/tinker](https://github.com/vluzrmos/lumen-tinker)
