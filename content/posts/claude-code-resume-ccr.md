---
title: "claude-code-resume — 跨專案續接你的 Claude Code 對話"
description: "用 Claude Code 養一堆 side project，對話散在各專案資料夾裡根本找不到。ccr 就是為這個痛點做的：一個指令，跨專案 fuzzy search 所有 session，選一個直接 resume。"
subtitle: "一個 CLI 玩家寫的 Claude Code session 續接器——鍵盤一路到底，不離開終端機"
date: 2026-07-03T09:40:00+08:00
lastmod: 2026-07-03T09:40:00+08:00
draft: false
tags: [ "Claude Code", "AI", "CLI", "Side Project" ]
categories: ["造物誌"]

featuredImage: "https://repository-images.githubusercontent.com/1277600433/68c51f66-2002-4547-9516-3fb973f4a226"
images: ["https://repository-images.githubusercontent.com/1277600433/68c51f66-2002-4547-9516-3fb973f4a226"]

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
---

用 Claude Code 同時養好幾個 side project，很快就會撞到一個問題：對話散在每個專案的資料夾裡，你根本記不得上次那段在哪。[claude-code-resume](https://github.com/kylinfish/claude-code-resume)（`ccr`）就是為這個痛點做的——一個指令，跨專案 fuzzy search 所有 Claude Code 對話，選一個直接 resume。

我是在終端機裡過日子的人——`vim` + `tmux` + `fzf` 那一派，多年前就把[終端機下的開發配置](/unix-like-develop-env/)整理成一篇。這麼多年過去，那套工具鏈的品味沒變：一個指令、鍵盤一路到底、不用碰滑鼠、不用切到另一個視窗、丟到 `PATH` 就能用。ccr 就是照這個老標準，做給現在的 Claude Code 工作流。

<!--more-->

## 緣起：對話都跑去哪了

Claude Code 每個 session 是一個 `.jsonl`，藏在 `~/.claude/projects/<專案>/` 底下。

專案一多就崩潰：想 resume 昨天那段對話，得先想它在哪個資料夾、`cd` 進去、再 `claude --resume` 從一堆 id 裡挑。煩。

對 CLI 玩家來說，最痛的是**被迫離開流程**——手從鍵盤移開、去別的地方翻、腦袋斷線。

我要的很簡單：在原地、用鍵盤，一個地方看到「所有專案、所有對話」，選一個就接上。

這麼小的需求，以前懶得寫；現在有 Agent，這個想法在我開會進會議室前給完，會議後測試驗收。收工！！

## ccr 做什麼

跨專案的 Claude Code session picker。

![ccr 實際操作：fuzzy search、預覽、一鍵 resume](https://github.com/kylinfish/claude-code-resume/raw/main/assets/demo.gif)

- 掃 `~/.claude/projects/*/*.jsonl` 全部 session，不分專案
- fzf 選單 + 預覽：AI 標題、時間、工作目錄、最後一句 prompt
- `Enter`：自動 `cd` 到專案目錄 + `claude --resume`
- `Ctrl-R`：加 `--remote-control`，用手機／網頁接手
- `ccr --last` / `ccr -n N`：不開選單，直接續最近那個


```

---- 我是demo----
 just now │ Add JWT auth to the API gateway      │ ~/code/acme-api
   2m ago │ Fix flaky checkout integration test  │ ~/code/storefront
   1d ago │ Refactor the payment webhook handler │ ~/code/payments-svc
┌──────────────────────────────────────────────────────────┐
│ 📌 Add JWT auth to the API gateway                       │
│ 🕒 2026-06-20 14:08  (just now)                          │
│ 📁 /Users/you/code/acme-api                              │
│ 💬 last prompt: extract the token check into middleware  │
└──────────────────────────────────────────────────────────┘
```


## 選型：能少就少

這是個人工具，我給自己的原則是**克制**——能不寫的就不寫。

- **單一 Bash script**: 最無縫整合、無 daemon、無狀態檔，丟到 `PATH` 就能用，`ssh` 進遠端機器一樣跑。
- **UI 套用 [`fzf`](https://github.com/junegunn/fzf) 風格。** fzf 是 CLI 玩家的共同語言——模糊搜尋、鍵盤選單、預覽窗，肌肉記憶全都在。我只負責把資料排好餵進去，自己刻 TUI 是浪費生命。
- **可組合。** `ccr .` 只看當前目錄、`ccr <path>` 看指定目錄、`ccr --last` 直接續——吃參數、可管線，跟其他 CLI 工具一樣的脾氣。
- **`python3` 只做 Bash 做不好的那一小塊**：`.jsonl` 解析、全形字寬計算。其他都 Bash。
- **快取靠檔案 mtime。** 建一次索引，沒變動的 session 不重複解析。上百個 session 開起來還是秒開——CLI 工具慢半秒都嫌久。


## Product Taste 收穫

- 生活周邊的小痛點，過往繁瑣，現在 Agent 解決都是順勢而為。做起來就產生 Output
- **工具的 taste 藏在你以為沒人會注意的細節**
  - 可依照不同資料型態做排序
  - 時間依新舊上色，一眼看到哪段是剛剛的
  - 一鍵 resume，不要逼使用者記 session id ，盡可能極簡化使用方式
- **CLI 玩家的 taste 是「不打斷心流」**：留在終端機、鍵盤到底、秒開秒關。工具越隱形越好，你不該感覺到它存在
- **克制本身就是一種 taste**：能靠 fzf 的就別自己刻，能不加的設定就不要加
- **meta 小樂趣**：這是一個「用 Claude Code 做的、拿來管 Claude Code 對話」的工具。我的造物誌(Side Project)越寫越多，session 越多，這工具就越用得到——剛好自己養自己
