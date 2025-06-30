---
title: "MySQL Row Constructor"
subtitle: ""
date: 2025-06-30T10:39:24+08:00
lastmod: 2025-06-30T10:39:24+08:00
draft: true
author: ""
authorLink: ""
description: ""
license: ""
images: []

tags: []
categories: []

featuredImage: ""
featuredImagePreview: ""

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
ruby: true
fraction: true
fontawesome: true
linkToMarkdown: true
rssFullText: false

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
math:
  enable: false
  # ...
mapbox:
  # ...
share:
  enable: true
  # ...
comment:
  enable: true
  # ...
library:
  css:
    # someCSS = "some.css"
    # located in "assets/"
    # Or
    # someCSS = "https://cdn.example.com/some.css"
  js:
    # someJS = "some.js"
    # located in "assets/"
    # Or
    # someJS = "https://cdn.example.com/some.js"
seo:
  images: []
  # ...
---

<!--more-->

## Row Constructor

先來看看 [Row Constructor Expression](https://dev.mysql.com/doc/refman/8.4/en/row-constructor-optimization.html)
是什麼?

```sql
SELECT * FROM t1 WHERE (column1,column2) = (1,1);
SELECT * FROM t1 WHERE column1 = 1 AND column2 = 1;
```
允許把多個比較條件使用 (列結構) 表示法來寫表示。上述兩條 SQL 等價。


額外留意的是，Row Constructor 不包含 index prefix ，也就是當查詢條件不是 `=` equals 的時候，某些時候會吃不到索引，此時就要考慮就不要使用 Row Constructor 如下:

```sql
(c2,c3) > (1,1)
c2 > 1 OR ((c2 = 1) AND (c3 > 1))
```

但是上述情況太難理解，不建議使用。光解讀 `>` 的轉譯就令人頭痛...



See more in  [Range Optimization of Row Constructor Expressions.](https://dev.mysql.com/doc/refman/8.4/en/range-optimization.html#row-constructor-range-optimization)


## 場景

介紹完 Row Constructor，分享什麼場景我們可以這樣用。

先前我們探討[要不要正規化](/table-normalize-or-denormalized/) 裡提到:
{{< admonition info>}}
 **Normalize until it hurts, denormalize until it works.**
{{< /admonition >}}


手上一個場景是，在 OLTP 中資料庫高度正規化因為需要嚴格控管資料的關係，只有在適時必要才會做反正規化 (Denormalize)，以及反正規化展開對組合對資料同步的成本極高。在踏入分布式解方之前還在嘗試找尋資料上可用的方案。

---
以下有兩張主要的資料表: `dp_codes`, `fp_codes`
{{< admonition warning>}}
_The data has been obfuscated_
{{< /admonition>}}
```sql
MariaDB root@localhost:core_entity> select code from dp_codes limit 5
+------+
| code |
+------+
| A001 |
| A015 |
| A016 |
| A023 |
| A027 |
+------+
```

```sql
MariaDB root@localhost:core_entity> select id, sku, dp_code from fp_skus limit 5;
+------+--------------+-----------+
| id   | sku          |   dp_code |
+------+--------------+-----------+
| 6714 | 3PB09999116  |      A001 |
| 4982 | 3PB09999116T |      A002 |
| 4983 | 3PB09999224T |      A001 |
| 4984 | 3PB099ee116T |      A001 |
| 6691 | 3PB09999123  |      A005 |
+------+-------------+-----------+
```


我需要得知:
{{< admonition question "fp_skus 跟 dp_codes 對應關係?" >}}
- 是否有 3PB09999116T + A023 的組合
- 是否有 3PB09999224T + A001 的組合
- 是否有 3PB09999123 + A999 的組合
{{< /admonition >}}

兩表如果透過反正規化展開數量組合數千萬，如果要在資料同步時做維護，不管是使用類似 Materialized View 或者是自行維護，都有巨大的成本，同時資料會有難以控管的時間差議題。在走向