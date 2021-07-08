---
title: "AWS ElasticSearch 升級紀錄 5/6"
description: "Upgrading ElasticSearch from 5 to 6"
date: "2019-09-23T14:19:36+08:00"
draft: false
tags: [ "ElasticSearch", "Kibana" ]
categories: ["技術"]

featuredImage: "/img/post/ElasticSearch.png"
images: [ "/img/post/ElasticSearch.png" ]
---

本篇紀錄 AWS ES  升級相關資訊，這次是從版本 5.x 升到 6.x，因為敝 TEAM ES 資料龐大，為了不讓切換時影響 Prod ES ，擬定升級流程之外也需要 Dev/Stg 不同環境進行演練


<!--more-->

## 升級流程與步驟
先看官方建議的流程 [Upgrading Elasticsearch](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-version-migration.html)，而我後續實際執行的步驟可以這樣看:

- 修正 Breaking Changes 錯誤/設定/測試
- 執行資料轉移(底下仰賴 ES API 完成)
    1. Create the snapshot backups for ES V5 (透過 API 備份舊版 ES V5)
    2. Create the new V6 ES (建立新版 ES V6)
    3. Enable slow Log action (設定到 slow log action 收集到 CloudWatch)
    4. Register the snapshot repository (註冊備份用的 S3 Path )
    5. Delete the `.kibana` alias (刪除 V6 預設的 `.kibana` Alias)
    6. Restore the snapshot of V5 (復原 V5 的資料到 V6 的 Instance)
    7. Delete the `.kibana` index (刪除 V6 內的 V5 .kibana index)
    8. Create the alias named `.kibana` from `.kibana_1` (根據 .kibana 從新建立 .kibana_1 的 alias)
    9. Wait for green status (等待同步完成)
- Kibana 設定匯出/匯入
    - 利用 Kibana Web Console 匯出 **Dashboard/Visualize/Search** 等資料 (json file)，等 V6 完成再匯入即可
{{<admonition warning "注意">}}
V5 的 kibana 無法匯出 Index Pattern·。如果有 V6 的DEV 環境，可以先把 PROD 的 Index Pattern 轉過去再使用 V6 匯出功能就可以連同 Index Pattern 一起輸出，這邊也要注意是否有設定 `scripted_fields`，如果轉移後有少會影響 Visualize 拉資料的轉換
{{</admonition>}}

- 確認其他 AWS Service 是否有正確轉換接到新的 ES 版本
    - 如果有使用 [Cloudformation](https://docs.aws.amazon.com/zh_tw/AWSCloudFormation/latest/UserGuide/Welcome.html) 可能會搭配 [SSM](https://docs.aws.amazon.com/zh_tw/systems-manager/latest/userguide/what-is-systems-manager.html) 的 [Parameter Store](https://docs.aws.amazon.com/zh_tw/systems-manager/latest/userguide/systems-manager-parameter-store.html) 來管理 ELK Endpoint。確保相對應的 ELK 參數都有被更新為新版

## Breaking Changes
- v6 不再支援 Multiple Mapping types
    - [Elasticsearch 6.0 Removal of mapping types](https://medium.com/@federicopanini/elasticsearch-6-0-removal-of-mapping-types-526a67ff772)
- v6 不再需要做 Store throttling
    - [ES Doc - Settings changes](https://www.elastic.co/guide/en/elasticsearch/reference/6.2/breaking_60_settings_changes.html#_store_throttling_settings)
- v6 有幾個重要的 Mapping 調整
    - [ES Doc - Mapping changes](https://www.elastic.co/guide/en/elasticsearch/reference/5.0/breaking_50_mapping_changes.html#breaking_50_mapping_changes)
    - `string` fields replaced by `text/keyword` fields
    - `index` property only accept `true/false`
- 其他檢查清單
    - [Elasticsearch 5.6.4升级到6.4.3配置检查](https://cloud.tencent.com/document/product/845/36106)


## Elasticsearch RESTful API
使用 ES 提供的 RESTful API 來備份、編輯 Index 及 Alias、刪除復原等動作。

- AWS 文件教學 [Working with AWS Elasticsearch SErvice Index Snapshots](https://docs.aws.amazon.com/zh_tw/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html)
- 我自己包的 [aws-scripts/es_snapshot.py](https://github.com/kylinfish/aws-scripts/blob/master/wrapper/es_snapshot.py)



## Blue/Green Deployments
操作同時，Create ES V6 跟 Enable Slow log action 要分開做沒辦法一次到位，同時要注意 [Blue/Green deployments](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains.html)，最後真的要做的時候可以把會進行 Blue/Green 的修改盡可能安排在一起，避免 Instance 數量很多的時候觸發會噴更多 $$$.

> Enabling or disabling the publication of error logs or slow logs to CloudWatch