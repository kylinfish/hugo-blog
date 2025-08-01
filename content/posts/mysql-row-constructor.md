---
title: "MySQL Row Constructor Expression"
description: " MySQL/MariaDB 中，Row Constructor Expression 是一種語法，用於同時處理多個列的值。它可以用來進行多列比較、插入多行數據、或作為查詢條件，這種語法在特定場景下非常有用。"
subtitle: "用於同時處理多個列的值。它可以用來進行多列比較、插入多行數據、或作為查詢條件，這種語法在特定場景下非常有用。"
date: 2025-06-30T10:39:24+08:00
lastmod: 2025-06-30T10:39:24+08:00
draft: false
tags: [ "MySQL", "index" ]
categories: ["技術"]

featuredImage: "/img/post/mysql-rdbms.jpg"
images: ["/img/post/mysql-rdbms.jpg"]

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
---

<!--more-->

## Row Constructor Expression

先給你看 GPT 總結:

{{< admonition note >}}
MySQL 的 Row Constructor Expression 主要用於以下場景：

- 多列值的範圍比較（字典序）。
- 批量插入多行數據。
- 多列匹配（如 IN 子句）。
- 引用插入值進行更新（如 ON DUPLICATE KEY UPDATE）。
- 與子查詢結合進行多列比較。
- 基於多列的排序或分組。
{{< /admonition >}}


看看官網怎麼說 [Row Constructor Expression](https://dev.mysql.com/doc/refman/8.4/en/row-constructor-optimization.html)?

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

### Example Tables
以下有兩張主要的資料表: `dp_codes`, `fp_codes`，兩表量很大。
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

### Query Scenario
我需要得知:
{{< admonition question "fp_skus 跟 dp_codes 對應關係?" >}}
- 是否有 3PB09999116T + A023 的組合
- 是否有 3PB09999224T + A001 的組合
- 是否有 3PB09999123 + A999 的組合
{{< /admonition >}}

- 兩表如果透過反正規化展開數量組合 **數千萬**
- 資料同步維護成本，不管是使用 Materialized View 或者是自行維護，都有巨大的成本
  - 場景有可能異動會一次帶起 **數萬筆** 以上的更新事件
  - 資料有難以控管的時間差議題

### Solution

在走向反正規化之前。最後找到 Row Constructor 這個方向可以讓我們使用 View 就可以有好的搭配。

#### 1. Create View Table
```sql
CREATE OR REPLACE VIEW v_combinations AS
SELECT 
    dp.code as dp_code,
    fs.sku
FROM dp_codes dp
LEFT JOIN fp_skus fs 
  ON dp.code = fs.dp_code
```

透過 View Table 可以先避免做反正規化的資料維護成本以及時間差議題。

---

#### 2. Use Row Constructor Expression
使用 Row Constructor Expression 可以滿足我們原先想要跨表查詢兩表的主鍵，滿足需求又有效能

```sql
MariaDB root@localhost:core_entity>
SELECT * FROM v_combinations 
WHERE (col1, col2) IN (
  ('A001', '3PB099224T'), 
  ('A002', '3PB099224T')
)
limit 10;
+-------------+------------+-------+
| design_code | code       | width |
+-------------+------------+-------+
| A001        | 3PB099224T | 95.0  |
| A002        | 3PB099224T | 95.0  |
+-------------+------------+-------+
```

#### Explain Performance Check
Row 裡面的兩個欄位都有吃到兩表 (dp_code, fp_codes) 的索引，scan rows 也極低。

```sql
MariaDB root@localhost:core_entity> EXPLAIN 
SELECT * FROM v_combinations 
WHERE (col1, col2) IN (
  ('A001', '3PB099224T'), 
  ('A002', '3PB099224T')
)
limit 10;
+----+-------------+-------+-------+----------------------------------------+-----------------------+---------+------+------+----------------------------------------------------+
| id | select_type | table | type  | possible_keys                          | key_len  | ref     | rows | extra                                                      |
+----+-------------+-------+-------+----------------------------------------+-----------------------+---------+------+------+----------------------------------------------------+
|  1 | SIMPLE      | us    | range | PRIMARY,ux_table_xxxxxxxxxx            | ux_uxxx  | NULL    |    1 | Using index condition                                      |
|  1 | SIMPLE      | ms    | ref   | ux_xx_xx_xx_,xxx_xxx_xxx__unified...   | xxx_x... | core... |    1 |                                                            |
|  1 | SIMPLE      | sku   | eq_ref| PRIMARY,ix_xxx_xxx_xxx_id              | PRIMARY  | core... |    1 | Using where                                                |
|  1 | SIMPLE      | dms   | range | ux_xxxxxxwe_xxxxx,idx_xxxxxx           | ux_xxx   | NULL    |  437 | Using where; Using index; Using join buffer (flat...       |
+----+-------------+-------+-------+----------------------------------------+-----------------------+---------+------+------+----------------------------------------------------+
```

## 總結
透過 `View` + `Row Constructor Expression` 讓我們避免掉跨兩張大表條件查詢，同時避免反正規化帶來的資料維護成本。