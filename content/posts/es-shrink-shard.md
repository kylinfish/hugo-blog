---
title: "ElasticSearch 維運 - Shrink Shard"
description: "在 ElasticSearch 中如何縮小已經存在的 Indices Shard 個數"
date: "2021-06-24T14:19:36+08:00"
draft: false
tags: [ "ElasticSearch" ]
categories: ["技術"]

featuredImage: "/img/post/ElasticSearch.png"
images: [ "/img/post/ElasticSearch.png" ]
---

# Shrink the number of shards

## Brief introduction

1. Move all indices data into the same data node and block writing
2. Check data moving status util finish
3. Call `_shrink` api and assign the new name and settings(included # of shards)
4. Check the new indices creation status
5. Set the replica back, and check the new one and old one whether the doc.count is the same or not.
6. Delete old indices. (Be careful for all deletion, double check the snapshot before the deletion)


## Example
If we want to shrink the number of shards from 4 to 1 on `log-202105-0503-000005` indices.

```
health status index                     uuid   pri rep docs.count docs.deleted store.size pri.store.size
green  open   log-202105-0530-000005 xxxx   4   0   14845131            0     28.5gb         28.5gb
```

### Run Step 1.
   - Choose one unbusy data node and fill in `index.routing.allocation.require._name"` 
   - Set replica to 0 (for speed up whole progress)
   - Block write action

{{<admonition warning>}}
Change indices target and node name
{{</admonition>}}

```
PUT /log-202105-0530-000005/_settings
{
  "settings": {
    "index.number_of_replicas": 0,
    "index.routing.allocation.require._name": "X1imzcc",
    "index.blocks.write": true
  }
}
```
### Run Step 2. Check Status

```
GET _cat/recovery/log-202105-0530-000005?v&detailed&h=s,t,ty,source_node,target_node,files_recovered,bytes_percent&s=bytes_percent:desc
```

There are all in the same target_node (X1imzcc).
```
s t    ty   source_node target_node files_recovered bytes_percent
0 2.2m peer bzGs44F     X1imzcc     113             100.0%
1 2.2m peer HWatjUI     X1imzcc     107             100.0%
2 2.2m peer -3AWCw0     X1imzcc     113             100.0%
3 1.9m peer o3pEUt9     X1imzcc     118             100.0%
```

Most of time you have to block again, if you encounter the error about READ-ONLY issus

```
PUT /log-202105-0530-000005/_settings
{
  "settings": {
      "index.blocks.write": true                                    
  }
}
```


### Run Step 3. do _shrink action
   - `number_of_replica: 0` and `refresh_interval: -1` is for speedup action

{{<admonition warning>}}
Change indices target and the new indices name, and how many number of shards do you assign
{{</admonition>}}

```
POST /log-202105-0530-000005/_shrink/log-202105-0530-000005-s
{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "refresh_interval": -1
    },
    "index.routing.allocation.require._name": null,
    "index.blocks.write": null
  }
}
```


### Run Step 4. check status 

```
GET /_cat/recovery/log-202105-0530-000005-s/?v&h=index,shard,time

```
```
index                       shard time
log-202105-0530-000005-s 0     16.3s
log-202105-0530-000005-s 0     3.2s
```


### Run Step 5. Set replica back

```
PUT log-202105-0530-000005-s/_settings
{
  "index": {
  "number_of_replicas": 1,
  "refresh_interval": null
  }
}

```
```
GET _cat/indices/log-202105-0530-000005*?v&s=index
```

```
health status index                    uuid  pri rep docs.count store.size pri.store.size
green  open   log-202105-0530-000005   xxxx   4   0   14845131     28.5gb         28.5gb
yellow open   log-202105-0530-000005-s xxxx   1   1   14845131     28.2gb         28.2gb
```
Check the number of `docs.count` and `health` util all are ready.



### Run Step 6. Delete all indices
```
DELETE log-202105-0530-000005
```
