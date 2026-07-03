---
title: "tw-house-ops 看房 agent"
description: "從 carrer-ops project 來達到產品力聯想，講兩件事：怎麼用 coding agent 把想法快速做出來，以及為什麼 Persona 人設才是這個專案的重點。"
subtitle: "從 tw-house-ops 談 agent 生產力與產品品味"
date: 2026-07-02T14:30:00+08:00
lastmod: 2026-07-02T14:30:00+08:00
draft: false
tags: [ "Claude Code", "AI", "Side Project", "Product" ]
categories: ["造物誌"]

featuredImage: "https://github.com/kylinfish/tw-house-ops/raw/main/demo-images/tracker-demo.png"
images: ["https://github.com/kylinfish/tw-house-ops/raw/main/demo-images/tracker-demo.png"]

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
---

寫得出來已經不是瓶頸了，該做什麼才是。拿這次的 Side Project 產品 [tw-house-ops](https://github.com/kylinfish/tw-house-ops) 當例子，講我這半年的兩個習慣：用 coding agent 把想法快速做出來，用 side project 練判斷。

<!--more-->

## career-ops 的啟發

[career-ops](https://github.com/santifer/career-ops)  推出短短時間獲得盛大回想，快速來聯想是有什麼也有相同特性也值得做。

職缺: 每個標的內容分析的指標超多，內容分析需要深度並極度客製化。需求跟頻次極高。

聯想到的第一想法就是 - 找房，於是 [tw-house-ops](https://github.com/kylinfish/tw-house-ops) 出現了。




以前一個想法會死在「做起來太麻煩」。要爬數個房仲網站、接實價登錄、算通勤、把結果整理成能比較的格式，想到就懶得動。

現在有 Agent 做什麼都快，軟體專業城牆已被拆除，翻轉架構也是彈指之間。


先來借鏡 [career-ops](https://github.com/santifer/career-ops)  作法，把找房拆成一條 pipeline：

```
掃描 → 過濾 → 評估 → 追蹤
```

貼一個 591 或永慶的連結進去，它自動判斷租屋還是買屋，比對行情、算通勤、給五維度評分，寫進一張追蹤表。`scan` 掃目標區的新物件，`pipeline` 批次跑一整批。

Agent 幫我省掉的是打字跟爬蟲，不是判斷。

判斷對，它把對的做完；判斷錯，它會很有效率地把錯的也做完。所以決定成敗的是下一段。

## 重點除了自動化，產品力的關鍵核心 Persona

這專案是看 [career-ops](https://github.com/santifer/career-ops) 的 ops-style 做法學來的。如果只做「自動評估房子」，那就只是又一個爬蟲加評分，沒什麼好講。

我注入了核心精神是這件事： 你的系統要服務什麼人?

以終為始來看: 同一套系統服務三種人。

- **租屋族**：看 CP 值、生活機能、能不能馬上住
- **首購族**：看可負擔房價、貸款壓力
- **換屋族**：看賣舊買新的時程跟資金缺口

同一個連結，三種人設，出三份不一樣的報告。不是換文案——連 **評分權重** 都不同：買屋「價格合理性」占 35%，租屋占 30%；首購有 `affordability` 算可負擔房價，換屋有 `upgrade plan` 排資金時程。

這就是我認為的 taste：**先想清楚「為誰、用什麼視角看」，比「加多少功能」重要**。

有 Persona，它才從「大量瀏覽」變成「精準快篩」——目標不是讓你看更多房子，是幫你少看不該看的。


## 爬蟲選型

**Playwright** — 傳統無頭瀏覽器。寫死 selector，deterministic，又快又穩，丟到背景 worker 跑也沒問題。代價：網站一改版 selector 就爛，六個站 = 六套要顧的 selector，人家改版你就得追。

**agent-browser** — agent friendly 的方案。直接讓 Agent 看渲染完的頁面、用自然語言把欄位撈出來，不寫死 selector。網站改版容錯高，開發快到誇張。缺點也很直白：慢、燒 token、結果不保證每次一樣。

### 怎麼挑? :

- **本地互動版（Claude Code 貼 URL 就跑）** → `agent-browser`。先驗證「這題能不能做」，開發要快，這階段為了穩定去寫死 selector 是本末倒置。
- **要平台化 / 批次大量跑 / 要省成本** → Playwright。deterministic、無頭、不燒 token，穩定來源才值得花力氣固化。

我的順序：先用 agent-browser 把想法跑起來、確定 pipeline 成立，再挑熱門又穩定的來源改寫成 Playwright。先能動，再談穩。


## Product Taste 收穫

- Agent 翻別人的架構是彈指之間
- 注入人設或者 TA 是產品化關鍵
- 掌握資料在下個世代仍然是贏家
  - 嘗試想要把這個模組平台商化，甚至第二個 Platform Name 都想好了 - `HouseGoing` ！！
  - 但重點是，很難收費去爬別人家官網來獲利，很容易侵權或者被告
  - 如果我是房網 RD 看到這功能就馬上先收進去惹
