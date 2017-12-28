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

#### Tinker 安裝步驟
1. 使用 composer 載入 tinker
{{< alert "alert-primary" >}}
composer require vluzrmos/tinker --dev
{{< /alert >}}

2. 註冊在 lumen 的  service providers
 > lumen\bootstrap\app.php
{{< alert "alert-primary" >}}
$app->register(Vluzrmos\Tinker\TinkerServiceProvider::class);
{{< /alert >}}

3. 在 shell console 使用 tinker
{{< alert "alert-primary" >}}
php artisan tinker
{{< /alert >}}

----

#### Lumen Generator

另外，後來發現有另一套 Generator 也不錯， 可以參考 [Lumen Generator](https://github.com/flipboxstudio/lumen-generator)，提供以下指令產生基本的程式碼架構

```
key:generate      Set the application key

make:command      Create a new Artisan command
make:controller   Create a new controller class
make:event        Create a new event class
make:job          Create a new job class
make:listener     Create a new event listener class
make:mail         Create a new email class
make:middleware   Create a new middleware class
make:migration    Create a new migration file
make:model        Create a new Eloquent model class
make:policy       Create a new policy class
make:provider     Create a new service provider class
make:seeder       Create a new seeder class
make:test         Create a new test class
```

#### 參考資料
* [🔗  Where is 'php artisan tinker' in Lumen?](https://laracasts.com/discuss/channels/general-discussion/where-is-php-artisan-tinker-in-lumen)
* [🔗  Github: vluzrmos/tinker](https://github.com/vluzrmos/lumen-tinker)
* [🔗  Github: flipboxstudio/lumen-generator](https://github.com/flipboxstudio/lumen-generator)
