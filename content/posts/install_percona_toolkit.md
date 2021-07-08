---
title: "如何安裝 Percona toolkit 工具包?"
description: "使用 Percona toolkit 提供的工具進行 profiling 分析，工具安裝筆記"
date: "2018-05-13T22:38:54+08:00"
draft: false
tags: [ "percona", "MySQL" ]
categories: ["技術"]

featuredImage: "/img/post/percona_toolkit.png"
images: [ "/img/post/percona_toolkit.png" ]
---

利用 percona 提供的 toolkit 來進行 mysql DB 資料分析。如何在我們開發環境安裝?

How to install __percona-toolkit__ on MacOSX or Linux?

> 前情提要：我們要透過 `pt-query-digest` 等指令，對 DB query 進行分析，所以先來安裝吧

> ref: [mysql_profiling log lesson 1](/mysql_profiling_query_log)

## 安裝 percona-toolkit
1. 如果是 __Mac OSX__ 可以透過 brew 來進行安裝 percona-toolkit
```SHELL
brew install percona-toolkit
```

2. 如果是 __Linux__ 系統
    - For Debian or Ubuntu:
        ```shell
        sudo apt-get install percona-toolkit
        ```
    - For RHEL or CentOS:
        ```shell
        sudo yum install percona-toolkit
        ```

> ref: https://www.percona.com/doc/percona-toolkit/LATEST/installation.html

## Percona Toolkit Tools

Percona 工具包安裝完後，可以使用的指令有以下

- Tools:
    - pt-align
    - pt-archiver
    - pt-config-diff
    - pt-deadlock-logger
    - pt-diskstats
    - pt-duplicate-key-checker
    - pt-fifo-split
    - pt-find
    - pt-fingerprint
    - pt-fk-error-logger
    - pt-heartbeat
    - pt-index-usage
    - pt-ioprofile
    - pt-kill
    - pt-mext
    - pt-mongodb-query-digest
    - pt-mongodb-summary
    - pt-mysql-summary
    - pt-online-schema-change
    - pt-pmp
    - pt-query-digest
        - 分析 log
        - 回報 slow query, 以及最頻繁執行的 query
    - pt-secure-collect
    - pt-show-grants
    - pt-sift
    - pt-slave-delay
    - pt-slave-find
    - pt-slave-restart
    - pt-stalk
    - pt-summary
    - pt-table-checksum
    - pt-table-sync
    - pt-table-usage
    - pt-upgrade
    - pt-variable-advisor
    - pt-visual-explain

查詢文件做進一步的學習操作

> ref: https://www.percona.com/doc/percona-toolkit/LATEST/index.html

----

> cover image from [percona.com](https://www.percona.com/software/database-tools/percona-toolkit)