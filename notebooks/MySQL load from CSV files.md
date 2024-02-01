---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.16.1
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

# Load CSV to MySQL/MariaDB or Spark SQL using PySpark

It is very useful in the data exploration or descriptive analytics phase of a project to be able to query your CSV files more or less directly using the power of SQL.

Spark makes this very simple by creating tables in Hive that reference the CSVs. In addition to SQL, this gives us the additional capabilities of the Spark and Pandas data frames.

Spark then allows us to create permanent tables in Hive using the very efficient Parquet file format. 

If we then want to store to a database outside of the Spark environment, we can save those dataframes to MySQL/MariaDB or other JDBC compliant databases.

## Prep the Spark server with the required JDBC driver `.jar` file

On Databricks, this can be done in the UI: Compute -> cluster -> Libraries

## Prep the target MySQL/MariaDB server
Create the database you want to use beforehand.  This code will create tables, but not the database.

On local Spark, the `.jar` can be placed in `$SPARK_HOME/jars/`


## Import libraries and configure secrets

In this example, we are using the `configparser` library to read a simple `.ini` style file named `CREDENTIALS.config`.  If you choose to use this method, create a section in the file like this:
```
[csvload]
sqluser = <myuser>
sqlpassword = <mypass>
sqlhost = <host or ip>
sqlport = <3306 or custom port>
sqldb = <database name>
```


```python
import pyspark
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField
from pyspark.sql.types import StringType, IntegerType
from pyspark.sql.types import DateType

import pandas as pd
from configparser import ConfigParser

import os
os.environ['PYSPARK_SUBMIT_ARGS'] = '--jars /usr/share/java/mariadb-java-client.jar pyspark-shell'

import findspark
findspark.init()

```

```python
# !env|grep SPARK
# !cp -v /usr/share/java/mariadb-java-client.jar $SPARK_HOME/jars/
```

# Establish our Spark session

```python
# spark = SparkSession.builder.config("spark.jars", "/usr/share/java/mariadb-java-client.jar").appName("TeslafiLoad").getOrCreate()
spark = SparkSession.builder.appName("CSVLoad").getOrCreate()
sc = spark.sparkContext
```

```python
# !echo $VIRTUAL_ENV
# !env|grep SPARK
!echo $SPARK_HOME
# !cp -v  /usr/share/java/mariadb-java-client.jar $SPARK_HOME/jars/
# !ls $SPARK_HOME/jars
# # !pip install pandas findspark
```

```python
# os.listdir(path='/data/data-files/teslafi/')
```

# Optional - create a Spark/Hive temporary table from the data

<!-- #region -->
# Write CSVs to MySQL/MariaDB


## Set all the parameters
For privacy, you may prefer to load `csvdir` from `CREDENTIALS.config`.  

The same goes for all the parameters.  Default practice is load everything from the credentials file, 
then override one or two variables as long as the values would not cause problems if checked in to a public repo.

<!-- #endregion -->

```python
# File location and type

file_type = "csv"
# CSV options
infer_schema = "true"
first_row_is_header = "true"
# delimiter = "\t"
delimiter = ","

# MySQL/MariaDB info
# Get credentials from file
config_section = 'stardog-mysql'
parser = ConfigParser()
_ = parser.read('CREDENTIALS.config')

# csvdir = parser.get(config_section, 'csvdir')
csvdir = '/home/gregj/projects/graph/stardog/poc-sk-telecom/data/'
user = parser.get(config_section, 'sqluser')
password = parser.get(config_section, 'sqlpassword')
host = parser.get(config_section, 'sqlhost')
port = parser.get(config_section, 'sqlport')
# db = parser.get(config_section, 'sqldb')
db = 'airtaxi'
sqlurl = 'jdbc:mysql://' + host + ':' + port + '/' + db

# csvdir = '/data/graph-data/AntiFraud/data/'
# csvdir = '/data/data-files/teslafi/'
# csvdir = '/data/graph-data/ldbc-workshop/data/'
```

```python
csvdir
```

## Write the CSVs to the database
Database must be created beforehand, but not the tables

Modify the rules paying special attention to the `timestamp` columns in the dataframe.  `TIMESTAMP` column type in MySQL cannot represent dates prior to 1980.  If needed, transfer those dataframe columes to `date` prior to creating the MySQL table with `df.write()`

```python
# # for path,name in [(f.path,f.name) for f in dbutils.fs.ls(csvdir) if f.path.endswith('.csv')  ]:
for fname in os.listdir(path=csvdir):
# for fname in next(os.walk(csvdir))[1]:
    # dirname = fname # or ''
    # fname = 'data.csv'
    if fname.endswith('.csv'):  # and fname.startswith('teslafi-20'):
    
        # if not fname in ['ff_party.csv', 'ff_company.csv']:
        #     print('skipping ' + fname)
        #     continue
        df = spark.read.format('csv') \
        .option("inferSchema", True) \
        .option("header", True) \
        .option("sep", delimiter) \
        .option("dateFormat", "yyyy-mm-dd") \
        .option("na_values", ["None", None]) \
        .load(csvdir + '/' + fname)
        # timestamp type in MySQL represents dates only after 1980
        # if timestamp is desired, comment or modify the following code
        # this code changes *all* timestamp columns to Date type
        for a,b in df.dtypes:
            if b == "timestamp" and a.find("timestamp") < 0: 
                newdf = df.withColumn(a, df[a].cast(DateType()))
                print('   CHANGED column ' + a + ' to Date type')
                df = newdf
            if '.' in a:
                df.withColumnRenamed(a, a.replace(',', '_'))
        # Modify filename-to-tablename as needed
        tablename = fname.replace('.csv','').replace('.tsv','').replace('-', '_').replace('c360_','').replace('exampledata','')
        # tablename = dirname
        print(tablename)
        df.write.format('jdbc').options(
            url=sqlurl,
            driver='org.mariadb.jdbc.Driver',
            dbtable=tablename,
            user=user,
            password=password).mode('overwrite').save()        
        # append or overwrite or ignore
```

fname

```python
# pprint
df.printSchema()
```

```python
df
```

```python
p = df.toPandas()
# p[''].unique()

```

```python
p
```
