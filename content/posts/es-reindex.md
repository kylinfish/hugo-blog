---
title: "ElasticSearch 維運 - Reindex"
description: "在 ElasticSearch 使用 Reindex 的時機跟作法"
date: "2021-06-24T14:19:36+08:00"
draft: false
tags: [ "ElasticSearch" ]
categories: ["技術"]

featuredImage: "/img/post/ElasticSearch.png"
images: [ "/img/post/ElasticSearch.png" ]
---

# Reindex
Refer to https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html

Reindex: If you want to merge different concrete indices.

Sometimes if the indices is not balance like too many tiny indices or can not shrink number of shards to suitable number.

## Brief introduction
1. Create the new dest indices
2. Call `_reindex` action
3. Check reindex running status
4. Recover the indices setting to the new dest indices
5. Delete the old indices

## Example
We want to merge `qlog-fff-202105-000002`, `qlog-fff-202104-1`


### Run Step 1.
Create the dest indices with the right mappings and settings.
Check the template for index name if you want to apply some default settings.

- replica and refresh_interval are for speeding up the process.
```
PUT  qlog-fff-202104-0000-1
{
  "settings": {
    "index": {
      "number_of_shards": 2,  // Change here depends on your case
      "number_of_replicas": 0,
      "refresh_interval": "-1"
    }
  }
}
```

### Run Step 2.
- `slices` can speed up reindex process.
- By default `_reindex` uses scroll batches of 1000. You can change the batch size with the `size` field in the source element:
- Set dest indices by the previous one

```
POST _reindex?wait_for_completion=false&slices=auto&refresh=false
{
  "source": {
    "index": ["qlog-fff-202105-000002", "qlog-fff-202104-1"],
    "size": 5000
  },
  "dest": {
    "index": "qlog-fff-202104-0000-1"
  }
}
```

### Run Step 3.
check reindex status

```
GET _tasks?detailed=true&actions=*reindex

```

### Run Step 4.
Check the new indices `doc.size` whether is expected or not
Recover Settings
```
GET qlog-fff-202104-0000-1/_settings
PUT qlog-fff-202104-0000-1/_settings
{
  "index": {
  "refresh_interval": null, // depends on your default setting value
  "number_of_replicas": 1
  }
}

```

### Run Step 5.
Delete unnecessary indices.
```

GET _cat/snapshots/cs-automated?v&s=start_epoch:desc
GET _snapshot/cs-automated/2021-04-08t08-50-34.1efe36ab-ed7d-4dc7-b160-6014453d8774
## Check Snapshot before delection


DELETE qlog-fff-202105-000002
DELETE qlog-fff-202104-1"
```
