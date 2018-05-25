+++
draft = false
description = "使用 Percona Profiling Tool 分析系統 Log, 透過案例了解不同情境的 Query 與 Index 的效果"
tags = [ "MySQL", "profiling" ]
categories = [ "技術" ]
date = "2018-05-14T13:22:20+08:00"
title = "MySQL Index 設計第一節 - 從 Log 分析 Query"
absolute_banner="/img/post/mysql_index/index.png"
og_images = ["/img/post/mysql_index/index.png"]
+++
Schema 設計是根據 data，而 Index 設計是根據 Query
<!--more-->

> Relational schema design is based on data, but Index design is based on queries.

> _原文出處: [how-to-design-indexes-really](https://www.slideshare.net/billkarwin/how-to-design-indexes-really)_

{{< figure src="https://image.slidesharecdn.com/howtodesignindexesreally-121025130330-phpapp02/95/how-to-design-indexes-really-12-638.jpg?cb=1354609505" title="design table is different from b" >}}

### 收集 Query Log
- 打開 slow-query_log 設定:
{{< highlight sql>}}
mysql> SET GLOBAL slow_query_log = ON;
{{< / highlight >}}
- 設定 query 執行時間 > 0s 就進行 log:
{{< highlight sql>}}
mysql> SET GLOBAL long_query_time = 0;
{{< / highlight >}}

## pt-query-digest
- [Install pt-query-digest tool](/install_percona_toolkit)
- 查詢自己 Slow query log 的存放位置
{{< highlight sql>}}
mysql> show variables like '%slow_query%';
{{< / highlight >}}
{{< highlight bash>}}
+---------------------+-----------------------------------+
| Variable_name       | Value                             |
|---------------------+-----------------------------------|
| slow_query_log      | ON                                |
| slow_query_log_file | /usr/local/var/mysql/win-slow.log |
+---------------------+-----------------------------------+
2 rows in set
Time: 0.025s
{{< / highlight >}}
- 用法：
{{< highlight bash>}}
$ pt-query-digest /usr/local/var/mysql/win-slow.log > ~/pgd.txt
{{< / highlight >}}

我們會看到類似以下的圖
{{< figure src="/img/post/mysql_index/pgd_profile.png" title="Your mysql digest profile." >}}

{{< highlight SHELL>}}
### 如何解讀 profile 資訊
# Profile
.# Rank Query ID           Response time   Calls R/Call  Apdx V/M   Item
.# ==== ================== =============== ===== ======= ==== ===== =======
.#    1 0xA8D2BBDE7EBE7822 4932.2992 28.8%    78 63.2346 0.00 5.22 SELECT person_info
.#    2 0xFE25DAF5DBB71F49 4205.2160 24.6%   130 32.3478 0.00 3.47 SELECT title
.#    3 0x70DAC639802CA233 1299.6269  7.6%    14 92.8305 0.00 0.17 SELECT cast_info
.#    4 0xE336B880F4FEC4B8 1184.5101  6.9%   294  4.0289 0.36 2.29 SELECT cast_info
.#    5 0x60550B93960F1837  905.1648  5.3%    60 15.0861 0.05 1.33 SELECT name
.#    6 0xF46D5C09B4E0CA2F  777.2446  4.5% 16340  0.0476 1.00 0.17 SELECT char_name
.#    7 0x09FCFFF0E5BC929F  747.4346  4.4%   130  5.7495 0.53 7.69 SELECT name
.#    8 0x9433950BE12B9470  744.1755  4.4% 14368  0.0518 1.00 0.18 SELECT name
.#    9 0x4DC0E044996DA715  448.5637  2.6%   130  3.4505 0.65 8.31 SELECT title
.#   10 0x09FB72D72ED18E93  361.1904  2.1%    78  4.6306 0.28 1.89 SELECT cast_info title
{{< / highlight >}}

- `Rank 1`: 呼叫數次，呼叫時間花費超過 1 分鐘 (calls: 78,  R/Call: 63.2346)
- `Rank 6`: 呼叫頻率很高的 Query ，每次都很快 (calls: 16340, R/Call: 0.0476)

----

## 案例 - 電話簿情境
以電話簿為例，我們對電話簿打 index, 其順序為 `last_name, first_name, phone_number` (順序很重要)
{{< highlight sql>}}
mysql> CREATE INDEX phone_idx ON TelephoneBook (`last_name`, `first_name`, `phone_number`);
{{< / highlight >}}

#### ➤ 簡易條件搜尋
{{< highlight sql>}}
mysql> SELECT * FROM TelephoneBook WHERE `last_name` = 'Smith';
{{< / highlight >}}

- 由於 last_name 的 index 已經有預先排序的 (pre-sorted) ，所以這對上述的查詢是有提升速度的幫助
- 有效減小搜尋範圍，因為要查詢的內容已經排序過了


#### ➤ 混合條件搜尋
{{< highlight sql>}}
mysql> SELECT * FROM TelephoneBook WHERE `last_name` = 'Smith' AND `first_name` = 'John';
{{< / highlight >}}

- 同時搜尋 last_name 跟 first_name 一樣是有助益的

#### ➤ Index 失敗的搜尋
{{< highlight sql>}}
mysql> SELECT * FROM TelephoneBook WHERE `first_name` = 'John';
{{< / highlight >}}

- 這是無法預測的分佈，任何人的 first_name 都可能是 John，故需要做 scan whole table 全表搜尋

##### <i class="text-warning">順序影響問題 (Order Matters)</i>
- 順序是 index 被定義的關鍵
- 只搜尋 last_name 欄位是會吃到 index 的; 如果只搜尋 first_name 會吃不到 index。代表 `index 的順序是影響查詢是否吃到 index 的關鍵`
- 需要再多打一組 first_name 在前的 index 才能使以 first_name 為條件搜尋的 query 可以吃到 index
{{< highlight sql>}}
mysql> CREATE INDEX phone_idx2 ON TelephoneBook (`first_name`, `last_name`, `phone_number`);
{{< / highlight >}}
- 如果搜尋兩個條件都是使用 __= (equality)__，那麼欄位的順序`對 index 不會有所影響`
{{< highlight sql>}}
mysql> SELECT * FROM TelephoneBook WHERE `last_name` = 'Smith' AND `first_name` = 'John';
{{< / highlight >}}


#### ➤ 範圍式比較 (Range Comparisons)
模糊搜尋 last_name 為 S 開頭的資料
{{< highlight sql>}}
mysql> SELECT * FROM TelephoneBook WHERE `last_name` = 'S%';
{{< / highlight >}}

- Index 可以讓我們減少搜尋範圍，只找 S 開頭的資料避免全部搜尋。故此例 index 仍然對搜尋有幫助

#### ➤ 混合式範圍式比較 (Compound Range Comparisons)
範圍搜尋 last_name 同時指定 first_name 的情境
{{< highlight sql>}}
mysql> SELECT * FROM TelephoneBook WHERE `last_name` = 'S%' AND `first_name` = 'John';
{{< / highlight >}}

- 對整體來說，first_name 仍然處於無法預測的分佈，因為 John 並沒有和 last_name 是 S 開頭的組合在一起。故我們需要對所有
last_name 為 S 開頭的資料做全部查詢

##### <i class="text-warning">順序影響問題 (Order Matters)</i>
在 Range search 中，index 在查詢時無法幫助到後面的 (subsequent) 欄位。

根據先前打的 index:
{{< highlight sql>}}
mysql> CREATE INDEX phone_idx ON TelephoneBook (`last_name`, `first_name`, `phone_number`);
{{< / highlight >}}

- 第一欄 - `last_name`: 首欄對 Range search 有幫助
- 第二欄 - `fisrt_name`: subsequent 後續的欄位是沒有助益的

#### ➤ 排序 (Sorting by Index)
{{< highlight sql>}}
mysql> SELECT * FROM TelephoneBook WHERE `last_name` ORDER BY `first_name`;
{{< / highlight >}}
這裏的 ORDER BY 沒有做任何事，因為先前打的 index 已經就是預排序 (pre-sorted) 了

#### ➤ Index 無法幫助 Sorting
{{< highlight sql>}}
mysql> SELECT * FROM TelephoneBook WHERE `last_name` ORDER BY `phone_number`;
{{< / highlight >}}

- Sorting 任一欄位是另一個故事了 0rz.. 汗
- phone_idx 的 index 已經是先對 last_name 再對 first_name 排序了，但並沒有對 phone_number 在數字上排序

##### <i class="text-warning">順序影響問題 (Order Matters)</i>
- 如果搜尋條件順序是按照 index 的欄位順序，那麼 index 是有助益的
- 但如果我們需要在 index 後面在進行另一種排序，或者需要排序的沒在索引中的欄位，那麼這將會很困難

#### ➤ Index-Only 搜尋
如果我們需要的欄位是搜尋條件之外的欄位
{{< highlight sql>}}
mysql> SELECT `phone_number` FROM TelephoneBook WHERE `last_name` = 'Smith' AND `phone_number` = 'John';
{{< / highlight >}}

- 不需要額外成本，因為一開始 phone_idx 的 index 一次就是打 3 個欄位，就算我們在 query 時沒有明確地指定 phone_number

#### ➤ Index 失敗的案例
如果我們需要的欄位不包含在 index 中，需要額外的搜尋成本
{{< highlight sql>}}
mysql> SELECT `business_hours` FROM TelephoneBook WHERE `last_name` = 'Smith Plumbing';
{{< / highlight >}}

- 這就是 extra work. 需要額外的作業取得 business_hours 的資訊

##### <i class="text-warning">欄位影響問題 (Columns Matter)</i>
- 對一般的 Query 來說，Index 中欄位的配置是很重要的，即使 Query 中沒有用到欄位拿來做搜尋或排序


看完第一節 - 從 Log 分析 Query

進入第二節了嗎?

第二節: [MySQL Index 設計 - 三星評分法則](/mysql_index_3star_system/)

<br>

----

### <span class="text-success">__文章系列__</span>

1. [MySQL 效能 - How to design Indexes, Really](/mysql_performance/)
2. <span class="text-info">_MySQL Index 設計第一節 - 從 Log 分析 Query_</span>
3. [MySQL Index 設計第二節 - 三星評分法則](/mysql_index_3star_system/)
4. [MySQL Index 設計第三節 - 檢驗與回顧設計不良的 Index](/mysql_index_review/)

- [如何安裝 Percona toolkit 工具包?](/install_percona_toolkit/)
