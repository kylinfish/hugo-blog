---
title: "MySQL 字串(char/varchar) 欄位搜尋數字(integer)"
subtitle: ""
date: 2022-04-14T17:53:09+08:00
draft: false
tags: [ "MySQL", "Schema" ]
categories: ["技術"]

featuredImage: "/img/post/mysql-rdbms.jpg"
images: ["/img/post/mysql-rdbms.jpg"]
---
某次的 Table Query 下了一個基本的數字 id 條件做查詢，結果異樣的慢

帶一下 profiling 的過程找問題 ..
<!--more-->

## 情境
該條 SQL 需要耗費將近 2 分鐘
```sql
db> SELECT * FROM order_task_table WHERE orderId = 2913339
```

## 分析

檢查索引 [show index](https://dev.mysql.com/doc/refman/8.0/en/show-index.html) 是有的
```shell
db> show indexes from order_task_table\G
8 rows in set
Time: 0.167s
***************************[ 4. row ]***************************
Table         | order_task_table
Non_unique    | 1
Key_name      | orderid_index
Seq_in_index  | 2
Column_name   | orderId
Collation     | A
Cardinality   | 606842
Sub_part      | <null>
Packed        | <null>
Null          | YES
Index_type    | BTREE
Comment       |
Index_comment |
```

只好 [Explain](https://dev.mysql.com/doc/refman/8.0/en/explain-output.html) 一下

```shell
db> explain SELECT * FROM order_task_table WHERE orderId = 2913339

+----+-------------+---------------------+------+----------------+--------+---------+--------+---------+-------------+
| id | select_type | table               | type | possible_keys  | key    | key_len | ref    | rows    | Extra       |
+----+-------------+---------------------+------+----------------+--------+---------+--------+---------+-------------+
| 1  | SIMPLE      | order_task_table    | ALL  | customid_index | <null> | <null>  | <null> | 2427382 | Using where |
+----+-------------+---------------------+------+----------------+--------+---------+--------+---------+-------------+
```

怪哉，吃不到 index，只好再用 [describe](https://dev.mysql.com/doc/refman/8.0/en/show-columns.html) 看一下欄位狀況


```sql
db> describe order_task_table
+----------------------+---------------------+------+-----+---------------------+----------------+
| Field                | Type                | Null | Key | Default             | Extra          |
+----------------------+---------------------+------+-----+---------------------+----------------+
| ..........           | ............        | YES  | MUL | <null>              |                |
| orderId              | varchar(30)         | YES  | MUL | <null>              |                |
| ..........           | ............        | YES  | MUL | <null>              |                |
```

{{<admonition danger "傻眼貓咪" >}}
結果號稱 Id 的欄位開的 Type 是 varchar...
{{</admonition >}}


這故事告訴我們，不要覺得欄位名稱跟型別會有關係，原本以為是數字型態 (integer/biginteger)


## 修正
修正方法，一律加上 Quote 引號把數字視為字串

上述情境無法使用指定索引來改善，只要你搜尋的條件是在字串欄位給數字，那就無法利用 Btree 索引

```sql
db> SELECT * FROM order_task_table WHERE orderId = '2913339'
```

## 探討
直接查到 DK 大寫的文章: [MySQL 裡搜尋 CHAR/VARCHAR (String) 欄位時要注意的事情](https://blog.gslin.org/archives/2014/02/09/4237/mysql-%E8%A3%A1%E6%90%9C%E5%B0%8B-charvarchar-string-%E6%AC%84%E4%BD%8D%E6%99%82%E8%A6%81%E6%B3%A8%E6%84%8F%E7%9A%84%E4%BA%8B%E6%83%85/)

數字被當成文字處理很常被誤用

### 欄位型態與查詢數字的內容做比較
- `欄位是 integer`: 查詢內容是數字，不管有沒有帶引號，也就是內容有可能是數字或字串
    - MySQL 會自己幫你轉成數字再比較，**可以吃索引**
- `欄位是 char/varchar`: 查詢內容是數字，一定要使用引號將其視為字串
    - MySQL 不會幫你轉，所以會**吃不到索引**
    - 原因在 DK 大大文章內寫了

## 結論
{{<admonition summary "建議" >}}
1. 儲存內容如果確定是數字的，不要用 char/varchar 存
    - 不要荼毒隊友
    - 數字的儲存空間，在大多情況都比字串來得小
2. 看到欄位名稱時，要記得檢查型別(type)
3. 真的要在字串欄位裡搜尋數字，記得轉成字串(加上引號)
{{</admonition >}}





<br>

雷踩完了，就更強了
