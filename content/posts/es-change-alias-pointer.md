---
title: "ElasticSearch 維運 - Change Alias Pointer"
description: "在 ElasticSearch 中改變 Alias Pointer"
date: "2021-06-24T14:19:36+08:00"
draft: false
tags: [ "ElasticSearch" ]
categories: ["技術"]

featuredImage: "/img/post/ElasticSearch.png"
images: [ "/img/post/ElasticSearch.png" ]
---
# Change Alias Pointer

The alias is your writer enterance, sometimes if you need to change the alias pointer to different concrete indices.

## Run Step 1. Create the new target concrete indices

```
PUT /test_new_target_indices
```

##  Run Step2. Change pointer

{{<admonition warning>}}
Update old indices is_write_index to false, the new one to true
{{</admonition>}}


```
POST /_aliases
{
    "actions" : [
        {
            "add" : {
                 "index" : "qlog-f-vbs-202104-0430-000006",
                 "alias" : "qlog-f-vbs-202104",
                 "is_write_index" : false
            }
        },
        {
            "add" : {
                 "index" : "test_new_target_indices",
                 "alias" : "qlog-f-vbs-202104",
                 "is_write_index" : true
            }
        }
    ]
}
```
