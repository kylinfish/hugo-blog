+++
draft = false
description = "替 Vim 設定適合 Python 開發的環境以及套件，讓開發速度得以加快"
tags = [ "vim" ]
categories = [ "技術" ]
date = "2019-03-23T00:22:03+08:00"
title = "Vim for Python Development"
relative_banner="/post/pyvim-bg.jpg"
+++

最近在寫 Python，已經習慣用 Vim 的我，當然先找看看 Python 相關的套件跟設定怎麼做開發起來比較方便，
於是 整理近期有套用的設定與大家分享，如果有更好的作法也歡迎分享給我
<!--more-->

## 給 Py 用的套件 - Python Vim Plug
- [`heavenshell/vim-pydocstring`](https://github.com/heavenshell/vim-pydocstring)
    - 自動產生 pydocstring ，個人習慣套用 *Ctrl + x* 來自動產生
- [`davidhalter/jedi-vim`](https://github.com/davidhalter/jedi-vim)
    - 大家都推的 Python 用的自動補全，但這套我用起來不順所以後來用下面那套，大家還是可以嘗試看看
- [`maralla/completor.vim`](https://github.com/maralla/completor.vim)
    - 自動補全後來改用這套
- [`tell-k/vim-autopep8`](https://github.com/tell-k/vim-autopep8)
    - Python 介通用 Codging Style - [PEP8](https://www.python.org/dev/peps/pep-0008/) style
    - 先用 pip install autopep8，再裝這套
    - 套用 <F8> 來手動啟用，同時做些基礎設定，詳見 .vimrc
    - 如果想要用 = 來套用 PEP8 的格式，可以加入這行 *autocmd FileType python set equalprg=autopep8\*
- [`vim-scripts/indentpython.vim`](https://github.com/vim-scripts/indentpython.vim)
    - 如果沒規定要用 PEP8 Style，卻又想要使用 = 正常的自動縮排可以使用這套來做縮排修正

## 執行與編寫 - Run Python in Vim
1. 無腦的作法寫完存檔離開 Vim 用 Shell 執行
2. `:` 進入指令模式輸入 `!clear; python %`
3. 設定\<F4\> 快捷鍵，這裡提供一個 Python/Java 版本，也可自行添加 C 的版本。
    - 以下這段加入 .vimrc

```
" 快速編譯
map <F4> : call CompileRun()<CR>
func! CompileRun()
    exec "w"
    if &filetype =='python'
        exec "!time python2.7 %"
    elseif &filetype =='java'
        exec "!javac %"
        exec "!time ./&<"
    endif
endfunc
```

### 印出有顏色的字 - Python print in terminal with colors
承上，若在 Vim 中執行 Py 多次的話， Python 的 Console Print 的視覺化效果很差，混在一起也不容易看。 於是我刻了一個簡單土炮的方式。

在你編輯的 Python Script 最上面自行加入以下這段程式碼，讓你每次編譯都有機會印出不一樣的顏色，同時也方便觀察執行差異。
_⚠️   對了，不要加入 Git Tracking 喔 😅_

<script src="https://gist.github.com/kylinfish/a43b730f43a780c64a29357ef6c41269.js"></script>

{{< lazy-img src="/img/post/py_print_with_color.png" title="Python print with colors" >}}



### <span class="text-success">__延伸閱讀__</span>

- [Terminal 底下的開發環境 vim 的設定 tmux zsh fzf 套件整合](/unix-like-develop-env/)
