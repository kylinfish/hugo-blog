+++
draft = false
categories = ['技術']
tags = ['Scala', 'Python']
date = "2019-12-25T14:30:12+08:00"
description = "Spark Cheat Sheet for scala and python"
title = "Spark Cheat Sheet for Scala/Python"
absolute_banner="/img/post/spark.jpeg"
og_images = ["/img/post/spark.jpeg"]
+++
<!--more-->
## Read the parquet file
{{< highlight shell >}}
scala> val param = spark.read.parquet("s3://file_path_you_put")
{{< /highlight  >}}

## Print the parquet file schema
{{< highlight shell >}}
scala> param.printSchema()

root
 |-- sha1: string (nullable = true)
 |-- label: string (nullable = true)
 |-- time: long (nullable = true)
{{< /highlight  >}}

## Print the parquet content
{{< highlight shell >}}
scala> new_result.show()
+--------------------+-----+----------+
|                uuid|label|      time|
+--------------------+-----+----------+
|d8f9ba869c19f25cc...| Hell|1562112000|
|f8e172cb34d620bbe...|     |1562112000|
|28eb0ec1e0d549a58...| PUMA|1562112000|
|602e7cbc21f84c73c...| Hell|1562112000|
|0dbdd026b7289c878...| Hell|1562112000|
|769dc575d8c918a35...|     |1562112000|
|eb2d649caaa5c50af...| PUMA|1562112000|
|54c4a913e155e7498...| Hell|1562112000|
|f869bc9db782403e6...| Hell|1562112000|
|1267183b43b770323...| Hell|1562112000|
|c688e203dddff994a...| Vior|1562112000|
|9feebd3baf18ead6b...|  PUA|1562112000|
|c1b24674530e9800e...| Hell|1562112000|
|8e4b8fa293b59359e...| Hell|1562112000|
|2743920303b11901a...| PUMA|1562112000|
|0bcec8ac02f891fc7...| Hell|1562112000|
|1cdafdde2a10df9fa...| Hell|1562112000|
|c4ac9ae9db127a9d2...| SPYD|1562112000|
|145760249908bb4f7...| PUMA|1562112000|
|e5622270036303a86...| Hell|1562112000|
+--------------------+-----+----------+
only showing top 20 rows
{{< /highlight  >}}

## Get the number of rows
{{< highlight shell >}}
scala> new_result.count()
res8: Long = 568
{{< /highlight  >}}

## Join two dataframes (with name alias)
{{< highlight shell >}}
scale> val jt = new_df.as("n").join(old_df.as("o"), "uuid")

jt: org.apache.spark.sql.DataFrame = [uuid: string, label: string ... 3 more fields]
{{< /highlight  >}}

## Filter two fields for the different value
{{< highlight shell >}}
scala> jt.filter(! ($"n.label" <=> $"o.label")).show()
+--------------------+-----+----------+-----+----------+
|                uuid|label|      time|label|      time|
+--------------------+-----+----------+-----+----------+
|e3198d3d3b51d245a...|     |1562112000| Hell|1562112000|
+--------------------+-----+----------+-----+----------+
{{< /highlight  >}}

ref: [scala filtering out rows in a joined df based on 2 columns with same values - best way](https://stackoverflow.com/questions/54065130/scala-filtering-out-rows-in-a-joined-df-based-on-2-columns-with-same-values-be)

## PySpark Example

Read csv file and transform to data frame.
{{< highlight python >}}
ps_schema = StructType([
    StructField("sha1", StringType(), True),
    StructField("label", StringType(), True),
    StructField("time", LongType(), True)
])

spark.read.csv("file.csv", header=False, schema=ps_schema)
{{< /highlight  >}}

## PDF External Link

{{< pdf url="https://s3.amazonaws.com/assets.datacamp.com/blog_assets/PySpark_SQL_Cheat_Sheet_Python.pdf" height="500px" >}}

[https://s3.amazonaws.com/assets.datacamp.com/blog_assets/PySpark_SQL_Cheat_Sheet_Python.pdf](https://s3.amazonaws.com/assets.datacamp.com/blog_assets/PySpark_SQL_Cheat_Sheet_Python.pdf)
