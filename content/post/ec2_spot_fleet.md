+++
draft = false
description = "Amaon EC2 Spot 基礎知識及 Design Patterns 和 Best Practice 旁聽筆記"
date = "2018-02-08T00:10:12+08:00"
tags = [ "AWS" ]
categories = [ "技術" ]
title = "Amaon EC2 Spot Fleet Design Patterns and Best Practice 筆記"
featuredImage = "/img/post/spot_instance.jpg"
images = ["/img/post/spot_instance.jpg"]
+++
2 月 7 日 參加 `Amaon EC2 Spot Fleet Design Patterns and Best Practice` 由 AWS User Group 台北小小聚主辦的活動

<!--more-->

是我第一次踏入 AWS 的社群聚會。平常沒什麼機會直接接觸 AWS 服務使用，最近在看文件的時候也不是這麼有感覺

於是今天來聽 [@Pahud Hsieh](https://www.facebook.com/profile.php?id=660510468) 分享關於 AWS EC2 Spot 的相關知識

以下紀錄我於議程中記錄到的筆記，把一些基本知識做清楚的理解，以及補充一些講者提到的最佳實踐筆記。

## Fundamentals

### Spot is legit.

同樣的 Workload 比別人便宜 90%，而不是全部都用 On-demand

- `On-demand`: 要機器的時候點或用 SDK 開，隨需的主機
- `Reserved`: 運行一段時間後，Reserved Instance (RI) 可以跟 AWS Sales 買，什麼都不用做結帳的時候會自動幫你打折
    - Pay by month
    - 可以互換 Family 或者跨 Region

-    `Spot`: 閒置的資源用競標的方式讓大家取得，有市場價格。簡言之用標價得到 On-demand 的機器

{{<admonition tip >}}
Spot Instance 可以讓機房利用率提高
{{</admonition>}}

以前是出的價格不等同於實際要付的費用，會以當時市場機制當作付費的金額

現在是不用出價，被踢走不會反應在價格上，價格跟供需不是直接相關

被踢走可以選擇把 EBS Volume 保留，等  Spot 回來之後可以重啟(但 Reboot 會 Memory lost，重要資料要定期備份到 S3)

拿的 Instance 的時候最好拿跨 AZ、跨家族避免同一個 Spot pool 裡面都被拿光你就 GG 了

-  AZ
-  Instance Size
-  Instance Family

這樣可以讓你的 Spot instance 保有 Flexibility ...

-  Instance flexible
-  Time flexible
-  Region flexible

{{<admonition tip >}}
可以選擇更便宜的 region

>不同訂價可能取決於當地環境，像東京用電較貴所以費用較高
{{</admonition >}}

----

## New Feature

- Spot Fleet: Support tag propagation.
- Encrypt EBS volumes at launch. (可以保證從 memory 回到 EBS 的過程也是加密的)
    -  Spot Fleet  load balancer integration
    - `如果是 TCP 應用用 NLB，如果是 HTTP 應用用 ALB `
- Spot Fleet support capacity zero.  (現在可以改成 0 了 XD)
- Spot Fleet support `Target tracking`. (可以設定平均的 CPU rate 的標準，自動調整 instance)
    - Target tracking 現在被用在很多服務中， e.g. DynamoDB

- Spot Fleet support T2 Instances.
- Spot interruption to CloudWatch Events
    - 以前當 Spot 要被收回的時候，要趕快上 Spot Clean up 自己的資料
    - 現在可以自動送到 CloudWatch (事件中心) 通知
    - _What can you do with that?_
        1. SSM run commands (Clean up 的 script)
        2. Lambda (用 Lambda 來調度，5 mins 限制)
        3. Step Functions (當機器要關機時，觸發某個 Step Function  ''workload'')
        4. ECS Tasks. (自包的 Container，執行一次性工作讓 ecs 幫你帶起來)
- Spot Region availability


## New Pricing Model

- Predictable price
- 預設出 On-demand 價格，但機器還是有可能會被收走，只是你不見得會付到 On-demand 的錢
- Default 是 On-demand 的價格，但還是可以自己出價


以前只能 Terminate

現在可以選擇要 Stop 還是要 Hibernate (目前只能由 Spot fleet 決定什麼時候觸發)

## Stop/Start

Spot fleet with maintain option: 如果 Spot 被收回了，打開這個 Option 他會在下一次有資源時幫你 on 回來

-  Use case
    - Workloads needing lengthy provisioning (e.g. software setup, networking)
    - Stateful applications that persist date to durable storage for user across session.
    - 開發測試、工作機都很適合


## Hibernate/Resume
- 把 Memory 的資料自動寫回 EBS Volumes
- EBS size must greater than Memory size.
- Use case
    - Long running task that keep state in memory

----

## Best Practices and Design Pattern.

### EC2 spot with ECS

現在可以在 ECS console就可以開 Spot，其中 allocation 策略還可以選
- Diversified(盡可能分散組合)
- Lowest price. (雞蛋有可能放在同一個籃子裡)

### 實作
1.  建議用 Diversified 得來做最小化 Distribution
2.  Lowest allocation 可以給 dev/testing/staging 環境使用
3.  Create CloudFormation template 用你的模板就可以讓別人起跟你一樣的環境 (Infra as code)
4.  Spot Fleet with ALB integration. (主機長起來自動往 Load balancer 註冊)
5.  Set size to 0 for cost saving (假日下班關機)
6.  Design your Spot Fleet auto scaling policies. (某些 Alarm 出現的時候，想要怎麼長機器)
7.  考慮 hybrid(Spot Fleet + On-demand/RI) for production. (註冊到同一個 ECS groupd)
8.  Container Draining with cloudWatch Events
    1.  ECS 有 Draining API, 可以讓你的主機通知要關機前，先讓 ELB 不會再把 connection 送進來，讓舊的做完再結束 instance

{{< figure src="https://cloudncode.files.wordpress.com/2016/07/hybrid_auto_scaling.png?w=640"
title="EC2 On-demand + RI 混搭 Spot Instance Case. img from: cloudncode.blog" >}}

{{< figure src="/img/post/serverless_sticker.jpg" title="AWS Serverless Sticker" >}}
