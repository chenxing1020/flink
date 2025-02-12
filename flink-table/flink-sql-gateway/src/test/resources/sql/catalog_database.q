# catalog_database.q - CREATE/DROP/SHOW/USE CATALOG/DATABASE
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ==========================================================================
# validation test
# ==========================================================================

use non_existing_db;
!output
org.apache.flink.table.catalog.exceptions.CatalogException: A database with name [non_existing_db] does not exist in the catalog: [default_catalog].
!error

use catalog non_existing_catalog;
!output
org.apache.flink.table.catalog.exceptions.CatalogException: A catalog with name [non_existing_catalog] does not exist.
!error

create catalog invalid.cat with ('type'='generic_in_memory');
!output
org.apache.flink.sql.parser.impl.ParseException: Encountered "." at line 1, column 23.
Was expecting one of:
    <EOF> 
    "WITH" ...
    "COMMENT" ...
    ";" ...
!error

create database my.db;
!output
org.apache.flink.table.api.ValidationException: Catalog my does not exist
!error

# ==========================================================================
# test catalog
# ==========================================================================

create catalog c1 with ('type'='generic_in_memory');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show catalogs;
!output
+-----------------+
|    catalog name |
+-----------------+
|              c1 |
| default_catalog |
+-----------------+
2 rows in set
!ok

show catalogs like '%c1';
!output
+--------------+
| catalog name |
+--------------+
|           c1 |
+--------------+
1 row in set
!ok

show catalogs not like 'default%';
!output
+--------------+
| catalog name |
+--------------+
|           c1 |
+--------------+
1 row in set
!ok

show catalogs ilike '%c1';
!output
+--------------+
| catalog name |
+--------------+
|           c1 |
+--------------+
1 row in set
!ok

show catalogs not ilike 'default%';
!output
+--------------+
| catalog name |
+--------------+
|           c1 |
+--------------+
1 row in set
!ok

show current catalog;
!output
+----------------------+
| current catalog name |
+----------------------+
|      default_catalog |
+----------------------+
1 row in set
!ok

use catalog c1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show current catalog;
!output
+----------------------+
| current catalog name |
+----------------------+
|                   c1 |
+----------------------+
1 row in set
!ok

drop catalog default_catalog;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create catalog cat_comment comment 'hello ''catalog''' WITH ('type'='generic_in_memory', 'default-database'='db');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show create catalog cat_comment;
!output
CREATE CATALOG `cat_comment`
COMMENT 'hello ''catalog'''
WITH (
  'default-database' = 'db',
  'type' = 'generic_in_memory'
)
!ok

describe catalog cat_comment;
!output
+-----------+-------------------+
| info name |        info value |
+-----------+-------------------+
|      name |       cat_comment |
|      type | generic_in_memory |
|   comment |   hello 'catalog' |
+-----------+-------------------+
3 rows in set
!ok

describe catalog extended cat_comment;
!output
+-------------------------+-------------------+
|               info name |        info value |
+-------------------------+-------------------+
|                    name |       cat_comment |
|                    type | generic_in_memory |
|                 comment |   hello 'catalog' |
| option:default-database |                db |
+-------------------------+-------------------+
4 rows in set
!ok

create catalog if not exists cat_comment comment 'hello' with ('type' = 'generic_in_memory');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create catalog cat_comment comment 'hello2' with ('type' = 'generic_in_memory');
!output
org.apache.flink.table.catalog.exceptions.CatalogException: Catalog cat_comment already exists.
!error

create catalog cat2 WITH ('type'='generic_in_memory', 'default-database'='db');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show create catalog cat2;
!output
CREATE CATALOG `cat2`
WITH (
  'default-database' = 'db',
  'type' = 'generic_in_memory'
)
!ok

describe catalog cat2;
!output
+-----------+-------------------+
| info name |        info value |
+-----------+-------------------+
|      name |              cat2 |
|      type | generic_in_memory |
|   comment |                   |
+-----------+-------------------+
3 rows in set
!ok

describe catalog extended cat2;
!output
+-------------------------+-------------------+
|               info name |        info value |
+-------------------------+-------------------+
|                    name |              cat2 |
|                    type | generic_in_memory |
|                 comment |                   |
| option:default-database |                db |
+-------------------------+-------------------+
4 rows in set
!ok

desc catalog cat2;
!output
+-----------+-------------------+
| info name |        info value |
+-----------+-------------------+
|      name |              cat2 |
|      type | generic_in_memory |
|   comment |                   |
+-----------+-------------------+
3 rows in set
!ok

