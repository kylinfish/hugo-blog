---
title: "MySQL DataType / Schema CheatSheet"
subtitle: ""
date: 2023-06-12T15:42:10+08:00
lastmod: 2023-06-12T15:42:10+08:00
description: "MySQL Schema CheatSheet 以及開發設計考量特性"
draft: false
tags: [ "MySQL", "index" ]
categories: ["技術"]

featuredImage: "/img/post/mysql-datatype-cheatsheet.png"
images: ["/img/post/mysql-datatype-cheatsheet.png"]
---

<!--more-->
MySQL Schema 開發設計，針對不同資料型態的 CheatSheet 整理。 詳見整理文末 PDF 附件


## [MySQL 數字型態](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html)
- TINYINT
- SMALLINT
- MEDIUMINT
- INT
- BIGINT

## [MYSQL 浮點數型態](https://dev.mysql.com/doc/refman/8.0/en/floating-point-types.html)
- Float
- Double

## [MySQL DATATIME vs TIMESTAMP](https://dev.mysql.com/doc/refman/8.0/en/date-and-time-types.html)
- DATATIME
- TIMESTAMP

## [MySQL 字串](https://dev.mysql.com/doc/refman/8.0/en/string-types.html)
- CHAR
- VARCHAR

## MySQL 字元空間
佔用 DISK 空間，以及 Query 時會影響的記憶體大小

- 字元
- TEXT
- 日期與時間


## MySQL Schema 型態選型準則
- 時間型態
- 字串型態
- 數字型態

## 下載
- [MySQL DataType / Schema CheatSheet - PDF](https://drive.google.com/file/d/1_l7c43xHojKDGA16ocW0NEkFQkLhW52_/view?usp=sharing)
- [MySQL DataType / Schema CheatSheet - ePub](https://drive.google.com/file/d/1OvEG5gPdBACSPE2dgyTEFm1ZHJDt1IVK/view?usp=sharing)


{{< admonition summary 文章系列>}}
- [MySQL 系列文章](/tags/mysql/)
{{< /admonition >}}
