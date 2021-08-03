---
title: "從 MVC 談後端作業流 (Backend HTTP Workflow)"
subtitle: "何謂: Backend HTTP Workflow"
date: 2021-08-02T10:25:39+08:00
lastmod: 2021-08-02T10:25:39+08:00
description: "以 MVC 框架角度切入探討專案的可維護性，整理歸後端的作業流 Backend HTTP Workflow 進而釐清元件的邊界切分，使軟體設計更接近 SOLID、DRY、KISS 原則，同時使專案更容易修改、測試增進軟體專案品質"
tags: [ "PHP", "backend", "HTTP workflow"]
categories: [ "技術" ]
draft: false

featuredImage: "/img/post/backend-http-workflow/mvc-boundry.png"
images: [
  "/img/post/backend-http-workflow/workflow-with-component.png",
  "/img/post/backend-http-workflow/mvc-boundry.png",
  "/img/post/backend-http-workflow/laravel-arch.png",
  "/img/post/backend-http-workflow/fat-controller.png",
  "/img/post/backend-http-workflow/side-effect-example.png",
]
---

最近回 Backend 領域看 Team 內的後端開發給予建議，雖然號稱在使用 MVC 框架但還是有分[**可維護**](https://terms.naer.edu.tw/detail/1286733/)跟**不容易維護**的差別。

我試著用後端的 HTTP LifeCycle 或者可以說是 HTTP Workflow 來解釋如何在 MVC 上架構可維護的軟體程式設計。

## MVC 邊界
{{< figure src="/img/post/backend-http-workflow/mvc-boundry.png" title="MVC 邊界劃分" >}}
先不管 MVC 在社群上定義的爭議，Model、View、Controller 可以代表三個職責的切分。
在 [Clean Architecture](https://www.tenlong.com.tw/products/9789864342945) 一書中提到，其實它們分別代表的是三種不同的邊界切份
- Model => Database
- View => UI
- Controller => Business Logic

決定邊界的切分，其實蘊含的元件之間的相異性管控，以及職責的負責範疇。在實務上其實我們還會需要了解`粒度`的因子，從哪個角度切入看待你畫的邊界是否合適，或者需要再往下細分呢?



## 優美架構?
{{< figure src="/img/post/backend-http-workflow/laravel-arch.png" title="Laravel 優美架構" >}}

我們看過常常有人實踐除了 MVC 之外的元件出來協作溝通，原因是如果只照 MVC 的切份法 **(粒度較粗)**，很有機會造成單一元件過度肥大的狀況，過度肥大就容易造成可維護性變差。
> [圖片內容來源](https://docs.google.com/presentation/d/1rOWNct6tu8u63Gss8hHwz8KncWkP3yI3BR8dsDs1-Sg/edit#slide=id.g23a49237ff_0_0)
### 肥大的 Controller
{{< figure src="/img/post/backend-http-workflow/fat-controller.png" title="肥大的 Controller" >}}

- 難以 Trace
  - 大腦大概超過 50 行要記得前面寫什麼會顯的困難
- 異動時還容易有副作用
  - 修改的變數可能在肥大的範圍中被任意修改


### 元件切分
我們看到實作多種不同的元件，最常見的想必就是 Service 元件，使**粒度變得更細**。

好處有什麼?
- 提升可讀性，降低副作用
- [SOLID - SRP 單一職責](https://ithelp.ithome.com.tw/articles/10191955)
- [DRY (Don’t Repeat Yourself)](https://zh.wikipedia.org/wiki/%E4%B8%80%E6%AC%A1%E4%B8%94%E4%BB%85%E4%B8%80%E6%AC%A1)、[KISS (Keep It Simple, Stupid)](https://zh.wikipedia.org/wiki/KISS%E5%8E%9F%E5%88%99)
- 程式碼就是文件 [Code as Docucmentation](https://martinfowler.com/bliki/CodeAsDocumentation.html)
- 易於修改、測試、擴充  (可維護性提升)

一體兩面，成本呢?
- 開發時間增加
- 基礎門檻提高: 開發者須清楚元件之間的相依性

## 何謂後端 HTTP 作業流
我將他定義為: [**`Backend HTTP Workflow`**](/mvc-api-workflow/) ，意指 Request 進入到後端直到 Response 回到使用者端所經歷的工作流程。

後端 API 的開發其實是有模式的，不管是 Server Render 或者是 RESTful API，可以將 HTTP 進入後的 Life Cycle 做一個歸納。

### 常見的後端處理工作歸納
1. 檢查登入 / Header 處理/ Token 驗證
2. 使用者輸入資料驗證
3. 商業邏輯
4. 回饋反應 SSR/JSON/XML

{{< figure src="/img/post/backend-http-workflow/backend-http-workflow.png" title="後端 HTTP 作業流" >}}

### 根據工作透過元件職責劃分
除了 Model, Controller, View 之外 進而衍伸對應的處理元件就有機會看到
Middleware, Service, Presenter, Transformer, Repository 等等

{{< figure src="/img/post/backend-http-workflow/workflow-with-component.png" title="MVC 邊界劃分" >}}

遵循 [**`Backend HTTP Workflow`**](/mvc-api-workflow/)  的順序定義元件，就可乾淨賦予每個元件所對應的職責，同時也達到 Code as Documentation 的目的，每個元件可以直接看出分配的處理職責，也是因為選擇把粒度切得更細，讓職責單一化。

## 副作用避免
職責切處劃分，就不容易看到在巨大的程式碼區塊中無法掌握撰寫思維的窘境。
如下圖，巨大的區塊中，在都是檢查使用者輸入的區段中，突然發現有一小段商業邏輯的修改，這樣的設計容易造成 Trace 上的困難，也增加後續維護修改的難度。

{{< figure src="/img/post/backend-http-workflow/side-effect-example.png" title="常見的肥大程式碼中副作用" >}}


你知道自己經手專案中的工作流嗎?

有辦法按照職責切分元件以及歸納嗎?

