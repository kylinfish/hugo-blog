---
title: "RDBMS 資料庫案例設計 (二) - 最佳化設計技巧"
description: "PHP 也有 Day RDBMS 最佳化設計技巧的口語筆記"
date: "2017-10-24T09:31:24+08:00"
draft: false
tags: [ "RDBMS", "MySQL", "Innodb"]
categories: ["技術"]

featuredImage: "/img/post/mysql-tuning.jpg"
images: ["/img/post/mysql-tuning.jpg"]

---

`PHP 也有 Day 番外篇`，最佳化關於 MySQL 的 Database 參數調校 ...

<!--more-->

開場以電子商務網站為例做討論

- 資料庫的參數設定 (MySQL, PostgreSQL) 要如何調校資料庫效能
- 作業系統的參數設定
    - [MySQL 5.7 參數官方文件](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html)


## Workload
從 Workload 出發來思考，業務的

- 資料完整性
    - 對於遺失，損壞的忍受度為何
- 效能維度
    - 取決機器資源. e.g. CPU, Storage, Memory, Bandwidth


然而評估效能取捨時，通常考慮 `latency` 與 `throughput` 兩項指標

{{< figure src="/img/post/rdbms_tune/workload.jpg" title="圖片出自 Ant_ModernWeb 恰如其分的MySQL設計技巧 p.35" >}}


### 找尋 workload 的 Capacity:
在 connection 變高的時候

- throughput 會降低
- latency 會升高

找到兩者的交叉點。

{{< admonition example >}}
依照業務需求
- 高頻交易為 0.3 ~ 0.5 sec 就要處理完交易
- 傳輸的時候是否要進行壓縮，壓縮會耗損 CPU 資源
- Bandwidth 是買不到的，這是瓶頸之處
{{< /admonition >}}

{{< admonition notice "注意" >}}
有時候會用 CPU 效能換 Bandwidth
{{< /admonition >}}

{{< figure src="/img/post//rdbms_tune/workload-capacity.jpg" title="隨著 Throughput, latency 兩者因素變動下的 Capacity 關係折線圖" >}}


## MySQLTuner 工具
https://github.com/major/MySQLTuner-perl

- 數據蒐集之後告訴你可以怎麼調整
- 但他不會告訴你是為了 `throughput`、`latency`，還是需要手動檢核


### Tuning the query cache
{{< figure src="/img/post/rdbms_tune/query_tune.jpg"  >}}

- 佔記憶體空間，又有查詢成本
- Cache 最大的問題是 ***更新資料策略***
- Cache 資料的 ***讀跟寫*** 的比率為多少?
- 對 Cache 最好的情境是 100% READ

    但要 100% READ 就用 ***Redis*** 就好啦!

    {{< admonition warning "注意" >}}
    `query cache` will no longer be supported in MySQL 8.0
    {{< /admonition >}}

## Connection Pool
{{< figure src="/img/post/rdbms_tune/connect_pool.jpg" title="Connection pool demo flow" >}}

- like [PHP swool extension](https://github.com/swoole/php-cp)
- 傾向 Application 的執行面
- 用來控制 Connection 數量不要太高，過高一定影響 Server 效能
- 建立連線的時候不用再走 3-steps Acks 跟 身份驗證層

## Thread Pool
{{< figure src="/img/post/rdbms_tune/mysql_thread_pool.jpg" title="MySQL with thread pool enabled" >}}

- 在資料庫本身層級的 Pool
- MySQL 的 Enterprise Edition 才有 Thread Pool
- MariaDB, Percona 有支援 Community Server ThreadPool
    - 如果要使用 Thread Pool 要記得設定 pool size


### Buffer Pool
{{< figure src="/img/post/rdbms_tune/mysql_buffer_pool.jpg" title="MySQL Buffer Pool demo flow" >}}

- 把資料跟 index 都從 Disk 抓出來放在 Memory(Buffer Pool) 中
- 通常參數不要設定到 100%，系統層級還有其他部分要操作 Memory
    - maybe: 50% ~ 70%
- 設定太高 MySQL 會 crash 表示記憶體不夠用

---

## 其他的 MySQL server-system-variables 設定經驗

-  [skip-name-resolve](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_skip_name_resolve)
    - off: mysqld resolves host names when checking client connections
    - on: mysqld uses only IP numbers
    - 通常設定 on 之後會比較快

- [system_time_zone (系統時區)](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_system_time_zone)
    - 如果沒指定就要用 linux 機器，要多做訪查
- [key_buffer_size](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_key_buffer_size)
    - 通常高一些比較好，但不要開到最大
- [max_connections](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_max_connections)
    - 每個 connection 都要佔用記憶體空間
    - 通常開大，但不是開愈大愈好，一樣要進行權衡檢查
- [innodb_flush_log_at_trx_commit](https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit)
    - 0, 1, 2 效能比較好
    - 反思資料安全性，你想要效能好或者不能掉資料
- [innodb_page_size](https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_page_size)
    - MySQL default: 16kb.

- [innodb_flush_method](https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_flush_method)
    - 5.7 default: all_o_direct
    {{< figure src="/img/post/rdbms_tune/innodb_flush_method.jpg" title="innodb_flush_method demo flow" >}}
    - direct io 省下記憶體，因為跳過 Page Cache  直接跟底層溝通
    {{< figure src="/img/post/rdbms_tune/direct_io.jpg" title="Block I/O Layer demo image" >}}


see more: [RDBMS 資料庫案例設計 (一) - Schema 設計技巧](/rdbms_design/)
