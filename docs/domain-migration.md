# 網域 kylinyu.win 轉移計畫(Gandi → Cloudflare Registrar)

> 建立日期:2026-06-17
> 狀態:**計畫中**(2026-06-16 剛在 Gandi 續費,等下個續約週期前提前作業)

## 背景

- 2026-06-10 網域到期 → 一度被 Gandi 設成 `clientHold`,整個 DNS 委派被抽掉,網站全斷。
- 2026-06-16 已重新續費,到期日延到 **2027-06-10**,`clientHold` 解除。
- 痛點:Gandi `.win` 續費 **~2100 TWD/年(~$65 USD)**,過於昂貴。

## 目標

把網域轉移到 **Cloudflare Registrar**(成本價、零加價)。

| 註冊商 | `.win` 續費/年 | 約合台幣 |
|--------|--------------|---------|
| **Cloudflare Registrar** | **~$5.16 USD** | **~165 元** ✅ |
| Porkbun / Spaceship | ~$10–15 USD | ~350–480 元 |
| Gandi(現況) | ~$65 USD | 2100 元 |

每年省約 **1900 元**。

## 為什麼選 Cloudflare

- DNS 本來就在 Cloudflare(NS:`joel.ns.cloudflare.com` / `etta.ns.cloudflare.com`)。
- 轉移後 registrar + DNS 同一家,DNS 記錄 / Worker(`workers/`) / SSL 全部沿用,**幾乎不用改設定**。
- 成本價,不玩首年低價、續費爆貴。

## 時間點注意事項

- ICANN 規則:**註冊 / 上次轉移後 60 天內**不可轉移(續費不在此限,但保險起見不要剛續完馬上轉)。
- 轉移通常會 **自動 +1 年** 疊加到現有到期日,所以剛在 Gandi 續的那年不會白費。
- 到期日 2027-06-10,建議 **提前約 6–7 週(2027-04 中下旬)** 啟動,留足轉移完成 + 緩衝時間。
- 已建立行事曆提醒:見同目錄 `kylinyu-domain-transfer-reminder.ics`(自行匯入)。

## 轉移步驟

### Gandi 端
1. 解除網域鎖定 → 移除 `clientTransferProhibited`(unlock domain)。
2. 取得 **授權碼 / EPP / Auth code**。
3. 暫時關閉 WHOIS 隱私(若有,部分流程需要)。

### Cloudflare 端
4. Dashboard → 帳號 → **Domain Registration → Transfer Domains**。
5. 選 `kylinyu.win`,貼上授權碼,付款(~$5 多)。
6. 等轉移完成(通常 5 天內,常常數小時就過)。

### 完成後
7. 確認到期日已 +1 年(預期 ~2028-06-10)。
8. 確認 DNS 記錄、Worker 路由、SSL 都正常(NS 不變,理論上零影響)。
9. 在 Cloudflare 開啟 **auto-renew**,綁定有效付款方式。

## 參考連結

- Cloudflare 價目:https://tldprice.org/registrar/cloudflare
- Cloudflare 轉移文件:https://developers.cloudflare.com/registrar/get-started/transfer-domain-to-cloudflare/
