---
title: "PHP Linter 和 Formater 選擇"
subtitle: "剖析 PHP Coding Style 整合工具"
date: 2021-08-01T18:25:39+08:00
lastmod: 2021-08-01T18:25:39+08:00
draft: false
description: "剖析常見的 PHP Linter 和 Foramter 工具，協助選擇適應自己及團隊的開發工具。"

tags: ["PHP", "linter", "CS_Sniffer"]
categories: ["技術"]

featuredImage: "/img/post/php.jpg"
images: ["/img/post/php.jpg"]
---

兩個脈絡看待 PHP Coding Style 整合工具，我們可以從 **Formater 自動修正** 以及 **Linter 檢查工具** 來看
<!--more-->

## PHP Formater
Formater 主要協助開發者再提交 Commit 前可以快速修正錯誤。

查詢 [Visual Code](https://code.visualstudio.com/) 上面提供的 Extension
- [php-fmt](https://marketplace.visualstudio.com/items?itemName=kokororin.vscode-phpfmt)
- [php-cs-fixer](https://marketplace.visualstudio.com/items?itemName=junstyle.php-cs-fixer)
- [php-sniffer](https://marketplace.visualstudio.com/items?itemName=wongjn.php-sniffer)

以及 [phpinsights](https://phpinsights.com/)

上述工具可以根據大家自己的開發習慣選擇喜歡的工具使用。

## PHP Linter
以[持續整合(CI)](https://zh.wikipedia.org/wiki/%E6%8C%81%E7%BA%8C%E6%95%B4%E5%90%88) 整合為主要考量，主要檢查提交者的程式是否有符合團隊規範。只有整合進自動化作業才能確保開發風格的一致性。
- [CS Sniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- [phpinsights](https://phpinsights.com/)

----

## 個別看法
以下簡單提供自己對下列工具的看法:
### phpfmt - PHP formatter
- 工具停止維護了，可能不考慮

### php-cs-fixer
- 純粹是 Formater 幫忙修正格式，但不方便整合到 CI 工具中
- config file 可以客製化

### PHP CS Sniffer
- 兼具 Linter 跟 Formater 的功能，但其實是兩個工具，分別是 phpcs 跟 phpcbf
- CI 上可以用 phpcs，local (dev) 可以透過 phpcbf 
- config 可以客製化，但使用 XML 較不友善 (個人主觀)


### PHP Insights
- Laravel 友善
- 可以使用 Docker
- 結合 Linter、formater 以及 Analyzer
- 可搭配 CI
- config 用 PHP 表示比較友善
- 適合人類閱讀的格式

> Analyzer 類似的工具可以參考 [PHPMetrics](https://phpmetrics.org/)


## 結語
PHP Formater 以及 Linter 的選擇
{{<admonition question "PHP Formater 的選擇?">}}
- PHP Formater 的選擇可以根據自己的開發習慣或喜好選擇方案，但如果有要搭配 Linter 建議可以找有機會一致化 Config 的方案。
- 實務上不可能完全修正到乾淨沒有錯誤跟警告
{{</admonition>}}

{{<admonition question "PHP Linter 的選擇?">}}
- Linter 整合進 [CI](https://zh.wikipedia.org/wiki/%E6%8C%81%E7%BA%8C%E6%95%B4%E5%90%88) 的好處是確保團隊成員開發能夠確實遵守規範，
同時 Reviewer 可以不用人肉檢查 Style 只需要專注於商業邏輯以及程式設計寫法。
- Config Rule 規範建議從大範圍往細部制定 **(粒度由粗至細)**，根據團隊習慣規則慢慢演進，以及各個專案可以個別定義
{{</admonition>}}

{{< admonition summary 文章系列>}}
1. _PHP Linter 和 Formater 選擇_
2. [解密 PHP_CodeSniffer Configuration File](/reveal-php-cs-sniffer-config/)
3. [優雅導入 PHP CS_Sniffer 至 Legacy 專案](/introduce-php-linter-in-the-smooth-way/)
{{< /admonition>}}