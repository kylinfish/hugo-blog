---
title: "MySQL Index Cardinality 索引基數"
subtitle: "SHOW INDEX FROM TABLE"
description: "認識索引基數，以及判斷 Index 是否會被 Query Optimizer 使用的依據"
date: 2021-09-17T10:37:21+08:00
lastmod: 2021-09-17T10:37:21+08:00

draft: false
tags: [ "MySQL", "index" ]
categories: ["技術"]

featuredImage: "/img/post/mysql-index-cardinality.png"
images: ["/img/post/mysql-index-cardinality.png"]
---

## 什麼是 MySQL Index [Cardinality](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_cardinality)

索引基數代表欄位中有不同值的數量，舉例:
- Primary Key 而言: `Cardinality = 該表總資料數`
- 某個欄位的 Unique Key: `Cardinality = 該表總資料數` (因為欄位內確保沒有重複的值)
- 假設 Index 是性別，通常系統會有的值(0: None, 1: Male, 2: Female): `Cardinality = 3`

索引基數，是當 Query 有該欄位條件時，Query Optimizer 會參考決定是否使用該 Index 的參考之一


## 什麼是 [selectivity](https://dev.mysql.com/doc/refman/8.0/en/glossary.html#glos_selectivity)

MySQL query optimizer 在平估 Index 的使用以及選擇時，`資料選擇性(selectivity) 高`的欄位資料會優先使用


### Configuring the Number of Sampled Pages
> The MySQL query optimizer uses estimated statistics about key distributions to choose the indexes for an execution plan,
> based on the `relative selectivity` of the index. When InnoDB updates optimizer statistics,
> it samples random pages from each index on a table to `estimate the cardinality of the index`. (This technique is known as random dives.)

根據 selectivity 參考 Index Cardinality 來決定怎麼使用 Index。

所以重點是: `當 Cardinality 太低，MySQL Optimizer 會認定不使用該 Index 可能會讓查詢更有效`。

也就是 Cardinality 太低，該 Index 就不會被使用，只會成為浪費空間以及徒增Insert/Update 的成本

另外在參考其他文章時候，一直有看到 30% 的這個設定。

## 關於是否進行 Full Table Scan 的切分決定
> Query Optimizer 認定某個值出現在表的 data rows 中的百分比很高的時候，它一般會忽略索引，進行全表掃描。慣用的百分比界線是"30%"
https://www.twblogs.net/a/5b7d4f862b71770a43de9d56

> Too many matching rows
> A good rule of thumb is that when MySQL believes more than about 30% of the rows are likely matches,
> it will resort to a table scan rather than using the index.
> _High Performance MySQL_
https://www.oreilly.com/library/view/high-performance-mysql/0596003064/ch04.html



這裡的 30% 指的是，假設透過 index 沒辦法 filter out data ＜total rows 的 30%，那 MySQL Query Optimizer 會判斷，不如使用 Full table Sacn
同時也代表這個 Index 就是白打了
