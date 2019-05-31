+++
draft = false
description = "釐清三種 Python Method 呼叫方式，Instance Method, Class Method, Static Method 差異"
tags = [ "python" ]
categories = [ "技術" ]
date = "2019-05-30T09:36:42+08:00"
title = "Clarify Three Types of Method in Python"
relative_banner="/post/python.jpg"
og_images = ["/img/post/python.jpg"]
+++

在 Python 中， Method 被呼叫的方式有三種，Instance, Class, Static 
其中 Class Method 跟一般我們用物件導向程式語言溝通有別，參考 RealPython 撰寫的文章釐清差異
<!--more-->
## Instance Method
- 可以直接存取被實例化(New)出來後的實體(Instance)本身所有屬性(Property)

- 其中 Instance Method 的第一個參數需傳入 `self`

- 可看成: `能夠任意修改 Object 的 State 狀態`

## Class Method
- 使用 `@classmethod` Decorator

- 其中 Class Method 的第一個參數需傳入 `cls`

- 代表會指向整個 Class Instance 而不是 Object Instace

- 可看成: `能夠任意修改 Class 的 State`，並套用到所有相同的類別實體

## Static Method

- 使用 `@staticmethod` Decorator

- 其中 Static Method 的第一個參數不需傳入， `不用 cls, 也不用 self`

- 故可看成: `既不能修改 Class State，也不能修改 Object state`

- Static Method 用來限制能存取的資料

----

## 使用範例

### Instance Method 

{{< highlight python>}}
>>> obj = MyClass()
>>> obj.method()
('instance method called', <MyClass instance at 0x101a2f4c8>)
{{< /highlight>}}

使用 Instance Method 是透過 `self` 來操作 New 出來的 Object 本身
當 __.method()__ 被呼叫的時候，Python 會自動把原先定義的第一個參數 `self` 自動改成 `obj` 也就是這個 Object 本身

<br>

故如果手動轉入 obj 本身，也會得到一樣的結果

{{< highlight python>}}
>>> MyClass.method(obj)
('instance method called', <MyClass instance at 0x101a2f4c8>)
{{< /highlight>}}

> BTW, Instance Method 是可以透過 `self.__class__` 屬性來存取 Class 本身的喔

> 代表可以同時操作 Object State 也能越級操作 Class State


### Class Method

{{< highlight python>}}
>>> obj.classmethod()
('class method called', <class MyClass at 0x101a2f4c8>)
{{< /highlight>}}

Class Mtehod 被呼叫時與 Instance Method 相同， 當 __MyClass.classmethod()__ 被呼叫的時候，Python 會自動把整個 Class 傳入原先定義的第一個參數 `cls`
其中糖衣作(dot syntax trigger)用與 Instance Method 被呼叫時雷同

PS. `self`, `cls` 只是命名，也可以用 `_object`, `_class`，但其實還是遵照 self, cls 大家都看得懂


### Staic Method

{{< highlight python>}}
>>> obj.staticmethod()
'static method called'
{{< /highlight>}}
 
其實背後，一樣也是透過糖衣(dot syntax)呼叫 Staic Method，Python 只是不幫你傳入 Class 或是 Object 而已
。其用意如文起所及，為了限制被存取的資料與屬性而生


## 關鍵重點 Key Takeaways
- Instance Method 
    - 最常見的物件導向觀念，需要建立整個 Class Instance 並且可以透過 `self` 存取 Instance 本身 data 和 properties
- Class Method
    - 不需要 Class Instance，**無法**透過 `self` 存取 Instance，但可以使用 `cls` 存取 Class 本身的 data 和 properies
- Static Method 無法使用 `self, cls` 存取 data 和 properties。操作有如一般的 function 但屬於 Class 的 Namespace

{{< bootstrap-table "table table-bordered" >}}
|Method 種類     | 需要 Class Instance | 使用 `self`| 使用 `cls` | 存取 Class | 存取 Instance|
|:--------------:|:-------------------:|:--------:|:----------:|:-----------:|:-------------:|
|Instance Method | **Yes** | **Yes** | No      | No      | **Yes** |
|Class Method    |  No     | No      | **Yes** | **Yes** |  No     |
|Static Method   |  No     | No      | No      | **Yes** |  No     |
{{< /bootstrap-table >}}


進階了解 Class Method 應用實例，可以參考
[RealPython - Delicious Pizza Factories With @classmethod](https://realpython.com/instance-class-and-static-methods-demystified/#delicious-pizza-factories-with-classmethod)

其他參考資料 - [Instance vs. Static vs. Class Methods in Python: The Important Differences](https://www.makeuseof.com/tag/python-instance-static-class-methods/)
