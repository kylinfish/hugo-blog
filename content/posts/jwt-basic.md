---
title: "Head First JSON Web Token (JWT)"
description: "設計 Web API 授權時常見 OAuth 與 JWT。認識 JSON Web Token（RFC 7519）的 Header、Payload、Signature 結構，以及為什麼要用 JWT。"
date: "2017-07-24T14:58:50+08:00"
lastmod: "2021-07-07T09:30:12+08:00"
draft: false
tags: [ "JWT", "JSON" ]
categories: ["技術"]
featuredImage: "/img/post/jwt.jpg"
images: [ "/img/post/jwt.jpg" ]
---
在設計 Web API 的時候常常會需要授權或者是驗證，常見的框架跟標準就屬 OAuth 跟 JWT 兩種

這次來看看 JWT 的知識介紹以及為什麼要用 JWT?


> JWT 是基於 JSON 的開放標準 (RFC 7519)

> 一般被用來在 __身份提供者__ 和 __服務提供者__ 間傳遞被 __認證__ 的用戶身份信息，以便於從資源伺服器獲取資源

> 同時也可以增加一些額外的聲明信息，該  token 也可直接被用於認證，也可被加密

> from: https://read01.com/PgGDgy.html


## JWT 的組成

JWT 的組成內容有三個部分，由 `. (dots)` 做區隔

1. Header
2. Payload
3. Signature

最後表示法就像這樣 `xxxxx.yyyyy.zzzzz`

#### 1. Header
* typ
* alg

參數宣告加密的方法，`HMAC`、`SHA256` 或 `RSA` 進行 __Base64__ 編碼，成為 JWT <b class="text-primary">第一個部分</b>

#### 2. Payload
這裡放聲明內容，可以說就是存放溝通訊息的地方，在定義上有 3 種聲明 (Claims)

* Reserved (註冊聲明)
* Public (公開聲明)
* Private (私有聲明)

其中 Reserved 註冊聲明中含有被預先定義的的項目，這些是建議使用的項目，紀錄在 [RFC 標準#registered_claim_names](https://tools.ietf.org/html/rfc7519#section-4.1) 中

* "iss" (Issuer)
* "sub" (Subject)
* "aud" (Audience)
* "exp" (Expiration Time)
* "nbf" (Not Before)
* "iat" (Issued At)
* "jti" (JWT ID)

一樣經過 __Base64__ 編碼形成 JWT <b class="text-primary">第二個部分</b>

#### 3. Signature
<b class="text-primary">第三個部分</b> 是用來確定發送請求對象的身份驗證，由前面兩個部分一起加密形成。以 HMAC SHA256 加密演算法為例:
{{<admonition info >}}
HMACSHA256( base64UrlEncode(header) + "." + base64UrlEncode(payload), secret)
{{</admonition >}}

## JWT 建議使用方式
#### ❖ 取得 JWT Token
情境是會先有登入的授權行為來發放 Token，拿到 Token 的 Client 建議以 Local storage 的方式來儲存，cookie 亦可。透過 Request header 送出

#### ❖ JWT Token 驗證
使用 `Bearer Token` 的方式進行溝通
{{<admonition info >}}
Authorization: Bearer <JWT token>
{{</admonition >}}

{{< figure src="https://cdn.auth0.com/content/jwt/jwt-diagram.png" title="JWT-Token process diagram" >}}


## Main Idea
[from: 5 Easy Steps to Understanding JSON Web Tokens (JWT)](https://medium.com/vandium-software/5-easy-steps-to-understanding-json-web-tokens-jwt-1164c0adfcec)

> The data inside a JWT is __encoded__ and __signed__, not ___encrypted___.

JWT 內的 `資料` 組成方式是就由簽名 (防偽造) 及編碼所處成，`並非加密`。

> The main purpose of encryption is to secure the data and to prevent unauthorized access

主要目的是為了保護資料以及確保請求是來自於`『已授權的行為』`。


## Why JWT?
* JSON 比 XML 普及，相較之下結構也簡單，支援多種程式語言
* 可以儲存簡單但 __非敏感__ 的商業邏輯訊息
* 構成內容簡單，佔用 Size 小方便傳輸
* Stateless
	* 可以降低 Server 保存 Session 的 loading
	* 容易做到跨平台的應用擴展，如 SSO 應用

## Security
* Base64 只是一種編碼方式，所以 JWT 不適合儲存敏感訊息。也就是說 JWT 的 Token 內容是可以被解析的
* 用來加密的 Secret 要保存在 Server 不應外流
* 請使用 `Https` 確保在授權的時候不會被竊聽
* 建議開啟 `Http only` 防止 Token 被擷取，這也是常見的來 XSS 防護方法之一

----

## 常見問題

 {{<admonition question "①  JWT 安全嗎?" >}}
Base64 編碼方式是可逆的，也就是透過編碼後發放的 Token 內容是可以被解析的

一般而言，我們都不建議在 Payload 內放敏感訊息，比如使用者的密碼
{{</admonition >}}


{{<admonition question "②  JWT Payload 內容可以被偽造嗎？">}}
JWT 其中的一個組成內容為 Signature，可以防止藉由 Base64 可逆方法回推 payload 內容並將其修改。

因為 Signature 是經由 Header 跟 Payload 一起 Base64 組成的。當然如果你的加密的金鑰 (secret) 流失，
便可經由第三方自行重置合法的 Token 導致失去驗證授權與否的效益
{{</admonition >}}

{{<admonition question "③  如果我的 Cookie 被竊取了，那不就表示第三方可以做 CSRF 攻擊?" >}}
是的，Cookie 掉了，就表示身份就可以被偽造。故官方建議的使用方式是存放在 LocalStorage 中，並使用 Header 送出
{{</admonition >}}

#### 看更多 (More)
* [🔗  深入探討 JSON Web Token (JWT)](https://kylinyu.win/jwt-advanced/)

----

#### 參考資料
* [🔗  JWT 官網](https://jwt.io/introduction)
* [🔗  八幅漫畫理解使用JSON Web Token設計單點登錄系統 ](http://blog.leapoahead.com/2015/09/07/user-authentication-with-jwt/)
* [🔗  5 Easy Steps to Understanding JSON Web Tokens (JWT)](https://medium.com/vandium-software/5-easy-steps-to-understanding-json-web-tokens-jwt-1164c0adfcec)
