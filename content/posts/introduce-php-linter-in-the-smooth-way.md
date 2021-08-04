---
title: "優雅導入 PHP CS_Sniffer 至 Legacy 專案"
subtitle: "Introduce PHP Linter into legacy project smoothly"
date: 2021-08-04T15:30:07+08:00
lastmod: 2021-08-04T15:30:07+08:00
draft: false
description: "Linter 如何優雅導入 Legacy 專案而不造成團隊太大的開發負擔"

tags: ["PHP", "linter", "CS_Sniffer"]
categories: ["技術"]
featuredImage: "/img/post/php.jpg"
images: ["/img/post/php.jpg"]
---

導入工具限制常常會有機會聽到反對的聲音，因為害怕工具造成開發效能降低，雖然這是必然的...
<!--more-->
產品的 `品質` 跟 `效率` 本身存在著互斥的關係，既有的開發資源中如何在這兩點之間取捨，一項是開發者每天會面臨的課題。

<BR>

試著提升團隊的開發品質而導入 Linter 當然也不希望就此影響大家在開發上直接遇到困難，希望採用 **漸進式** 的方式協助大家慢慢適應 Coding Style 的重視。
全新的專案可以無痛的直接引入，但是 Legacy 專案其實常常令人頭痛或者不想面對，如何優雅的導入呢?

<BR>

我們選擇使用 [PHP CS_Sniffer](https://marketplace.visualstudio.com/items?itemName=wongjn.php-sniffer)，接下來告訴大家我們如何讓大家技能開始接受 Coding Style 的規範也能在開發中的效率與之取捨。

---

本日主角:
## coverageChecker
https://github.com/exussum12/coverageChecker

簡述其作法:
{{<admonition tip "步驟拆解">}}
1. diff 存成 txt
2. phpcs 跑完 export to JSON format
3. coverageChecker 會用 1 的 diff 去 Parse 2 警告的內容並顯示
{{</admonition>}}

這樣的作法就可以 `只針對每次修正的 Diff 作檢查`，確保今後提交的程式碼都有受其保護跟檢查。

確實落實 Clean Code 中的童子軍原則
{{<admonition info>}}
「離開營地前，讓營地比使用前更加乾淨。」

http://teddy-chen-tw.blogspot.com/2015/07/blog-post_14.html
{{</admonition>}}


## 專案整併

### Require coverageChecker
```shell
composer require squizlabs/php_codesniffer --dev
composer require exussum12/coverage-checker --dev
```

```diff

		},
+	"require-dev": {
+     "squizlabs/php_codesniffer": "*",
+	  	"exussum12/coverage-checker": "^1.0"
+  }
}
```
### 串 Makefile 或者將其整進 CI

```makefile
.PHONY: lint, lint-summary, fix

CS_SNIFF_CONFIG := phpcs.xml

lint:
	@echo "> Check coding style for diff sections only"
	@git diff origin/master > diff.txt
	@./vendor/bin/phpcs --standard=$(CS_SNIFF_CONFIG) --report=json > phpcs.json || true
	@./vendor/bin/diffFilter --phpcs diff.txt phpcs.json 100

lint-summary:
	@./vendor/bin/phpcs --standard=$(CS_SNIFF_CONFIG) --report=summary

fix:
	@phpcbf --standard=$(CS_SNIFF_CONFIG)

```

{{< admonition summary 文章系列>}}
1. [PHP Linter 和 Formater 選擇](/php-linter-formater/)
2. [解密 PHP_CodeSniffer Configuration File](/reveal-php-cs-sniffer-config/)
3. _優雅導入 PHP CS_Sniffer 至 Legacy 專案_
{{< /admonition>}}