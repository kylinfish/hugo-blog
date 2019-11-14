+++
draft = false
description = "PHP 也有 Day - RDBMS 資料庫案例設計的口語筆記"
date = "2017-10-18"
tags = [ "RDBMS", "MySQL", "Index"]
categories = [ "技術" ]
title = "RDBMS 資料庫案例設計 (一) - Schema 設計技巧"
relative_banner = "post/mysql-rdbms.jpg"
og_images = ["post/mysql-rdbms.jpg"]
+++

`PHP 也有 Day 番外篇`，關於 Schema 的設計技巧 ...

<!--more-->

ref. [教材參考 ](https://blog.gcos.me/Spec.pdf) 由 [Ant](https://about.me/yftzeng) 提供

#### Agenda:
1. Schema 欄位設計怎麼開
2. 怎麼對欄位打 Index
3. 資料的底層儲存

## Schema 欄位設計怎麼開？

- 時間欄位
    - timestamp (only support until [2038](https://zh.wikipedia.org/wiki/2038%E5%B9%B4%E9%97%AE%E9%A2%98))
    - datetime
    - integer

- 通常有國際標準的就直接 Follow, e.g. `ISO`, `RFC`, `Schema.org`
    - [電話號碼標準](https://en.wikipedia.org/wiki/E.164#Telephone_number_categories)
    - 國際區碼 (Country Code)
    - 各國幣值

{{< alert "alert-warning" >}}
其實沒有絕對的標準，通常搭配業務需求來決定，也非僅有一組最佳答案
{{< /alert >}}

- 舉例來說，密碼欄位長度設計：根據我的加密演算法產生的長度來制定
    - password: char(60)
    - by `password_hash("password", PASSWORD_BCRYPT)` 固定產生長度為 60 的字串


## 怎麼對欄位打 Index
{{< alert "alert-success" >}}
原則上看 where 後面用到什麼，搭配 explain 指令來查看 sql 語法吃到的 index 是哪個
{{< /alert >}}


### <span class="text-primary">情境一：用戶登入頁</span>

```sql
SELECT * FROM users WHERE ( `email`={email} OR `username`={username} ) AND `password`={password} AND `password_expired_at` > NOW() AND `status` = {active};
```
where 後面主要有 `email` OR `username` AND `password` AND `password_expired_at`
接著

#### 1. 對 where 後面分別建立 index
- **index**: `[email]`, `[username]`
- **explain**: index merge `idx_email, idx_username`

#### 2. 多打 password index
- **index**: `[email]`, `[username]`, `[password]`
- **explain**: `idx_email`
    - 發現原先打的 username 跟 password 都用不到了，只用 email 就可以

---- 清除所有 index ----

#### 3. 複合鍵的 Index 順序差別為何
##### 3.1 username + email
- **index**: `[username, email]`
- **explain**: 沒吃到複合鍵的 index
    -  所以 OR 的條件應該要分別建立 index
##### 3.2 email + username
- **index**: `[email, username]`
- **explain**: index sort_union`(idx_email_username, idx_username_email)`


### <span class="text-primary">情境二：用戶認證頁</span>

```sql
SELECT id, email, status FROM users WHERE `email` = {email} AND `token` = {token} AND `token_expired_at` > NOW() AND `status` = {unverified}
```
- **index**: `[email]`
- **explain**: 直接吃掉 email index.

### <span class="text-primary">覆蓋索引 Covering Index. (最快速的 index)</span>
{{< alert "alert-info" >}}
通常我們可以把資料儲存分成 Index 跟 data，這兩塊是分地儲存的
{{< /alert >}}

撈資料的流程，通常是從 index 查找看是否滿足。

如果所要欄位在 index 裡面沒有，就要額外到 data 區查找來回傳。

<br>

但是如果要撈出來的資料在 index 裡面就涵蓋了，就不需要去 data 區撈資料了。這種取得方式稱為`Covering Index` 也可以說是最快速的 Index.


## 資料底層儲存
- `innodb_space`
    - 檢查 datatype 設計是否得宜，可以利用 innodb_space 工具指令，來把數據結構 dump 出來
    - 查看儲存的 record 位置以及順序等等
- `page_illustrate`
    - 畫出實際資料在 page 中的儲存大小與位置

### <span class="text-primary">案例分析 char vs varchar</span>
利用 innodb_space, page_illustrate 來分析 char, varchar 之間的更新變換

#### char 變動資料案例
由於 char 的資料結構原本就是固定長度

- 不管同一筆資料在修改後長度是否 「超出」 或者 「小於」 原先長度
    - `record` 儲存位置不變
        - 長度 「超過」原先大小會被截斷
        - 長度 「小於」原先大小會留下空間
    - `page` 中的位置會產生碎片，因為原先就預留 char 的大小位置

#### varchar 變動資料案例

在發生更新資料長度不同的時候

- 與初始資料 「一樣長」，
    - `record` 儲存位置不變
    - `page` 儲存結構圖沒變，因為空間還是夠塞
- 比初始資料 「短」，
    - `record` 儲存位置不變
    - `page` 儲存結構圖沒變，因為空間還是夠塞

- 比初始資料 「長」，
    - `record` 儲存位置改變，因為原先位置放不下
    - `page` 儲存結構圖舊的位置產生碎片，新的資料存放到大小允許的空間

#### 資料碎片
- 通常碎片發生在 `update` 跟 `delete` 的時候
    - 下一筆 insert 長度 「相同」 前一個碎片空間，也不會放在碎片空間
    - 下一筆 insert 長度 「小於」 前一個碎片空間，就會放進去了

- 副作用
    - 搜尋變慢
    - 佔硬碟空間

- 解決碎片浪費空間的方法
    - mysql optimze table
    - 需要時間，還會 `Lock Table` !!!!

{{< alert "alert-success" >}}
若欄位業務很常要 update 但不想要產生碎片，就用 char 吧!!
{{< /alert >}}


### 延伸問題
> Question: 為何不允許 nullable?

- 當你要 update 從 null 改成有值時，會留下一個很大的碎片。
- 讀的時候無法預測，速度會變慢
- 對於 SQL 也不用下 is not NULL
- 對於底層影響很大
- 程式不用處理 null 的情境*(自行補充)*

@ 當然如果有業務需求也可以使用

<br>

***以上為聽 Ant 口語跟 Demo 操作時的個人筆記，建議大家都可以試著自己操作分析加深印象***

ref. [Hackmd 版本] (https://hackmd.io/s/ry3xWNE6-)

<br>

----

### 延伸補充 (via 同事 [jnlin](https://jnlin.org/))

1. timestamp 還是用 integer 存會比較好，因為有時區的 bug : https://bugs.mysql.com/bug.php?id=38455
2. 複合鍵的 index 只有在後面的 index 可以用 RANGE QUERY (ex 大於, 小於) [ref](https://www.percona.com/blog/2009/09/12/3-ways-mysql-uses-indexes/)
3. varchar & text 都會有 fragment 的問題，有些時候建議另外開一張表
4. 如果 EXPLAIN 沒用 index，可以用 `USE INDEX ` 來 hint sql parse engine 來用



### <span class="text-success">__文章系列__</span>

-  [RDBMS 資料庫案例設計 (二) - 最佳化設計技巧](/rdbms_mysql_tuning/)

1. [MySQL 效能 - How to design Indexes, Really](/mysql_performance)
2. [MySQL Index 設計第一節 - 從 Log 分析 Query](/mysql_profiling_query_log/)
3. [MySQL Index 設計第二節 - 三星評分法則](/mysql_index_3star_system/)
4. [MySQL Index 設計第三節 - 檢驗與回顧設計不良的 Index](/mysql_index_review/)