desc catalog extended cat2;
!output
+-------------------------+-------------------+
|               info name |        info value |
+-------------------------+-------------------+
|                    name |              cat2 |
|                    type | generic_in_memory |
|                 comment |                   |
| option:default-database |                db |
+-------------------------+-------------------+
4 rows in set
!ok

alter catalog cat2 set ('default-database'='db_new');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

desc catalog extended cat2;
!output
+-------------------------+-------------------+
|               info name |        info value |
+-------------------------+-------------------+
|                    name |              cat2 |
|                    type | generic_in_memory |
|                 comment |                   |
| option:default-database |            db_new |
+-------------------------+-------------------+
4 rows in set
!ok

alter catalog cat2 reset ('default-database', 'k1');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

desc catalog extended cat2;
!output
+-----------+-------------------+
| info name |        info value |
+-----------+-------------------+
|      name |              cat2 |
|      type | generic_in_memory |
|   comment |                   |
+-----------+-------------------+
3 rows in set
!ok

alter catalog cat2 reset ('type');
!output
org.apache.flink.table.api.ValidationException: ALTER CATALOG RESET does not support changing 'type'
!error

alter catalog cat2 reset ();
!output
org.apache.flink.table.api.ValidationException: ALTER CATALOG RESET does not support empty key
!error

alter catalog cat2 comment 'comment for catalog ''cat2''';
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

desc catalog extended cat2;
!output
+-----------+----------------------------+
| info name |                 info value |
+-----------+----------------------------+
|      name |                       cat2 |
|      type |          generic_in_memory |
|   comment | comment for catalog 'cat2' |
+-----------+----------------------------+
3 rows in set
!ok

alter catalog cat2 comment '';
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

desc catalog extended cat2;
!output
+-----------+-------------------+
| info name |        info value |
+-----------+-------------------+
|      name |              cat2 |
|      type | generic_in_memory |
|   comment |                   |
+-----------+-------------------+
3 rows in set
!ok

# ==========================================================================
# test database
# ==========================================================================

create database db1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show databases;
!output
+---------------+
| database name |
+---------------+
|           db1 |
|       default |
+---------------+
2 rows in set
!ok

show current database;
!output
+-----------------------+
| current database name |
+-----------------------+
|               default |
+-----------------------+
1 row in set
!ok

use db1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show current database;
!output
+-----------------------+
| current database name |
+-----------------------+
|                   db1 |
+-----------------------+
1 row in set
!ok

create database db2 comment 'db2_comment' with ('k1' = 'v1');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

alter database db2 set ('k1' = 'a', 'k2' = 'b');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

# TODO: show database properties when we support DESCRIBE DATABASE

show databases;
!output
+---------------+
| database name |
+---------------+
|           db1 |
|           db2 |
|       default |
+---------------+
3 rows in set
!ok

drop database if exists db2;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show databases;
!output
+---------------+
| database name |
+---------------+
|           db1 |
|       default |
+---------------+
2 rows in set
!ok

# ==========================================================================
# test playing with keyword identifiers
# ==========================================================================

create catalog `mod` with ('type'='generic_in_memory');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

use catalog `mod`;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

use `default`;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

drop database `default`;
!output
org.apache.flink.table.api.ValidationException: Cannot drop a database which is currently in use.
!error

drop catalog `mod`;
!output
org.apache.flink.table.catalog.exceptions.CatalogException: Cannot drop a catalog which is currently in use.
!error

use catalog `c1`;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

drop catalog `mod`;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

# ==========================================================================
# test create/drop table with catalog
# ==========================================================================

use catalog hivecatalog;
!output
org.apache.flink.table.catalog.exceptions.CatalogException: A catalog with name [hivecatalog] does not exist.
!error

create table MyTable1 (a int, b string) with ('connector' = 'values');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create table MyTable2 (a int, b string) with ('connector' = 'values');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

# hive catalog is case-insensitive
show tables;
!output
+------------+
| table name |
+------------+
|   MyTable1 |
|   MyTable2 |
+------------+
2 rows in set
!ok

show views;
!output
Empty set
!ok

create view MyView1 as select 1 + 1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create view MyView2 as select 1 + 1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show views;
!output
+-----------+
| view name |
+-----------+
|   MyView1 |
|   MyView2 |
+-----------+
2 rows in set
!ok

# test create with full qualified name
create table c1.db1.MyTable3 (a int, b string) with ('connector' = 'values');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create table c1.db1.MyTable4 (a int, b string) with ('connector' = 'values');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create view c1.db1.MyView3 as select 1 + 1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create view c1.db1.MyView4 as select 1 + 1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

use catalog c1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

