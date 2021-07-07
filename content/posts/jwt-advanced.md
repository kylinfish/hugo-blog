---
title: "深入探討 JSON Web Token (JWT)"
description: "深入探討 JWT 的特性，以及使用情境跟安全顧慮"
date: "2017-07-29T22:26:50+50:00"
lastmod: "2021-07-07T09:30:12+08:00"
draft: false
tags: [ "JWT", "JSON" ]
categories: ["技術"]

featuredImage: "/img/post/jwt-security.png"
images: [ "/img/post/jwt-security.png" ]
---
在上一篇寫了 [初探 JWT 知識](https://kylinyu.win/head-first-json-web-token-jwt/)之後，進一步查找 JWT 相關知識發現了一篇這樣的觀點

[Stop Using Jwt For Sessions.](http://cryto.net/~joepie91/blog/2016/06/13/stop-using-jwt-for-sessions/)
不要用 JWT 取代 Server-side 的 Session 狀態機制

讀完之後，更深刻的提醒 JWT 機制的一些弊病

## 摘要與名詞解釋
- **Stateless JWT Token**
  - 原本是在 Session 中保存的 data，直接對其 data 編碼形成 Token
- **Stateful JWT Token**
  - Token 裡面只存放 Session Server 裡的 Session ID，而 Session data 一樣存於 ServerSide Server 中

{{<admonition warning "引用文澄清">}}
不是叫你都不要使用 JWT，而是 JWT 不適合拿來取代 Session 機制，這樣是很**危險**的
{{</admonition>}}

JWT 如果要拿來取代 Session 機制會有安全性疑慮問題在於，Token 的設計精神與使用方式有以下的問題:

## 實務問題
### Stateful JWT 功用如同 Session 機制所提供的
**Stateful JWT Token** 做法其實就類同 Session 的機制，沒有良好的測試及仔細評估的實踐之外，也會有 Client 端是否支援串接的問題。但其實會想用 JWT 就是因為 `Stateless` 的特性，應該較少人會拿來實作成 `Stateful`

### 空間以及長度問題
JWT Token 通常長度不會太小，特別是 `Stateless JWT Token`，把所有的 data 都編在 Token 裡，很快的就會超過 Cookie 的大小(4K)或者是 URL 長度限制

### 不能讓 Token 失效
1. `Stateless JWT Token` 發放出去之後，並不能透過 ServerSide 讓 Token 失效，必須等到 expire 時間過才會失去效用
2. 假設在這之間 Token 被攔截，或者有權限管理身份的差異造成授權 Scope 修改，都不能阻止發出去的 Token 失效並要求使用者重新請求新的 Token

其中，我最認同作者對於後兩點的說法。當然也不是不能用 JWT，其實也有適合使用的情境

##  JWT 適用情境
* MicroService architecture
* Single-use authorization
* One-time authorization
    * 忘記密碼連結
    * 信箱認證


## JWT 良好實踐

[JWT the right way](https://stormpath.com/blog/jwt-the-right-way)

* 不要存放敏感資料在 Token 裡
* Payload 中的 `exp` 時效不要設定太長
* 如果擔心 replay attacks 可以多宣告 `jti`, `exp`
* 開啟 `Http only` 預防 XSS 攻擊
* 在你的 Application 應用層中增加黑名單機制，必要的時候可以進行 Block 做阻擋 (這是針對掉 Token 被第三方使用竊取的的手動防禦)

## 一些容易誤會的謬誤

{{<admonition question "用 JWT 是為了輕易做到水平擴張?" >}}
 現在許多軟體可以做到這點，如把 Session Server 抽出來用 redis, memcache server 來做共同管理，也能輕易對 Application Server 做水平擴張
{{</admonition>}}

{{<admonition question "用 JWT 會更安全?" >}}
 很顯然這篇提出很多安全上的疑慮，相較之下 OAuth 2.0 提供更完善的授權機制，或者使用一般的 Session Server 機制也比 Stateless JWT Token 來替代的作法更佳
{{</admonition>}}

{{<admonition question "使用 JWT 可以預防 CSRF 攻擊?" >}}
  CSRF 的防禦是透過 CSRF Token 來防範，在此與 Session 機制無關。由於使用方式是透過 Cookie 跟 LocalStorage，只要 JavaScript 可以 Work 就有風險被竊取 Token 造成攻擊
{{</admonition>}}


以上兩篇針對 JWT 的討論與筆記，如果有不同的意見歡迎討論，如果有錯誤也歡迎指證。 感謝


----

#### 參考資料
* [🔗  JWT, wtf?](https://www.slideshare.net/Codemotion/jwt-wtf-phil-nash-codemotion-amsterdam-2017)
* [🔗  Stop using JWT for sessions](http://cryto.net/~joepie91/blog/2016/06/13/stop-using-jwt-for-sessions/)
* [🔗  Stop using JWT for sessions, part 2: Why your solution doesn't work](http://cryto.net/~joepie91/blog/2016/06/19/stop-using-jwt-for-sessions-part-2-why-your-solution-doesnt-work/)
* [🔗  Use JWT the right way](https://stormpath.com/blog/jwt-the-right-way)
