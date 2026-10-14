---
title: "基本的網頁安全與防護 - SQL Injection"
description: "自組 Raw SQL 才發現防護不足。整理 SQL Injection 的基礎防護：prepared statements、parameterized queries 與 PDO 用法。"
date: "2017-06-28T18:02:51+08:00"
draft: false
tags:  ["PHP", "sql_injection", "web_security"]
categories: ["技術"]

featuredImage: "/img/post/sql_injection.jpg"
images: ["/img/post/sql_injection.jpg"]

---

現在都依賴 Framework 來幫我們阻擋基本的 SQL Injection 防範

但當我自組 Raw Sql 的時候才發現漏洞百出，基礎防禦都沒做足...

<!--more-->
於是，查了一些相關知識，做一些筆記

## 基礎防護
### ✵ 使用 `prepared statements` 和 `parameterized queries`
* Using __PDO__
* Using __MySQLi__ (MySQLi does true prepared statements all the time.)

[🔗  How can I prevent SQL injection in PHP?](http://stackoverflow.com/questions/60174/how-can-i-prevent-sql-injection-in-php?rq=1)


### ✵ 別使用易受攻擊的編碼形式進行連線 (only use utf8 / latin1 / ascii / etc)
* 別使用 __utf8__, __latin1__, __ascii__ 以外的編碼
* 可以在 MySQL 設定中指定 __charset__
* 或針對 MySQL 連線指定編碼，使用 `set_charset`

[🔗  http://stackoverflow.com/questions/5741187/sql-injection-that-gets-around-mysql-real-escape-string](SQL injection that gets around mysql_real_escape_string())

### ✵ 跳脫 input 欄位，使用 `mysqli_real_escape_string()`
* 根據 __charset__ 來對字串做特殊字元的跳脫 escaped
* `一定要指定 charset` __[重要]__

[🔗 php manual：mysqli_real_escape_string](http://php.net/manual/en/mysqli.real-escape-string.php)

[🔗 GBK字符集下addslashes、mysql_real_escape_string函数的注入漏洞及解决办法](https://www.funboxpower.com/gbk_addslashes_mysql_real_escape_string_injection])
<br>



##  觀念
SQL Injection 防範是要 __跳脫__ 而非 __過濾__，不能採用 strip_tags <b class="text-danger">[x]</b>

### 如果自組 raw sql 一定要:
* 自行跳脫 (mysqli_real_escape_string())
* 型態轉換 (int => (int), string => (string))
* 如果要支援 `LIKE`
 * 建議要手動跳脫 __`_`(underline)__, __`%`(percent)__, `\`__(backslash)__ 符號，避免被 Injection
 * 使用 `addcslashes()` 把 __`_`__, __`%`__, `\` 也視為需要跳脫的字元

## 額外參考
* [🔗  2016 PHPtech session about web security](https://www.slideshare.net/colinodell/hacking-your-way-to-better-security-zendcon-2016)
* [🔗  OWASP SQL Injection Prevention Cheat Sheet](https://www.owasp.org/index.php/SQL_Injection_Prevention_Cheat_Sheet)
