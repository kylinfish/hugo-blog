---
title: "MySQL 效能 - How to design Indexes, Really"
description: "使用資料庫 MySQL 要如何設計 INDEX，以及如何分析 Query 的效能"
date: "2018-05-25T12:00:49+08:00"
draft: false
tags: [ "MySQL", "index" ]
categories: ["技術"]

featuredImage: "/img/post/indexcover.png"
images: [ "/img/post/indexcover.png" ]
---
每每遇到系統資料幅度成長時，就會考慮到效能的問題。

這次將要花心思來學習如何設計 MySQL Index，藉由投影片 [How to Design Indexes, Really](https://www.slideshare.net/billkarwin/how-to-design-indexes-really) 做細部了解

## 關於效能

- Index 是最常在效能上被建議以及需審視的項目
- 在 _尚未異動 Schema 以及式碼_ 的情境下，是用來加速 SQL Query __最簡單的方式__
- 最容易在資料庫的開發跟維護上被忽略

### Indexing 謬誤
{{< admonition warning 謬誤>}}
1. ~~Index 可以改善效能，所以我替所有欄位都加上 Index~~

    - 大部分的 Index 可能都用不到
    - 打 Index 時會占硬碟空間
    - 當發生 __INSERT, UPDATE, DELETE__ 的語法時，需要修改 Index
    - Query Optimizer 會在每個 Query 都參照 Index，這會增加 Query 成本
        -  [Definition - What does Query Optimizer mean?](https://www.techopedia.com/definition/26224/query-optimizer)
2. ~~打 Index 會增加成本，所以我不打任何的 Index~~
    - 正確(到位)的 index 可以加快 Query 的速度
    - 大部分的 Workload 都發生在讀(Read) 的情境，所以 overhead 相較於更新 (update/delete) 上是有益處的
    - Indexes 是複合式的能夠更有效率的使用緩衝記憶體
{{< /admonition >}}
### 我的 Schema 在這，告訴我如何打 Index ?
- Index 必須要根據
    - 你要 Query 的 table 和 columns ?
    - 你想要使用怎樣的 `JOINs` ?
    - 你需要怎麼樣的 `GROUP` BY 和 `ORDER BY` ?

----


{{< admonition summary 文章系列>}}

1. _MySQL 效能 - How to design Indexes, Really_
2. [MySQL Index 設計第一節 - 從 Log 分析 Query](/mysql_profiling_query_log/)
3. [MySQL Index 設計第二節 - 三星評分法則](/mysql_index_3star_system/)
4. [MySQL Index 設計第三節 - 檢驗與回顧設計不良的 Index](/mysql_index_review/)

- [如何安裝 Percona toolkit 工具包?](/install_percona_toolkit/)
{{< /admonition >}}