---
title: "Lumen artisan tinker - TinkerCommand::handle() does not exist. [solved]"
description: "修復 Lumen 升級 5.5 tinker 例外"
date: "2017-07-12T17:21:50+08:00"
draft: false
tags: [ "lumen", "artisan" ]
categories: ["技術"]

featuredImage: "/img/post/lumen.jpg"
images: [ "/img/post/lumen.jpg" ]
---

Lumen upgrade to 5.5 時，使用 `php artisan tinker` 發現出現以下錯誤:

<!--more-->


{{<admonition danger "錯誤" >}}
➜  behavior.pixplug.in (master) ✔ php artisan tinker

In BoundMethod.php line 135:

  Method Vluzrmos\Tinker\TinkerCommand::handle() does not exist
{{</admonition>}}


<br>

查找一下先前使用 composer 安裝 artisan tinker 的時候，安裝到的版本號是 1.3

```
"require-dev": {
    "vluzrmos/tinker": "^1.3",
}
```
>  [查看如何安裝 php artisan tinker in Lumen](/lumen_tinker)

接著在作者的 GitHub 查看 [issue](https://github.com/vluzrmos/lumen-tinker/issues/8)：

__將版本更新到 `dev-master` 後就可以正常使用了__

```
"require-dev": {
    "vluzrmos/tinker": "dev-master",
}
```

{{< figure src="/img/post/artisan_tinker.jpg" title="php artisan tinker demo" >}}
