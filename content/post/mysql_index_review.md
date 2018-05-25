+++
draft = false
description = "透過 Percona 工具適時 Review Index 設計，去蕪存菁。在發生軟體或需求變革時，如何重新分析或檢驗效能"
tags = [ "MySQL", "index" ]
categories = [ "技術" ]
date = "2018-05-14T23:25:09+08:00"
title = "MySQL Index 設計第三節 - 檢驗與回顧設計不良的 Index"
absolute_banner="/img/post/mysql_index/tide_up.jpg"
og_images = ["/img/post/mysql_index/tide_up.jpg"]
+++
前兩節我們找出需求最頻繁的 Query 並對此做 Index 設計之後，該節我們要對先前的設計做檢驗與回顧。

<!--more-->

{{< figure src="https://image.slidesharecdn.com/howtodesignindexesreally-121025130330-phpapp02/95/how-to-design-indexes-really-54-638.jpg?cb=1354609505" title="" >}}

## 使用 Percona 工具 Review Index Design

透過 Percona 的工具來檢驗是否有多餘的 Index 造成讀寫的成本浪費或者有重複是 Index


- pt-index-usage
- pt-duplcicate-key-checker


{{< figure src="https://image.slidesharecdn.com/howtodesignindexesreally-121025130330-phpapp02/95/how-to-design-indexes-really-63-638.jpg?cb=1354609505" title="" >}}

## 定期回顧 Query (Review Queries Regularly)
- 發生以下情形，重複並定期分析你的 Query
    - 當新的 Application 的程式引進新的 Query 時
    - 當資料量成長時，讓取得資料變得更耗時的時候
    - 當網頁流量改變，讓某個 Query 變得更頻繁被存取時

---

## 總回顧


{{< figure src="https://image.slidesharecdn.com/howtodesignindexesreally-121025130330-phpapp02/95/how-to-design-indexes-really-68-638.jpg?cb=1354609505" title="" >}}

整體建議在 Index 設計實踐上的四個步驟為：

1. 精確識別你的 Query
2. 針對你對 Query 設計的 Index 做三星系統評分
3. 去蕪存菁，透過工具檢驗多餘或者重複的 Index
4. 養成習慣做定期回顧或者 reveiw


<br>

----

### <span class="text-success">__文章系列__</span>

1. [MySQL 效能 - How to design Indexes, Really](/mysql_performance/)
2. [MySQL Index 設計第一節 - 從 Log 分析 Query](/mysql_profiling_query_log/)
3. [MySQL Index 設計第二節 - 三星評分法則](/mysql_index_3star_system/)
4. <span class="text-info">_MySQL Index 設計第三節 - 檢驗與回顧設計不良的 Index_</span>

- [如何安裝 Percona toolkit 工具包?](/install_percona_toolkit/)
