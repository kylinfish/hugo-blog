---
title: "NeonFlux — 把瀏覽歷史變成工作流的新分頁"
description: "新分頁是塊死掉的空間，瀏覽歷史是個沒人回頭翻的墳場。NeonFlux 把這兩塊縫起來：打開新分頁，就看到照你工作流自動分類好的瀏覽記錄。privacy-first、純本機。"
subtitle: "造物誌的起點——一個上架 Chrome Web Store 的 side project"
date: 2026-03-05T10:00:00+08:00
lastmod: 2026-03-05T10:00:00+08:00
draft: false
tags: [ "Chrome Extension", "AI", "Side Project", "Product" ]
categories: ["造物誌"]

featuredImage: "https://neonflux-web.web.app/screenshots/auto-categorized.png"
images: ["https://neonflux-web.web.app/screenshots/auto-categorized.png"]

toc:
  enable: true
  auto: true
code:
  copy: true
  maxShownLines: 50
---

每天開幾十個新分頁，預設畫面不是搜尋框就是一排捷徑，基本上是塊死掉的空間。
瀏覽歷史更慘——是個你幾乎不會回頭翻的墳場。[NeonFlux](https://chromewebstore.google.com/detail/neonflux/npmcfbnpmpiphenjnmlcgacbmdgcpacb) 想做的就是把這兩塊被浪費的地方縫起來，讓新分頁變成一個 `「照你工作流分類好的瀏覽歷史」`。

<!--more-->

 [Chrome Web Store](https://chromewebstore.google.com/detail/neonflux/npmcfbnpmpiphenjnmlcgacbmdgcpacb) 的第一個 Chrome Extension App

## 緣起：新分頁不該是塊死掉的空間

一天開幾十個分頁，工作脈絡其實都在瀏覽歷史裡 —— 早上在 Figma、中午在 GitLab、下午在 ClickUp。但這些紀錄躺在一個你永遠不會打開的地方。

我要的很簡單：打開新分頁，直接看到「我最近在哪些工具上做了什麼」，而且自動分好類。不是一排冷冰冰的捷徑，是我當下的工作流。

或者我在 Google Workspace 底下要找一堆會議文件，知道好像放在那邊，但就是叫不出來，或者要進去歷史紀錄海搜...

## NeonFlux 做什麼

一句話：自訂分類的瀏覽歷史，長在你的新分頁上。

![NeonFlux 自動把瀏覽記錄分類到各工具](https://neonflux-web.web.app/screenshots/auto-categorized.png)

- **自動分類**：內建 Google Workspace / AWS / GitLab / Figma / Jira / Linear / Asana… 也能自訂，支援 `domain` / `prefix` / `regex` 三種 matcher
- **聚焦檢視**：點一個分類看它的完整列表，全屏專注
- **隱私門簾**：開會或投影時一鍵蓋掉敏感紀錄，可鎖定，下次載入自動啟用
- **快速連結**：自動抓 favicon、可拖拽排序、釘選常用
- **智慧排序 + 即時搜尋 + 時間篩選**，中英雙語

## Product Taste 收穫

- **最好的點子常來自「重看一個大家都忽略的畫面」**：新分頁天天開，卻沒人把它當一回事。剛好 Apple 剛發佈 Liquid Glass ，成為我的 Prompt Styling  
- **隱私是一種設計立場**：選擇「不收集」，比事後再談「怎麼保護」乾脆太多
- **細膩的使用情境**：從日常工作中觀察，找到 Feature 強化的關鍵功能 - 隱私門簾
- **這是起點**：一個 extension 直接體現「發現痛點 → 做出來 → 上架」完整跑一輪

## 相關連結

- 介紹網站：<https://neonflux-web.web.app/>
- Chrome Web Store：<https://chromewebstore.google.com/detail/neonflux/npmcfbnpmpiphenjnmlcgacbmdgcpacb>
- 更新紀錄（Release Logs）：<https://neonflux-web.web.app/release.html>
- 隱私政策：<https://neonflux-web.web.app/privacy.html>
