+++
draft = false
description = "AWS re:Invent 2017 Keynote Summary"
date = "2017-12-27T00:09:12+08:00"
tags = [ "AWS", "reinvent" ]
categories = [ "技術" ]
title = "AWS re:Invent 2017 Keynote Day1 Recap"
absolute_banner="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Freinvent-keynote1.jpg?alt=media&token=b29029ce-b1e7-4e19-b687-a3020954e291"
og_images = ["https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Freinvent-keynote1.jpg?alt=media&token=b29029ce-b1e7-4e19-b687-a3020954e291"]
+++
<style> h3 { color: #309ac1; } </style>

今年 AWS Keynote 由 CEO - Andy Jassy Release 出不少令人驚艷的服務

有幸今年去到拉斯維加斯現場 Keynote 感受整體的臨場氣氛以外，來做個簡單的中文 Summary 吧!

<!--more-->

{{< youtube 1IxDLeFQKPk >}}

AWS 在這幾年的努力之後，除了累積了大量的企業用戶，整體的產品線不斷擴張之下使得業務也大量成長

在奠定了良好的雲端架構之後，現在 AWS 要做的目標是:

- Resiliency 彈性
    - Disater recovery 災難復原
- Optimization 最佳化
    - Developer empowerment
    - Build deploy and optimize applications
    - Just focus on writing your code
- Performance 效能
    - Data analysis
    - Innovation agility
    - Customer experience

Andy 今年主要 Announce 所有與服務相關的項目，我們大致上可以分門別類為以下幾個大項

<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Freinvent_1.jpg?alt=media&token=06239f3c-820e-4843-9bf6-e6940a946e90" width="100%">

## Compute
包含運算單位的機器升級，產品變革。

其中今年關注的最大賣點莫過於 EKS 的釋出，為容器化的世界帶來更大的整合

### Elastic Container Service for Kubernetes (EKS)
<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Feks.jpg?alt=media&token=e0ca46e7-ed29-4f01-82e0-b39578825271" width="100%">

AWS 宣布 Support Kubernetes 了，這可以確認 Kubernetes 現今在 Container 場的地位

接著 Andy 提到：

> managed clusters are great... but what else?


### AWS Fargate
<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Ffargate.jpg?alt=media&token=a33ead71-24aa-4160-b70f-17cf6bb9e6cb" width="100%">

- no cluster to manage
- manages underlying infra
- easy to run, easy to scale

基於 ECS 與 EKS 之上的執行 Container.

AWS Fargate 讓管理者只需要規劃 container ，專注於建立你的應用程式而免除管理 EC2 的 instances。

最重要的是當你要做 Scale 的時候，不再需要去選擇你的 instance type 、管理 cluster schedule 或其餘的最佳化


## Database

在資料庫層面，今年要強調的是全球化的支援

### Aurora Multi-Master
<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Faurora_multi-master.jpg?alt=media&token=2078e665-6cfb-4a1a-9f20-2da42abc2eb5" width="100%">

號稱 node failure 跟 AZ 的 failure 沒有 downtime 

在 2018 年還會 support Multi-region


### Aurora Serverless

自動幫你根據流量來做 scale-up/down

- automatically scales capacity up and down

### DynamoDB Global Tables
<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Fdynamodb_global_tables.jpg?alt=media&token=d57107d0-0895-456c-bb8b-fc6acd5987bd" width="100%">
另一個全球化業務的 Support 就是 DynamoDB 的 Global Tables
對於 Serverless 的架構支援是很大的關鍵，但相信台灣的市場跟業務其實很少有機會使用到

- high performance, globally distributed applications
- low latency


### Amazon Neptune
<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Fneptune.jpg?alt=media&token=402428b3-3275-4059-abe5-32529db08b39" width="100%">
fully managed graph database

- 6 replicas (reliable)
- open support apache and pgrah model
- fast


## Analytics & Big Data


### S3 and Glacier Select
<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Fs3_select.jpg?alt=media&token=cb59a63f-0761-4586-9fe7-b53b771fe866" width="100%">
S3 被廣泛的使用，其中

- most popular choice for data lakes is S3
- 整合性很高，容易部署到其他平台，也容易把資料丟進來 object-level 管理性佳
- 安全性很高
- 透過 AWS Glue 整合到其他串流服務 e.g. kinesis, quicksight
- 表示分析這件事情在 AWS 整合性很高

S3 Select 簡言之即是  partial select，部份擷取將可以更快速也能更省成本

相信這個新的 Feature 將帶給各種業務需求更好的效能支援

## Machine Learning
涵蓋範圍有機器學習，自然語言處理，語音辨識

### Amazon SageMaker
<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Fs3_select.jpg?alt=media&token=cb59a63f-0761-4586-9fe7-b53b771fe866" width="100%">

### AWE DeepLens
<img src="https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Freinvent%2Fkeynote1%2Fdeeplens.jpg?alt=media&token=3035b795-a59c-4c7e-9a86-6241a45e6286" width="100%">
一台內建深度學習的攝影機

- Amazon Rekognition Video 影片辨識
- Amazon Kinesis Video Streams 即時的影片串流服務
- Amazon Transcrib 語音辨識
- Amazon Trasnslate 翻譯
- Amazon Comprehend
    - entities
    - key phase
    - language
    - discover valuable insights form text 找到文章的重點

在 Machine Learning 就我個人曾經做過一點機器學習研究的淺薄之見， AWS 提供了更多方便的工具降低了串接以及實驗性的門檻，
再者利用運算能力把許多分析做到 realtime。

除了提供開發者更快速的實踐模型之外，在業務成長的時候遇到效能的瓶頸，也能透過 AWS 的服務做到升級


## IoT

最後在物聯網的部分，AWS 想要營造的是:

- Easy to trigger
- Easy to management
- Nice security
- Analysis
- Samller devices.

### Getting into the Game
- AWS 1-click
    - Trigger by lambda function in every deviec.

### Device Management
- AWS IoT Device Management

### IoT Security
- IoT defender
    - audit device policies
    - monitor
    - alarm

### IoT Analytics
- AWS IoT analysis
- AWS IoT FreeRTOS


在一次聽下這麼多不同領域的功能發佈的同時，其實該說的是萬事俱備之下

## 『唯一的限制即是如何使用雲的技能？以及如何利用雲來架構你的服務』

