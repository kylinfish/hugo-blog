+++
description = "如何透過 Reindex 以及 alias 搭配不停機 indices 合併?"
tags = [ "ElasticSearch", "Kibana" ]
categories = [ "技術" ]
date = "2021-04-09T09:31:24+08:00"
title = "ES Merge multiple indices in one by reindex API"
absolute_banner="/img/post/ElasticSearch.png"
og_images = ["/img/post/ElasticSearch.png"]
+++

如何透過 <a href="https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html">ES Reindex API</a> 
以及 alias 搭配不停機 indices 合併?

首先，確保你的環境寫入是針對 Alias Target 做寫入，這樣就可以在後面隨便你搞不停機。
<!--more-->

簡描一下流程：
* 讓 Alias 指向一個全新的 indices 做線上串流寫入
* 建立新的 indices 作為你要合併的 Destination
* 透過 reindex 進行多 indices 合併，同時如何進行加速
* 檢查 reindex 進行的狀態
* 完成後把為了加速的設定改回來(設定 Replica 會造成 <span class="text-warning">YELLOW</span> Status)



1. Check the new version indices with right provided name
{{< highlight shell >}}
GET _cat/indices?v&s=index
GET _cat/indices/qlog-fff*?v&s=index
{{< /highlight  >}}

2. Check the index and aliaes create or not
{{< highlight shell >}}
GET _cat/aliases/qlog-fff*?v&s=alias
GET _alias
{{< /highlight  >}}

3. Change `is_write_index` pointer from the old to the new one.
{{< highlight shell >}}

POST /_aliases
{
    "actions" : [
        {
            "add" : {
                 "index" : "qlog-fff-202104-1",
                 "alias" : "qlog-fff-202104",
                 "is_write_index" : false
            }
        },
        {
            "add" : {
                 "index" : "qlog-fff-202104-0408-1",
                 "alias" : "qlog-fff-202104",
                 "is_write_index" : true
            }
        }
    ]
}

{{< /highlight  >}}


4. Create the new index for reindex merge target
{{< highlight shell >}}

PUT qlog-f-vbs-202104-0000-1/
{
  "settings": {
    "index": {
      "number_of_shards": 2,  // Change here depends on your case
      "number_of_replicas": 0,
      "refresh_interval": "-1"
    }
  }
}

{{< /highlight  >}}

    - __For speeding up reindex action__:
        - set the `number_of_replicas` to 0
        - set `refresh_interval` to -1
        - More, check the number_of_shards case by case (calculate the total indices after merging)


5. Do reindex for merging indices
{{< highlight shell >}}

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

{{< /highlight  >}}

    - __For speeding up reindex action__:
        - Set the batch size
        - use <a href="https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-reindex.html#docs-reindex-automatic-slice">sliceing action</a> to run reindex with multiple threads


6. Check reindex status
{{< highlight shell >}}

GET _tasks?detailed=true&actions=*reindex

{{< /highlight  >}}


7. Recover the settings for the new indcies
{{< highlight shell >}}

GET qlog-fff-202104-0000-1/_settings
PUT qlog-fff-202104-0000-1/_settings
{
  "index": {
  "refresh_interval": null,
  "number_of_replicas": 1
  }
}

{{< /highlight  >}}

    After reindex action, set the `refresh_interval` and `replica` back


8. Delete old indices
{{< highlight shell >}}

    GET _cat/snapshots/cs-automated?v&s=start_epoch:desc
    GET _snapshot/cs-automated/2021-04-08t08-50-34.1efe36ab-ed7d-4dc7-b160-6014453d8774

    DELETE qlog-fff-202104-1
    DELETE qlog-fff-202105-000002
    
{{< /highlight  >}}

    Check the snapshot or not before deletion
