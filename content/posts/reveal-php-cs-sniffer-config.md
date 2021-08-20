---
title: "解密 PHP_CodeSniffer Configuration File"
subtitle: "如何設定 PHP_CodeSniffer config file .phpcs.xml, phpcs.xml, .phpcs.xml.dist, phpcs.xml.dist"
date: 2021-08-04T13:57:03+08:00
lastmod: 2021-08-04T13:57:03+08:00
draft: false
description: "解密 PHP CodeSniffer 的 XML configuration file，針對自己團隊專案作客製化"
tags: ["PHP", "Linter", "CS_Sniffer"]
categories: ["技術"]
featuredImage: "/img/post/php.jpg"
images: ["/img/post/php.jpg"]
---
上一篇做了 [PHP Linter 工具的分析](php-linter-formater/)之後，選定 PHP_CodeSniffer 來做團隊的工具導入，但是制定專案的設定檔需要了解其細節。
本文會帶介紹如何自己定義 [PHP_CodeSniffer config file](https://github.com/squizlabs/PHP_CodeSniffer/wiki/Advanced-Usage#using-a-default-configuration-file) 來適應團隊的開發文化跟規範。
<!--more-->


## 0. PHP_CodeSniffer Terminology
開始之前先定義一下專業術語，方便接下來的內容溝通
*   **Standard**: 社群規範標準: e.g. PSR, Zend, Perl, ... etc 參考 [Standards 清單](https://github.com/squizlabs/PHP_CodeSniffer/tree/master/src/Standards)
*   **Sniff**: Standard 內的條規

## 1. 決定規範(Standard)
參考這邊目前有整合的項目，推薦使用
*   [Generic](https://github.com/squizlabs/PHP_CodeSniffer/tree/master/src/Standards/Generic)
*   [PSR2](https://github.com/squizlabs/PHP_CodeSniffer/tree/master/src/Standards/PSR2) (老舊專案建議優先套這個就好)
*   [PSR12](https://github.com/squizlabs/PHP_CodeSniffer/tree/master/src/Standards/PSR12) (新專案就直接上這段)

> PSR2 跟 PSR12 一個專案擇一即可

  

## 2. 微調條規(Sniff)
老舊專案比較會有狀況是，無法完全符合 PSR2 (Baseline)，使用上會有些規範需要做排除，所以會需要做微調。

Standard 選定後，接著調整 Standard 內的 Sniff，如何對照?

  
### 使用 phpcs check 時會看到 Errors or Warnings
對照顯示內容找出在 CS Sniffer 中的設定方法是:

搭配 -e 的 argument 顯示
`phpcs --standard=psr1 -e`

```SHELL
 11:27:20  ~/work/nimda-v2   winyu/linter ● ? ⍟1  phpcs --standard=psr1 -e

The PSR1 standard contains 8 sniffs

Generic (4 sniffs)
------------------
  Generic.Files.ByteOrderMark
  Generic.NamingConventions.UpperCaseConstantName
  Generic.PHP.DisallowAlternativePHPTags
  Generic.PHP.DisallowShortOpenTag

PSR1 (3 sniffs)
---------------
  PSR1.Classes.ClassDeclaration
  PSR1.Files.SideEffects
  PSR1.Methods.CamelCapsMethodName

Squiz (1 sniff)
----------------
  Squiz.Classes.ValidClassName
```

接著把 Sniff 挑出來決定要不要做排除，如果需要的話在 XML 的 Rule Tag section 中加入 `exclude` 來做排除。詳見下段

## 3. 如何撰寫及解讀 phpcs.xml 格式
格式可以參考該網站
[https://pear.php.net/manual/en/package.php.php-codesniffer.annotated-ruleset.php](https://pear.php.net/manual/en/package.php.php-codesniffer.annotated-ruleset.php)

以下針對幾個特定的 Section 作解釋

#### 掃描檔案範圍設定

```xml
<!-- Scan Folder Settings -->
<file>application</file>

<exclude-pattern>*/application/libraries/*\.(inc|css|js|php)$</exclude-pattern>
<exclude-pattern>*/application/third_party/*/*\.(inc|css|js|php)$</exclude-pattern>
<exclude-pattern>*/application/modules/*/*\.(inc|css|js|php)$</exclude-pattern>
```
*   file: 要掃描的路徑
*   exclude-pattern: 排除路徑

#### 基礎一般設定

```xml
<!-- Default Settings -->
<arg name="colors"/>
```
*   是否顯示顏色

#### 選定 Standard
```xml
<rule ref="PSR2">
```
* 以 PSR2 為例

#### Standard 中排除特定 Sniff
```xml
<rule ref="PSR2">
    <exclude name="PSR1.Files.SideEffects"/>
    <exclude name="PSR1.Methods.CamelCapsMethodName"/>
    <exclude name="PSR1.Classes.ClassDeclaration.MissingNamespace"/>
</rule>
```
*   PSR2 中排除 PSR1.files.SideEffects
*   透過 phpcs --standard=YouWantToSearch -e 查找條規名稱

#### 套用特定 Sniff
```xml
<rule ref="Generic.Arrays.ArrayIndent"/>
<rule ref="Generic.Arrays.DisallowLongArraySyntax"/>
<rule ref="Generic.ControlStructures.InlineControlStructure"/>
<rule ref="Generic.Formatting.SpaceAfterCast"/>
<rule ref="Generic.PHP.DeprecatedFunctions"/>
<rule ref="Generic.PHP.Syntax"/>
<rule ref="Generic.WhiteSpace.IncrementDecrementSpacing"/>
```

#### 程式碼忽略檢查 ignore by inline comment
```diff
@@ -42,6 +43,7 @@ class Ticket extends Model
         return $this->belongsTo(Customer::class, 'customer_id');
     }

+    // phpcs:disable PSR1.Methods.CamelCapsMethodName
     public function customer_inventory()
     {
         return $this->hasMany(CustomerInventory::class, 'order_id', 'id');
```

#### 完整 Config 參考
```xml
<?xml version="1.0"?>
<ruleset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="PHP_CodeSniffer" xsi:noNamespaceSchemaLocation="phpcs.xsd">
    <description>The coding standard for PHP_CodeSniffer itself.</description>

    <!-- Scan Folder Settings -->
    <file>application</file>

    <exclude-pattern>*/application/libraries/*\.(inc|css|js|php)$</exclude-pattern>
    <exclude-pattern>*/application/third_party/*/*\.(inc|css|js|php)$</exclude-pattern>
    <exclude-pattern>*/application/modules/*/*\.(inc|css|js|php)$</exclude-pattern>


    <!-- Default Settings -->
    <arg name="colors"/>
    <arg name="parallel" value="75"/>


    <!-- Apply Standard -->
    <rule ref="Generic.Arrays.ArrayIndent"/>
    <rule ref="Generic.Arrays.DisallowLongArraySyntax"/>
    <rule ref="Generic.ControlStructures.InlineControlStructure"/>
    <rule ref="Generic.Formatting.SpaceAfterCast"/>
    <rule ref="Generic.PHP.DeprecatedFunctions"/>
    <rule ref="Generic.PHP.Syntax"/>
    <rule ref="Generic.WhiteSpace.IncrementDecrementSpacing"/>

    <rule ref="PSR2">
        <exclude name="PSR1.Files.SideEffects"/>
        <exclude name="PSR1.Methods.CamelCapsMethodName"/>
        <exclude name="PSR1.Classes.ClassDeclaration.MissingNamespace"/>
    </rule>


    <!-- Custom Rule or Threshold -->
    <!--
        lineLimit will show warnings
        absoulteLineLimit will show errors
    -->
    <rule ref="Generic.Files.LineLength">
        <properties>
            <property name="lineLimit" value="120"/>
            <!--<property name="absoluteLineLimit" value="120"/>-->
        </properties>
    </rule>

    <rule ref="Generic.Files.LineLength.MaxExceeded">
        <message>Line contains %s chars, which is longer than the max limit of %s</message>
    </rule>
    <rule ref="Generic.Files.LineLength.TooLong">
        <message>Line longer than %s characters; contains %s characters</message>
    </rule>
</ruleset>

```
{{< admonition summary 文章系列>}}
1. [PHP Linter 和 Formater 選擇](/php-linter-formater/)
2. _解密 PHP_CodeSniffer Configuration File_
3. [優雅導入 PHP CS_Sniffer 至 Legacy 專案](/introduce-php-linter-in-the-smooth-way/)
{{< /admonition>}}