---
title: "在 Terminal 環境下的開發配置"
description: "Terminal 底下的開發環境 vim 的設定 tmux zsh fzf 套件整合"
date: "2017-07-21T11:15:50+08:00"
draft: false
tags: [ "vim", "zsh", "bash", "tmux" ]
categories: ["技術"]

featuredImage: "/img/post/workenv.jpg"
images: ["/img/post/workenv.jpg"]

---

在 Teminal 底下開發時間約三年，環境的工具以及整合修改隨著時間與見識也不斷進化。
這篇是紀錄自己在工作操作方式流程與配置，或許不是最好的工作流，但與大家分享，也樂見給予回饋

<!--more-->

ref.  [🔗  GitHub 上的設定檔](https://github.com/kylinfish/dotvim/blob/master/README.md)

## Terminal 環境下開發所需要的工具

1. shell: 選定一個你喜歡的 shell 進行設定，我目前選用 [zsh](http://ohmyz.sh/)
2. [tmux](https://github.com/tmux/tmux): 在 terminal 工作為了加速流程跟操作，使用 tmux 可以建立多個窗並且可以隱藏在背景 cache 你的開發過程，或者你也可以選用 screen
3. [vim](https://github.com/vim/vim): 選用 vim 搭配套件配置自己的使用習慣
4. [tig](https://github.com/jonas/tig): 利用 tig 就可以不用 GUI 看 Git 的提交紀錄，可以全程 Focus 在 terminal 裡面工作
5. [fzf](https://github.com/junegunn/fzf): 模糊查找工具，支援在 vim 裡面使用也可以在 unix 下使用
6. [ack](https://beyondgrep.com/documentation/): unix 指令，我用它取代 __grep__，原因是字母少好記速度又略勝 __grep__


## Vim 的配置與使用習慣
vim 的個人配置與使用習慣都大相徑庭，這邊點出對於工作流有影響的部分，其餘可以參考我的 [GitHub .vimrc](https://github.com/kylinfish/dotvim/blob/master/.vimrc)

### Nerdtree 與 tagbar
* `scrooloose/nerdtree`
 * 有時候還是想要查看目錄底下的檔案方便進一步搜尋，並且可以在不離開 vim 做檔案的 __新增/重新命名/複製/刪除__ 等動作

* `majutsushi/tagbar`
 * 總覽專案規模以及變數查找的時候會使用

{{< figure src="/img/post/nerdtree_with_tagbar.jpg" title="Nerdtree with tagbar image" >}}

### fzf vs CtrlP
模糊搜尋的功能在其他類似的 IDE 也有提供，在 vim 裡面廣為人知的的套件就是 `CtrlP`，但是裝了 `fzf` 之後，速度快過 CtrlP 許多，除了在 vim 裡面使用之外，還可以在 unix 環境底下做檔案或者歷史紀錄的查詢，兼具 __自動補全__ 及 __模糊查詢__ 的功能

{{< figure src="/img/post/fzf.jpg" title="fzf demo image" >}}

## tig
查看 GIT 版本控制的工具，可撰寫 `.tigrc` 調整自己喜歡的樣式，在 terminal 底下使用 tig 指令就可以不用開 git sourcetree

{{< figure src="/img/post/tig.jpg" title="tig tool demo" >}}


## 顏色及主題的配置
開發工具順眼與否，決定我們想不想用，甚至影響開發效率。
以下知名的套件中很多都有提供主題的設定即客製化，列出我使用到的套件以及設定

* zsh powerline theme: [bhilburn/powerlevel9k](https://github.com/bhilburn/powerlevel9k)
    * zsh 提供比 bash 更多的主題設定
* vim colortheme: [winyu.vim](https://github.com/kylinfish/dotvim/blob/master/colors/winyu.vim)
    * 這套我是改自 _raphamorim/lucario_ ，專 For `PHP` 開發者使用的
* vim setting: [.vimrc](https://github.com/kylinfish/dotvim/blob/master/.vimrc)
    * 其中包含 airline 狀態列，以及 nerdtree 的 icon 美化等等
* tmux: [.tmux.conf.local](https://github.com/kylinfish/dotvim/blob/master/.tmux.conf.local), from: [gpakosz](https://github.com/gpakosz/.tmux#enabling-the-powerline-look)
    * gpakosz 的設定實在太炫砲了，還可以把電池狀態放上來
* itermcolos: [winyu.itermcolors](https://github.com/kylinfish/dotvim/blob/master/winyu.itermcolors)
    * 使用 iTerm2 很多地方的預設顏色都會根據 iTerm2 走

{{< figure src="/img/post/winyu_theme.jpg" title="winyu.vim 在 `PHP` 中的顏色主題" >}}

#### 參考資料
* [🔗  GitHub 上的設定檔](https://github.com/kylinfish/dotvim/blob/master/README.md)
