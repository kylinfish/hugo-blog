---
title: "Spark Cheat Sheet for Scala/Python"
description: "Spark Cheat Sheet for scala and python"
date: "2019-12-25T14:30:12+08:00"
draft: false
tags: ['Scala', 'python', 'spark']
categories: ["技術"]

featuredImage: "/img/post/spark.jpeg"
images: [ "/img/post/spark.jpeg" ]

---

## Spark Example
### Read the parquet file
{{< highlight shell >}}
scala> val param = spark.read.parquet("s3://file_path_you_put")
{{< /highlight  >}}

### Print the parquet file schema
{{< highlight shell >}}
scala> param.printSchema()

root
 |-- sha1: string (nullable = true)
 |-- label: string (nullable = true)
 |-- time: long (nullable = true)
{{< /highlight  >}}

### Print the parquet content
{{< highlight shell >}}
scala> new_result.show()
+--------------------+-----+----------+
|                uuid|label|      time|
+--------------------+-----+----------+
|d8f9ba869c19f25cc...| Hell|1562112000|
|f8e172cb34d620bbe...|     |1562112000|
|28eb0ec1e0d549a58...| PUMA|1562112000|
|145760249908bb4f7...| PUMA|1562112000|
|e5622270036303a86...| Hell|1562112000|
+--------------------+-----+----------+
only showing top 20 rows
{{< /highlight  >}}

### Get the number of rows
{{< highlight shell >}}
scala> new_result.count()
res8: Long = 568
{{< /highlight  >}}

### Join two dataframes (with name alias)
{{< highlight shell >}}
scale> val jt = new_df.as("n").join(old_df.as("o"), "uuid")

jt: org.apache.spark.sql.DataFrame = [uuid: string, label: string ... 3 more fields]
{{< /highlight  >}}

### Filter two fields for the different value
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

### Read csv file and transform to data frame.
{{< highlight python >}}
ps_schema = StructType([
    StructField("sha1", StringType(), True),
    StructField("label", StringType(), True),
    StructField("time", LongType(), True)
])

spark.read.csv("file.csv", header=False, schema=ps_schema)
{{< /highlight  >}}

### Count number of duplicate rows

{{< highlight python >}}
import pyspark.sql.functions as funcs
df.groupBy(df.columns) \
    .count() \
    .where(funcs.col('count') > 1) \ # Filter count condition
    .select(funcs.sum('count')) \
    .show()
{{< /highlight  >}}

[https://proinsias.github.io/til/Spark-Count-number-of-duplicate-rows/](https://proinsias.github.io/til/Spark-Count-number-of-duplicate-rows/)



### Convert Dataframe to CSV or HTML String for email report usage

{{< highlight python >}}

df = spark.read.csv("file.csv", header=False, schema=ps_schema)
panda_df = df.toPandas()

panda_df.to_html()
panda_df.to_csv()
{{< /highlight  >}}

[https://docs.databricks.com/spark/latest/spark-sql/spark-pandas.html](https://docs.databricks.com/spark/latest/spark-sql/spark-pandas.html)

[https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.to_csv.html](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.to_csv.html)

### Spark Read multiple CSV files and parquet files

#### parquet

{{< highlight python >}}
release_date = datetime.strptime("2020/10/10", '%Y/%m/%d')
process_dates = ["s3://sample/" + (release_date - timedelta(days=x)).strftime("%Y/%m/%d")
                         for x in range(0, 10)]

total_df = spark.read.parquet(*process_dates).select("sha1", "reqBody").cache()
{{< /highlight  >}}

#### CSV

{{< highlight python >}}
release_date = datetime.strptime("2020/10/10", '%Y/%m/%d')
process_dates = ["s3://sample/" + (release_date - timedelta(days=x)).strftime("%Y/%m/%d")
                         for x in range(0, 10)]

total_df = spark.read.format("csv").option("header", "False").schema(StructType([
    StructField("sha1", StringType(), True),
    StructField("count", IntegerType(), True)
])).load(process_dates)
{{< /highlight  >}}

## PDF External Link
[https://s3.amazonaws.com/assets.datacamp.com/blog_assets/PySpark_SQL_Cheat_Sheet_Python.pdf](https://s3.amazonaws.com/assets.datacamp.com/blog_assets/PySpark_SQL_Cheat_Sheet_Python.pdf)