use db1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show tables;
!output
+------------+
| table name |
+------------+
|   MyTable3 |
|   MyTable4 |
|    MyView3 |
|    MyView4 |
+------------+
4 rows in set
!ok

show views;
!output
+-----------+
| view name |
+-----------+
|   MyView3 |
|   MyView4 |
+-----------+
2 rows in set
!ok

# test create with database name
create table `default`.MyTable5 (a int, b string) with ('connector' = 'values');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create table `default`.MyTable6 (a int, b string) with ('connector' = 'values');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create view `default`.MyView5 as select 1 + 1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create view `default`.MyView6 as select 1 + 1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

use `default`;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show tables;
!output
+------------+
| table name |
+------------+
|   MyTable1 |
|   MyTable2 |
|   MyTable5 |
|   MyTable6 |
|    MyView1 |
|    MyView2 |
|    MyView5 |
|    MyView6 |
+------------+
8 rows in set
!ok

show views;
!output
+-----------+
| view name |
+-----------+
|   MyView1 |
|   MyView2 |
|   MyView5 |
|   MyView6 |
+-----------+
4 rows in set
!ok

drop table db1.MyTable3;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

drop view db1.MyView3;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

use db1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show tables;
!output
+------------+
| table name |
+------------+
|   MyTable4 |
|    MyView4 |
+------------+
2 rows in set
!ok

show views;
!output
+-----------+
| view name |
+-----------+
|   MyView4 |
+-----------+
1 row in set
!ok

drop table c1.`default`.MyTable6;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

drop view c1.`default`.MyView6;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

use `default`;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show tables;
!output
+------------+
| table name |
+------------+
|   MyTable1 |
|   MyTable2 |
|   MyTable5 |
|    MyView1 |
|    MyView2 |
|    MyView5 |
+------------+
6 rows in set
!ok

show views;
!output
+-----------+
| view name |
+-----------+
|   MyView1 |
|   MyView2 |
|   MyView5 |
+-----------+
3 rows in set
!ok

# ==========================================================================
# test configuration is changed (trigger new ExecutionContext)
# ==========================================================================

create table MyTable7 (a int, b string) with ('connector' = 'values');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show tables;
!output
+------------+
| table name |
+------------+
|   MyTable1 |
|   MyTable2 |
|   MyTable5 |
|   MyTable7 |
|    MyView1 |
|    MyView2 |
|    MyView5 |
+------------+
7 rows in set
!ok

reset;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

drop table MyTable5;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show tables;
!output
+------------+
| table name |
+------------+
|   MyTable1 |
|   MyTable2 |
|   MyTable7 |
|    MyView1 |
|    MyView2 |
|    MyView5 |
+------------+
6 rows in set
!ok

# ==========================================================================
# test enhanced show tables and views
# ==========================================================================

create catalog catalog1 with ('type'='generic_in_memory');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create database catalog1.db1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create table catalog1.db1.person (a int, b string) with ('connector' = 'datagen');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create table catalog1.db1.dim (a int, b string) with ('connector' = 'datagen');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create table catalog1.db1.address (a int, b string) with ('connector' = 'datagen');
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create view catalog1.db1.v_person as select * from catalog1.db1.person;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

create view catalog1.db1.v_address comment 'view comment' as select * from catalog1.db1.address;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show tables from catalog1.db1;
!output
+------------+
| table name |
+------------+
|    address |
|        dim |
|     person |
|  v_address |
|   v_person |
+------------+
5 rows in set
!ok

show views from catalog1.db1;
!output
+-----------+
| view name |
+-----------+
| v_address |
|  v_person |
+-----------+
2 rows in set
!ok

show tables from catalog1.db1 like '%person%';
!output
+------------+
| table name |
+------------+
|     person |
|   v_person |
+------------+
2 rows in set
!ok

show views from catalog1.db1 like '%person%';
!output
+-----------+
| view name |
+-----------+
|  v_person |
+-----------+
1 row in set
!ok

show tables in catalog1.db1 not like '%person%';
!output
+------------+
| table name |
+------------+
|    address |
|        dim |
|  v_address |
+------------+
3 rows in set
!ok

show views in catalog1.db1 not like '%person%';
!output
+-----------+
| view name |
+-----------+
| v_address |
+-----------+
1 row in set
!ok

use catalog catalog1;
!output
+--------+
| result |
+--------+
|     OK |
+--------+
1 row in set
!ok

show tables from db1 like 'p_r%';
!output
+------------+
| table name |
+------------+
|     person |
+------------+
1 row in set
!ok

show views from db1 like '%p_r%';
!output
+-----------+
| view name |
+-----------+
|  v_person |
+-----------+
1 row in set
!ok
