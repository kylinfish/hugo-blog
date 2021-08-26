---
title: "資料庫到底要不要做正規化"
subtitle: ""
date: 2021-08-26T14:01:30+08:00
lastmod: 2021-08-26T14:01:30+08:00
draft: false
author: ""
authorLink: ""
description: ""

tags: [ "RDBMS", "MySQL", "Normalization"]
categories: ["技術"]

featuredImage: "/img/post/mysql-rdbms.jpg"
images: ["/img/post/mysql-rdbms.jpg"]


---
> **Normalize until it hurts, denormalize until it works.**

資料庫的設計有個基本的作法是 - [正規化](https://zh.wikipedia.org/zh-tw/%E6%95%B0%E6%8D%AE%E5%BA%93%E8%A7%84%E8%8C%83%E5%8C%96)
<!--more-->
## 資料庫正規化
資料庫正規化是用來消除重複資料，提升硬碟效能以及降低更新錯誤的一種設計方式。

消除重複資料就能減少 `開發成本` 以及 `儲存成本`

當你拆分資料表關聯的程度愈多，代表正規化的程度也愈高，資料關聯性的約束性也愈強，

但同時也代表資料被切分為多張關聯表格
- DB I/O 更加繁忙
- [JOINs](https://en.wikipedia.org/wiki/Join_(SQL)) 的狀況也愈多

## 什麼時候做正規化?
考量需回歸 Data 本身特性

{{<admonition summary "如果有以下情況的話，做正規化會是好的選擇" >}}
1. 避免大量資料重複問題，或同步機敏資訊避免暴露的情況
2. 允許你使用更簡單的 Query 查詢
3. 更好的查詢效能
{{</admonition>}}

## 要不要正規化?
我們通常怎麼取捨或決定?

{{<admonition question "資料成長幅度會不會破百萬?" >}}
如果會，建議做適當的正規劃。

資料量小的時候，有沒有正規劃都不會有太大影響，也不重要
- [Everything is fast for small n.](https://blog.codinghorror.com/everything-is-fast-for-small-n/)

{{</admonition>}}

{{<admonition question "你是不是被 Join 困擾" >}}
正規劃程度越高， Join 愈複雜。這時候造成開發上的困擾時，其實可以考慮做反正規化了。
{{</admonition>}}


## 結語
以前都被教育也習慣開發就直接以正規化方式開下去，重新讀完這兩篇文章的觀點之後...

覺得 **適度的反正規劃** 或者 **乾脆不正規化** 其實都是不錯的選擇。

現在我可能會這樣看:

- 開發環境有沒有 ORM 還是只有 Query Builder?
- 如果資料成長幅度不大的設計，直接不做正規化應該也是很舒適
- 至於重複性的 Data 根據上一點的想法，就交給 $$ Money 跟硬體解決吧!
  - $$ 可以解決的問題，都不會是問題


> **Normalize until it hurts, denormalize until it works.**

##### Reference:
- https://blog.codinghorror.com/maybe-normalizing-isnt-normal/

- http://www.25hoursaday.com/weblog/CommentView.aspx?guid=cc0e740c-a828-4b9d-b244-4ee96e2fad4b