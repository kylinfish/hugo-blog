+++
description = "如何導入 Python Linter Tool，使用 Prospector 多合一整合工具守護你的程式碼品質"
tags = [ "python", "linter" ]
categories = [ "技術" ]
date = "2019-06-04T10:23:15+08:00"
title = "導入 Python Linter - 使用 Prospector"
relative_banner="/post/python.jpg"
og_images = ["/img/post/python.jpg"]
+++

開發自動化工具時，發現沒有 Linter 保護程式碼。提到[持續整合 CI](https://zh.wikipedia.org/wiki/%E6%8C%81%E7%BA%8C%E6%95%B4%E5%90%88) ，
除了自動化、單元測試以外，靜態語言分析工具檢查也是重要環節，本篇將介紹如何整合 Python 的程式碼靜態分析工具。
<!--more--> 

<br>

## 靜態分析工具評估/分析/導入
### 1. 如何挑選 Python 靜態分析工具
Python 的程式碼靜態分析工具多元，開始導入的時候會發現種類繁多不知道如何下手，主要可以分成以下兩種類別

#### Logical Lint 邏輯型
檢查程式碼錯誤，是否有機會產生意外結果，或者是危險的模式(Dangerous Code Patterns)... 等等。

在 Python 社群中較為熱門的 Linter 有 `Pylint、PyFlakes、pycodestyle、pydocstring、MyPy`

#### Stylistic Lint 風格型
就是團隊規範所謂 Code Style ，自行定義團隊準則讓工具檢查命名方式、註解撰寫、括號、空白細節等等

> *補充: 可以參考我先前整理的 [無瑕的程式碼 Clean Code](https://www.slideshare.net/kylinfish/clean-code-72688451) 準則*

另外常見的 Style 檢查或者自動修正工具如下: `Mccabe、Radon、Black`

上述簡單介紹後，詳細特色比較可以參考 [realpython](https://realpython.com/python-code-quality/#how-to-improve-python-code-quality)
有完善的介紹。

### 2. 設定 Linter，制定團隊規範
理解分析工具的特色後，接著你會需要知道如何設定 lintrc (config file) 同時來符合團隊需求，以下提供我在導入的時候有挑選到的工具。

{{< alert "alert-warning" >}}
*看到這裡先不用急著設定你的 lintrc，在下節會介紹工具整合，可以省去各別設定的麻煩喔!。*
{{< /alert >}}

#### [pylint](https://www.pylint.org/)
在眾多 linter 中就屬它最為常見，提供足夠的彈性客製化。這裡我們主要需要 pylint 的:

- Style Check
- Error Detection
- 生成基礎 pylintrc 檔案
{{< highlight shell>}}
pylint --generate-rcfile > .pylintrc
{{< / highlight >}}
- [規則設定參照 - pylint features](http://pylint.pycqa.org/en/latest/technical_reference/features.html)

#### pycodestyle
- PEP8 Naming Conventions
    - 命名規範 Function、Variable、Class、Method、Module、Package、Constant
- PEP8 Code Layout
    - 換行規範、縮排檢查、Maximum Line Length(最大寬度)
- docString
    - 註解規範
- [規則參照 - PEP8 Naming Convention Cheat Sheet](https://realpython.com/python-pep8/#naming-styles)
- [規則設定參照 - pycodestyle Error Code](https://pep8.readthedocs.io/en/latest/intro.html#error-codes)

#### pyflakes
可以看成他整合了 [flake8](https://pypi.org/project/flake8/) 標準及 PEP8 標準，又 flake8 整合以下:

- PyFlakes
- pycodestyle
- [McCabe script](https://github.com/PyCQA/mccabe) (計算循環複雜度CC)


### 3. 整合導入，使用 Prospector - Python Static Analysis
正題來了，當要整合進入 CI 工具中時，工具的多樣性在此時反而造成困擾，因為你可能要安裝各種不同的檢查工具，各自產生不同的 lintrc 做對應的指定等等。
介紹 [Prospector](https://prospector.landscape.io/en/master/index.html) 這套整合性工具:

在本文第二節提到的工具 Prospector 都有了，同時還有其他支援的整合，可以參考 [Supported Tool](https://prospector.landscape.io/en/master/supported_tools.html)

- Defaults(預設會檢查的項目)
    - Pylint、pyflakes、mccabe、dodgy、pydocstyle
- Optional(可以自行額外掛入)
    - Pyroma、Vulture、frosted、mypy

#### prospector.yaml
第二節提到的相關 lintrc 在 prospector 中統一透過 yaml 設定其實就可以了。當然所有工具的 configuration 也能個別定義，下一節會補充

- prospector.yaml 範例:
{{< highlight yaml >}}
output-format: json

strictness: medium
test-warnings: true
doc-warnings: false
max-line-length: 125 # refer to https://stackoverflow.com/questions/22207920/)

inherits:
  - my/other/profile.yml

ignore-paths:
  - docs

ignore-patterns:
  - (^|/)skip(this)?(/|$)

pep8:
  disable:
    - W602
    - W603
  enable:
    - W601

mccabe:
  run: false
{{</ highlight >}}

    - Strictness
        - Strictness 是根據 Profile 檔案做不同級別的檢查，可以參考[內建的 Profile 設定細節](https://github.com/PyCQA/prospector/tree/master/prospector/profiles/profiles)
    - inherits
        - Profile 本身允許繼承不同的 Profile
    - max-line-length
        - 特別一提，在 PEP8 中規定的是 79 個字，但其實現在的螢幕相較以往都較寬，有些團隊會放寬這條限制
        - 上述範例參考 GitHub 的 file 顯示做參照調整為 125 > [Stack Overflow 討論參考](https://stackoverflow.com/questions/22207920/)

{{< alert "alert-success" >}}
直接開始深入 Prospector 的 prospector.yaml 設定，若有缺的再回去第二節找，參考網址如下
https://prospector.landscape.io/en/master/profiles.html#example
{{</ alert >}}

## 導入細節補充

### pylintrc 整合
如果已經有 pylintrc 想做整合，Prospector 會根據 pylint 讀取 pylintrc 的邏輯尋找可以套用的 pylintrc

1. Project root path 
2. Your home path

{{< lazy-img src="/img/post/prospector_results.png" title="Prospector Demo Result" >}}
跑完結果直接告訴你，`現在用什麼 profile、用什麼 Tool、用哪裡的 pylintrc`。
是不是覺得整合的很好呢?

### 平穩導入小技巧
如果是現有專案尚未有 Lint 的，當你導入任何一套檢查規範時不免會讓專案陷入動彈不得的情況，一定會有很多目前的檔案不符合規範，這時候可以考慮採用白名單方式...

- 建立驗證白名單 e.g. prospector_file_list.txt 
{{< highlight shell>}}
foo.py
bar.py
{{< / highlight >}}

- 只驗證名單內的 python file 即可
{{< highlight shell>}}
prospector `cat prospector_file_list.txt | sed "s/\n/ /g"` --profile prospector.yaml
{{< / highlight >}}

### 整合 pre-commit
Prospector 也允許利用 [pre-commit](https://pre-commit.com/) 做整合喔

## 延伸閱讀
關心更多與 Python Quality 的主題，也可以來這裡 [PyCQA (Python Code Quality Authority)](http://meta.pycqa.org/en/latest/introduction.html)，
也建議瀏覽 PyCQA [GitHub https://github.com/PyCQA](https://github.com/PyCQA) 上的 Repository

##### Development FQA
1. [Why does pylint object to single character variable names?](https://stackoverflow.com/questions/21833872/why-does-pylint-object-to-single-character-variable-names)
2. [Pylint showing invalid variable names which are vocabularies in output ](https://stackoverflow.com/questions/10815549/pylint-showing-invalid-variable-name-in-output)

