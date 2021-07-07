---
title: "PHP7.1 Feature/Incompatible 升級注意事項"
description: "紀錄 PHP 7.1 新的 Feature，以及不相容的項目"
date: "2018-06-19T09:44:58+08:00"
draft: false
tags: [ "PHP" ]
categories: ["技術"]

featuredImage: "/img/post/php71.jpg"
images: ["/img/post/php71.jpg"]

---

PHP 從 7 的問世後，後續更新速度很快， 讀了一下 7.0 到 7.1 [PHP 官方升級文件](http://php.net/manual/en/migration71.new-features.php) 做個筆記， 這邊列出對於開發常見項目的 Feature 做簡述:

## Features
### Symmetric array destructuring
- 用一個 foreach  支援印出二維陣列
- 可以用 `list` 以及 shorthand `[]` 兩種表示法

{{< highlight php >}}
<?php
$data = [
    [1, 'Tom'],
    [2, 'Fred'],
];

// list() style
list($id1, $name1) = $data[0];

// [] style
[$id1, $name1] = $data[0];

// list() style
foreach ($data as list($id, $name)) {
    // logic here with $id and $name
}

// [] style
foreach ($data as [$id, $name]) {
    // logic here with $id and $name
}
{{< /highlight >}}


### Class constant visibility
- Class 內的 constant 可以決定 Visibility

{{< highlight php >}}
<?php
class ConstDemo
{
    const PUBLIC_CONST_A = 1;
    public const PUBLIC_CONST_B = 2;
    protected const PROTECTED_CONST = 3;
    private const PRIVATE_CONST = 4;
}

// public / protected / private
{{< /highlight >}}


### Multi catch exception handling
- 支援在同一個 catch 內捕捉多組 Exception type

{{< highlight php>}}
<?php
try {
    // some code
} catch (FirstException | SecondException $e) {
    // handle first and second exceptions
}
{{< /highlight >}}


### Support for keys in list()
- 可以在 array 的表示式內如 `list()` 或 `shorthand []` 指定 key 來賦值

{{< highlight php>}}
<?php
$data = [
    ["id" => 1, "name" => 'Tom'],
    ["id" => 2, "name" => 'Fred'],
];

// list() style
list("id" => $id1, "name" => $name1) = $data[0];

// [] style
["id" => $id1, "name" => $name1] = $data[0];

// list() style
foreach ($data as list("id" => $id, "name" => $name)) {
    // logic here with $id and $name
}

// [] style
foreach ($data as ["id" => $id, "name" => $name]) {
    // logic here with $id and $name
}
{{< /highlight >}}


### Support for negative string offsets
- String 的 index offset 支援負數


{{< highlight php>}}
<?php
var_dump("abcdef"[-2]);
var_dump(strpos("aabbcc", "b", -3));
{{< /highlight >}}
{{< highlight shell>}}
string (1) "e"
int(3)
{{< /highlight >}}

<hr>

## Backward incompatible changes

### Throw on passing too few function arguments
- 以前如果沒有傳入對應的參數會噴出 Warning 做提示，7.1 升級成更嚴謹的 Error exception.

{{< highlight php>}}
<?php
function test($param){}
test();
{{< /highlight >}}

{{< admonition danger>}}
Fatal error: Uncaught ArgumentCountError: Too few arguments to function test(), 0 passed in %s on line %d and exactly 1 expected in %s:%d
{{< /admonition >}}

### `error_log` changes with syslog value
### The empty index operator is not supported for strings anymore
- If the error_log ini setting is set to syslog, the PHP error levels are mapped to the syslog error levels


### The empty index operator is not supported for strings anymore
- 替 string 設置空的 index operator (e.g. $str[] = $x) 現在將會噴 fatal error


{{< highlight php>}}
<?php

$foo = '';

$foo[] = 'bar';
{{< /highlight >}}
{{< highlight shell>}}
PHP Fatal error: Uncaught Error: [] operator not supported for strings
{{< /highlight >}}

7.0 到 7.1 的異動實在是有點多，還是看官網吧 ╮(╯◇╰)╭
