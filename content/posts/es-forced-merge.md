---
title: "ElasticSearch 維運 - Forced Merge"
description: "在 ElasticSearch 中改變 Alias Pointer"
date: "2021-06-24T14:19:36+08:00"
draft: false
tags: [ "ElasticSearch" ]
categories: ["技術"]

featuredImage: "/img/post/ElasticSearch.png"
images: [ "/img/post/ElasticSearch.png" ]
---

# Force Merge

Force merge action can clean up `docs.delete`, make read preformace better and save more disks space for the snapshot.

Please refer to ES Document https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-forcemerge.html 

### Run Step 1.

{{<admonition warning>}}
The response will be sent utils the forcemerge action is done.

So you will usually encounter timeout on the production indices.

After enter the request, you can skip to wait manually.
{{</admonition>}}

```
POST qlog-b-202105-0521-000004/_forcemerge?max_num_segments=1

// Ctrl C? or waiting util timeout
```

### Run Step 2.

Check the forcemerge task progress, and confirm the action wheather handling or not

```
GET _tasks?&actions=*merge&detailed
```

```
Example response
{
  "nodes" : {
    "xbmaFOeBQhuZwCnZ1OWkiA" : {
      "name" : "xbmaFOe",
      "roles" : [ "data", "ingest" ],
      "tasks" : {
        "xbmaFOeBQhuZwCnZ1OWkiA:212136250" : {
          "node" : "xbmaFOeBQhuZwCnZ1OWkiA",
          "id" : 212136250,
          "type" : "transport",
          "action" : "indices:admin/forcemerge",
          "description" : "",
          "start_time_in_millis" : 1623047029333,
          "running_time_in_nanos" : 4016357042,
          "cancellable" : false,
          "headers" : { }
        }
      }
    }
  }
}
```

