---
title: "Mailquill — 把散在 Gmail 的銀行帳單，收攏成一本離線財務帳"
description: "記帳不該靠毅力。Mailquill 讀 Gmail 裡的銀行／信用卡帳單，解密、純規則解析、自訂品類分類，收攏成一本離線的財務帳與儀表板。全本地、零 LLM、零雲端。"
subtitle: "抓信 → 解密 → 解析 → 分類 → 儀表板，一氣呵成"
date: 2026-07-03T10:45:00+08:00
lastmod: 2026-07-03T10:45:00+08:00
draft: false
tags: [ "Claude Code", "AI", "Python", "Side Project" ]
categories: ["造物誌"]

featuredImage: "https://github.com/kylinfish/mailquill/raw/main/assets/images/demo-1.png"
images: ["https://github.com/kylinfish/mailquill/raw/main/assets/images/demo-1.png"]

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
---

記帳大概是最被高估的「好習慣」。它考驗毅力跟自制力，但坦白說一點也不高效——你花在輸入、對帳、分類上的時間，常常比它幫你省的還多。我自己用 Precento 追資產，但每個月的消費明細散在各家銀行的 App 跟信箱裡，想橫向看一眼根本是災難。[Mailquill](https://github.com/kylinfish/mailquill) 就是我把「記帳」從毅力題改成 pipeline 題的嘗試。

<!--more-->

## 緣起：記帳不該靠毅力

好習慣不該靠自制力硬撐，該靠系統。

現在銀行帳單、消費通知大多直接寄到 Gmail。

以前的流程是：一封封把 PDF 下載下來、輸入密碼解開、貼進試算表、再手動分類——每個月固定花你一個晚上。
這種重複、規則明確、又煩的活，正是該讓 Agent 一波帶走的。

還有一個更根本的痛：各家 App 都有自己的「消費分析報告」，但**品類定義各說各話**。國泰的「餐飲」跟台新的「餐飲」不是同一套，跨銀行根本加不起來。

要看到「這個月餐飲到底花多少」，你得自己重新歸類一遍。

## Mailquill 做什麼

一句話：讀 Gmail 裡的銀行／信用卡帳單，解密、解析、分類，收攏成一本離線財務帳 + 儀表板。

![Mailquill 總覽儀表板：KPI 卡與月度趨勢](https://github.com/kylinfish/mailquill/raw/main/assets/images/demo-2.png)

```
Gmail ─(唯讀抓信)─▶ 解密 PDF ─▶ 各家 parser ─▶ 正規化 ─▶ 分類
                                                        │
                                                        ▼
                                              transactions.csv（唯一真實來源）
                                                        │
                                                     rebuild / report
                                                        ▼
                                              report.html（離線儀表板）
```

- **收件匣直接變帳本**：依你 Gmail 已分類的 Label 抓信，自動辨識銀行
- **解密加密 PDF**：用本地 `passwords.txt` 自動試解電子帳單
- **兩層分類、隨你調**：`關鍵字 → (第一層, 第二層)`，改完一鍵重分類
- **離線互動儀表板**：單一 HTML、零外部資源，可依銀行／分類／月份篩選，深色主題、紅綠標示
- 目前支援 國泰、聯邦、台新／Richart、富邦（富邦帳單要手動下載後再 `ingest`）

## 核心設計：CSV 是唯一真實來源

這是我最滿意的一個決定：**抓信，跟分類／出表，解耦。**

抓信是整條流程裡最慢、最耗 API 額度的一步。所以我把它切開：

- `transactions.csv` = 唯一真實來源（single source of truth）
- SQLite 跟 HTML 都只是它的衍生物，隨時可丟、可重建

| 你想做的事 | 指令 | 連 Gmail？ |
|---|---|---|
| 納入新到的帳單 | `run` | ✅ 只有這件事需要 |
| 改了品類規則、重新歸類 | `rebuild` | ❌ 只讀 CSV |
| 換報表視角、重出儀表板 | `report` | ❌ 只讀 DB |

**一次抓信，之後反覆微調都不必重抓。** 對「在本地慢慢調品類」這件事，體驗差超多——你可以一直改 `categories.yaml`、一直 `rebuild`，完全不用再碰信箱。

## 選型：金融資料，刻意零 LLM、零雲端

有趣的地方來了：這工具是我用 coding agent 做出來的，但它跑起來**一行 LLM 都沒有**。

- 每家銀行一支**純規則 parser**，正則對版型。不猜、不呼叫任何模型 → 結果可複現、可稽核。
- 全本地、零雲端，Gmail 只唯讀。你的帳單、金額、卡號從不離開這台電腦。

帳務要的是「每次跑結果都一樣」，不是「大概對」。這種場景，rule-based 就是比 LLM 對。**「用 agent 開發」跟「產品裡用 AI」是兩件事**——這裡我刻意分開。

## Product Taste 收穫

- **把「毅力題」改成「pipeline 題」**：好習慣靠系統，不靠自制力
- **品類正規化才是關鍵 taste**：各家報告各說各話，一套自訂品類（`categories.yaml`）才讓跨銀行的數字加得起來
- **解耦即體驗**：CSV／SQLite／HTML 分層，讓「調分類」跟「重抓信」脫鉤，本地怎麼玩都不怕
- **隱私是預設值不是賣點**：處理金融資料，零雲端是底線
- **還沒做的**：把電子發票紀錄對進消費明細做核對——先放 todo，留給下一版

## 相關連結

- GitHub Repo：<https://github.com/kylinfish/mailquill>
- 設定指南（SETUP）：<https://github.com/kylinfish/mailquill/blob/main/docs/SETUP.md>
- 貢獻指南（新增銀行 parser）：<https://github.com/kylinfish/mailquill/blob/main/CONTRIBUTING.md>
