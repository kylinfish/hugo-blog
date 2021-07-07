---
title: "MySQL Index 設計第二節 - 三星評分法則"
description: "介紹 Index 設計心法 - 何謂三星評分法則"
date: "2018-05-14T13:25:13+08:00"
lastmod: "2021-07-07T09:30:12+08:00"
draft: false
tags: [ "MySQL", "index" ]
categories: ["技術"]

featuredImage: "/img/post/mysql_index/3star_rule.png"
images: [ "/img/post/mysql_index/3star_rule.png" ]
---

Rate your indexes using the star system.

根據三星評分法檢驗 Index 設計， 用星等對 Query 做評分

> _原文出處: [how-to-design-indexes-really](https://www.slideshare.net/billkarwin/how-to-design-indexes-really)_

## 什麼是 Three-Star System （三星評分法則)

### ★ First Star
{{<admonition info 準則>}}
Rows referenced by your query are grouped together in the index.
{{</admonition >}}

如果一個索引可以將 SELECT 中掃描的相關或相鄰的排列盡可能的相近

- 目標：
    - 減少隨機的 I/O
    - 減少被掃瞄的索引片段

### ★ Second Star
{{<admonition info 準則>}}
Rows referenced by your query are ordered in the index the way you want them.
{{</admonition >}}

SELECT 中 ORDER BY 的資料順序和索引的順序一致

- 目標：
    - 可以避免資料在 Memory 中進行排序

### ★ Third Star
{{<admonition info 準則>}}
The index contains all columns referenced by your query (covering index).
{{</admonition >}}

所有欄位都被 Index 所覆蓋

- 目標：
    - 只用索引就完成查詢的所有工作

### Summary
三星評分法則的本質其實是在減少 I/O

- 減少需要掃描的 index page
- 減少排序
- 減少存取原始資料表

----

## 實戰範例
{{< highlight sql>}}
mysql> explain SELECT person_id, person_role_id FROM cast_info WHERE movie_id = 91280 AND role_id = 1 ORDER BY nr_order ASC;
{{< / highlight >}}
{{< highlight shell>}}
***************************[ 1. row ]***************************
id            | 1
select_type   | SIMPLE
table         | cast_info
type          | ALL
possible_keys | <null>
key           | <null>
key_len       | <null>
ref           | <null>
rows          | 24001730
Extra         | Using where; Using filesort
{{< / highlight >}}

- `type = ALL`: 全表搜尋 (scan whole table)
- `key = null`: 沒用到 index (uses no index)
- `rows = 24001730`: 掃了很多筆 row
- `Using filesort`: sorts the hard way
    - 引用 MySQL 官方文件 Using filesort

    > MySQL must do an extra pass to find out how to retrieve the rows in sorted order. The sort is done by going through all rows according to the join type and storing the sort key and pointer to the row for all rows that match the WHERE clause.
{{<admonition info>}}
filesort 是速度較慢的外部排序方式，通常看到不會太開心

但不見得有 filesort 就會慢，主要要看影響的資料筆數有多少
{{</admonition >}}

### ★ First Star
挑出使用等號搜尋的欄位 (Equality predicates)，對這些欄位下 index

{{< highlight sql>}}
mysql>  SELECT person_id, person_role_id
        FROM cast_info
        WHERE movie_id = 91280 AND role_id = 1
        ORDER BY nr_order ASC;
{{< / highlight >}}

- `movie_id = 91280  AND role_id = 1` 是 Equality predicates

{{< highlight sql>}}
mysql>  ALTER TABLE cast_info ADD INDEX (movie_id, role_id)
{{< / highlight >}}

### ★ Second Star
替 GROUP BY 或 ORDER BY 所用到的欄位加 index
{{< highlight sql>}}
mysql>  SELECT person_id, person_role_id
        FROM cast_info
        WHERE movie_id = 91280 AND role_id = 1
        ORDER BY nr_order ASC;
{{< / highlight >}}

- `nr_order` 排序欄位 (sorting column)

{{< highlight sql>}}
mysql>  ALTER TABLE cast_info ADD INDEX (movie_id, role_id, nr_order)
{{< / highlight >}}

### ★ Third Star
替任何在 Query 中被選取剩餘的 column (Selet List) 補上 index
{{< highlight sql>}}
mysql>  SELECT person_id, person_role_id
        FROM cast_info
        WHERE movie_id = 91280 AND role_id = 1
        ORDER BY nr_order ASC;
{{< / highlight >}}

- `person_id, person_role_id`: select-list 欄位
- `nr_order` 排序欄位 (sorting column)

{{< highlight sql>}}
mysql>  ALTER TABLE cast_info ADD INDEX
        (movie_id, role_id, nr_order, person_id, pseron_role_id)
{{< / highlight >}}

#### 重新 Explain 檢驗
{{< highlight sql>}}
mysql> explain SELECT person_id, person_role_id FROM cast_info WHERE movie_id = 91280 AND role_id = 1 ORDER BY nr_order ASC \G;
{{< / highlight >}}
{{< highlight shell>}}
***************************[ 1. row ]***************************
id            | 1
select_type   | SIMPLE
table         | cast_info
type          | ref
possible_keys | movid_id
key           | movie_id
key_len       | 8
ref           | const, const
rows          | 57
Extra         | Using where; Using index;
{{< / highlight >}}

1. `effective index`: key 欄位吃到 movie_id, rows 從一開始的 24001730 縮小到剩下 57
2. `no filesort`: extra 沒顯示 filesort 代表沒用到外部排序了
3. `covering index`: Using Index

## Complications 複雜情況

1. 無法使用 First-Star indexes 的情況
    - 當 WHERE 條件句中包含 OR (Disjunction)時，
{{< highlight sql>}}
mysql> SELECT * FROM Telephonebook WHERE last_name = 'Smith' OR first_name = 'John';
{{< / highlight >}}

1. 無法使用 Second-Star indexes 的情況
    - 當 WHERE 條件中含有 range query 時將吃不到。(\>, \<, !=, NOT, IN, BETWEEN, LIKE, etc.)
    - Query 條件同時有 GROUP BY 和 ORDER BY 但在不同欄位時
    - Query 必須要對跨表的不同欄位做排序時 (Index 不能跨 table)

1. 無法使用 Third-Star indexes 的情況
    - Query 條件 > index 能處理的最大數量. (每個 index 最多能使用 16 的欄位)
    - Query 含有 BLOB, TEXT, VARCHAR 欄位超出每個 index 最大值 1000 bytes 時。(utf8 計算是每個 character 是 3 bytes)

## 範例 Query
{{< highlight sql>}}
mysql> Explain SELECT STRAIGHT_JOIN n.*
    FROM char_name AS c
    INNER JOIN cast_info AS i
        ON c.id=i.person_role_id
    INNER JOIN name AS n
        ON i.person_id=n.id
    WHERE c.name = 'James Bond'
    ORDER BY n.name ;
{{< / highlight >}}

### First-star index
{{< highlight sql>}}
mysql>  ALTER TABLE char_name ADD INDEX n (name(20));
{{< / highlight >}}

### Third-star index
{{< highlight sql>}}
mysql>  ALTER TABLE cast_info ADD INDEX pr_p (person_role_id, person_id);
{{< / highlight >}}


{{< admonition question "為何不建立 Second-star index ?">}}
- 這裏不可能建立 Second-star index，跨表無法做到
- join column 的順序不一定與排序的欄位相同
{{< /admonition>}}

---

下一篇： [MySQL Index 設計第三節 - 檢驗與回顧設計不良的 Index](/mysql_index_review/)


{{< admonition summary 文章系列>}}

1. [MySQL 效能 - How to design Indexes, Really](/mysql_performance/)
2. [MySQL Index 設計第一節 - 從 Log 分析 Query](/mysql_profiling_query_log/)
3. _MySQL Index 設計第二節 - 三星評分法則_
4. [MySQL Index 設計第三節 - 檢驗與回顧設計不良的 Index](/mysql_index_review/)

- [如何安裝 Percona toolkit 工具包?](/install_percona_toolkit/)
{{< /admonition >}}