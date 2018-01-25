+++
description = "介紹常見的 RESTFul API 使用 Token 產品對接驗證的設計方式"
date = "2018-01-25T01:25:12+08:00"
tags = [ "API", "JWT", "OAuth2" ]
categories = [ "技術" ]
title = "API Token 驗證方式設計"
absolute_banner="/img/post/api_token.jpg"
og_images = ["/img/post/api_token.jpg"]
+++

後端常見的工作是在對應的產品上出各種 API 提供串接，串接方有可能是 ___瀏覽器、手機___，另外在微服務 (MicroService) 興起的同時
___Server 與 Server 對接___ 也是常見的溝通方式。

各服務使用 API 溝通的同時，除非是公開的 API 不需要認證，不然一般的 API 可能都需要經過 `認證` 或者是 `授權` 的行為
來取得使用的允許權。

<!--more-->
<br>

然而在當今雲端架構技術成熟，可以使用雲端服務提供的驗證服務，如 Amazon API Gateway 或 Google Cloud Endpoints 等
可以達到上述的需求特性，這是在架構層面。

當然應用程式面不可避免的還是需要應付更細微複雜的需求，不同的情境取決於不同的方法做設計，安全性考量也將會是選擇考慮
的重要因子之一。

以下簡介我對於常見的 API Token 串接的設計特性簡介以及優缺分析，提供大家能夠在設計上快速釐清:

- 自行設計 Token
- JWT Token
- OAuth 2.0 驗證


## 自行設計 Token
- <b class="text-primary">適用情境</b>：自家 Server 服務對接，亦即呼叫者都為自家服務或者 Server
- <b class="text-success">優點</b>:
    - 實作簡單
- <b class="text-warning">缺點</b>:
    - 必須 Hardcode 設定
    - 更新 Token 的話 Client 和 Server 都要手動更新
- 備註：
    - 如果提供多組 Client 都可以存取，需要把 Token 分開處理。
      當需要把某一組 Token 設定為失效的同時，可以讓其他組的 Token 可以持續生效

## JWT Token
- <b class="text-primary">適用情境</b>：
    - 需要針對個人身份辨識做發放者
    - MicroService Server or Client Side 服務串接
    - 單次認證行為使用 (e.g. Email 驗證)
- <b class="text-success">優點</b>:
    - 根據單一身份或行為進行客製發放
    - 需要夾帶欲使用的(非敏感)資料
    - 設定 Expired time 來降低 Token 流失後作用的風險
- <b class="text-warning">缺點</b>:
    - 發出去無法收回，只能等 Token 失效，或者在 Server 端建立黑名單機制做 Block 阻擋
    - 更新 Token 的話 Client 和 Server 都要手動更新
- 備註：
    - 需注意編碼長度的問題，是否會超出 JS cookie 或者 Local Storage 的儲存長度
    - 與 CSRF 攻擊預防無關，只要 JS 可以 Work，Token 就有機會被竊取而造成攻擊
    - [可以看我先前深層筆墨 JWT 的介紹](/tags/jwt)

## OAuth 2.0 驗證

- <b class="text-success">優點</b>:
    - 相較於 `自設計 Token 對接` 以及 `JWT Token` 對接提供更大管理上的彈性，
    - 可以設定作用域以及存取資料範圍
- <b class="text-warning">缺點</b>:
    - 流程繁瑣，嚴謹

- 備註： 不同種的 Grant 有不同的適用情境，下列簡述:

#### OAuth Grant 簡介

#### ❖ __Authorization Code Grant__
- <b class="text-primary">適用情境</b>：
    - 可保存 client credentials， e.g. client secret, refresh token
    - 不被他人看到的第三方 APP，e.g. Server-side Web APP
- 各家 OAuth2 provider 幾乎都會實作，e.g. Google, FB, Amazon

#### ❖ __Implicit Grant__
- <b class="text-primary">適用情境</b>:
    - 無法保存 Client Secret 會被他人看到的第三方 APP，e.g. Mobile/Desktop APP, JavaScript Web APP

#### ❖ __Client Credentials Grant__
- <b class="text-primary">適用情境</b>：
    - OAuth2 Client 直接向 Authorization Server 取得授權的情境。
    - OAuth2 Client 自己就是 Resource Owner。

#### ❖ __Resource Owner Password Credentials Grant__
- 此授權流程需要使用者輸入帳密，所以一般不開放給外部開發者的 OAuth2 Client 使用，避免使用者帳密被第三方紀錄的風險。
- <b class="text-primary">適用情境</b>：
    - 適用於自家開發的 APP，e.g. Mobile/Desktop APP

