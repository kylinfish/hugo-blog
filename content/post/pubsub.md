+++
categories = ['技術']
tags = ['Google']
date = "2017-06-19T19:09:12+08:00"
description = "HEAD FIRST Google Pub/Sub"
title = "認識 Google Pub/Sub"
absolute_banner = "https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Fwp_flow.png?alt=media&token=af267843-69e6-438a-a528-cc8bf5bdfa70"
og_images = ["https://firebasestorage.googleapis.com/v0/b/hugo-81880.appspot.com/o/post%2Fwp_flow.png?alt=media&token=af267843-69e6-438a-a528-cc8bf5bdfa70"]
+++

初探 Google PubSub，根據官方文件來做筆記

[🔗  What is Google Cloud Pub/Sub?](https://cloud.google.com/pubsub/docs/overview)

<!--more-->
`Pub/Sub` 是一種 messaging service，適合拿來做不同服務間的 __訊息傳遞__ 或者 __狀態同步__ 。

## ❖ 主要名詞認識
* __Message__: 要傳送的 data
* __Topic__: 主題，是一個可以被訂閱訊息的實體
* __Subscription__: 訂閱，連結 Topic 跟 Subscriber 之間的實體，接收以及處理發佈訊息到 Topic
* __Publisher__: 發布者，提供並且發送訊息到 Topic 的單位
* __Subscriber__: 訂閱者， 訂閱訊息的一個單位

----

## ❖ 簡易情境
![Image](https://cloud.google.com/pubsub/images/wp_flow.svg)

* A, B 同時可以 publish message 到相同的 Topic
* 該 Topic 有兩個 subscriptions
 * `Subscription 1` 有 2 個訂閱者
 * `Subscription 2` 有 1 個訂閱者

----

## ❖ Performance
主要由 ___Scalability___, ___Availability___, ___Latency___ 來決定

* __Scalability__
 * publisher 的數量
 * topics 的數量
 * subscriptions 的數量
 * message 的數量
 * message 的 size 大小
 * ... etc

* __Latency 主要有兩個因素__
 * 確認已發佈的時間：也就是 ack 已發送的訊息的延遲
 * 訊息發送給訂閱者所需的時間

----

## ❖ Message 的生命週期
1. publish 一則 message
2. message 被寫入 storage
3. `Google Pub/Sub` 送一個 ack 給 publisher 說我收到你要傳遞的 message ，並且已經發給所有的訂閱者
4. 在訊息寫入 storage 的同時 `Google Pub/Sub` 傳給訂閱者
5. 訂閱者傳送 ack 給 `Google Pub/Sub` 說我在處理 message
6. 訂閱者至少 ack 過每一則訂閱的 message 之後， `Google Pub/Sub` 就會從 storage 移除

----

## ❖ Subscriber 操作面

#### 對訂閱者來說有兩種處理 Message 的方式，分別為 __PULL__ 跟 __PUSH__.

* [`push`](https://cloud.google.com/pubsub/docs/push)
 * 送一個 request 給 App 的 endpoint 說我要傳訊息來。
 * 以這個 endpoint return `[200, 201, 204, or 102]` 來判定為 ack, 如果不是就會一直被打直到這個訂閱所設置的最大 retention time 為止
 * 動態調整 push 的 request，根據拿到的狀態碼來調整。

* [`pull`](https://cloud.google.com/pubsub/docs/pull)
 * 視為被動的取得訂閱佇列 (subscription queue) 中的 Message

#### 兩者機制要怎麼選用，有以下建議

* `push`
 * 低流量情形 (< 10,000/second)
 * Legacy push webhook
 * App Engine 的訂閱者


* `pull`
 * 大量的訊息 (many more than 1/second)
 * 效能跟訊息遞送因素很重視者
 * 公開的 Https Endpoint

----

## ❖ Subscription 的生命週期

* 31 天內沒有被 pull or push 就會被自動刪除，或者經過手動操作被刪除
* 訂閱的名字沒有絕對關係，用同樣的名字也會被視為兩者不同的訂閱(情境可能是：刪除前，刪除後)
* 刪除後就算有大量還沒寄出的訊息，或者是 Backlog，都與新建立的無關
