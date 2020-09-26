---
title: 🥊SQL 拾遗
date: '2020-08-16'
slug: sql-tutorial
author: DG
tags: 
  - 编程
  - 代码
categories: 
  - SQL
---

*大纲* 

1. MySQL 创建数据库
2. MySQL 用户管理
3. MySQL CURD
4. MySQL 事务
5. MySQL 引擎
6. 其他与补充

> Docker 创建数据库
>
> ```bash
> docker run -d --name=mysql5.7 -p 3307:3306 -e MYSQL_ROOT_PASSWORD=liu12134 mysql:5.7
> ```
>
> 

## #mysql 创建数据库

<p style="color:green">//TODO</p>

> ### MYSQL 默认编码与UTF8、UTF8MB4的区别
>
> - MySQL 默认编码
>
>   在 MYSQL 8.0 以上 默认编码为 UTF8MB4
>
>   ```bash
>   mysql> show  variables like '%char%';
>   +--------------------------+--------------------------------+
>   | Variable_name            | Value                          |
>   +--------------------------+--------------------------------+
>   | character_set_client     | latin1                         |
>   | character_set_connection | latin1                         |
>   | character_set_database   | utf8mb4                        |
>   | character_set_filesystem | binary                         |
>   | character_set_results    | latin1                         |
>   | character_set_server     | utf8mb4                        |
>   | character_set_system     | utf8                           |
>   | character_sets_dir       | /usr/share/mysql-8.0/charsets/ |
>   +--------------------------+--------------------------------+
>   8 rows in set (0.00 sec)
>   ```
>
>   在MySQL 8.0以下， 默认便为 latin1
>
>   ```bash
>   mysql> show variables like '%char%';
>   +--------------------------+----------------------------+
>   | Variable_name            | Value                      |
>   +--------------------------+----------------------------+
>   | character_set_client     | latin1                     |
>   | character_set_connection | latin1                     |
>   | character_set_database   | latin1                     |
>   | character_set_filesystem | binary                     |
>   | character_set_results    | latin1                     |
>   | character_set_server     | latin1                     |
>   | character_set_system     | utf8                       |
>   | character_sets_dir       | /usr/share/mysql/charsets/ |
>   +--------------------------+----------------------------+
>   8 rows in set (0.00 sec)
>   ```
>
>   
>
> - MySQL 的 UTF8
>
> - MySQL的UTF8MB4

### ##创建默认字符集的数据库

```sql
create database test1 
```

### ##创建 UTF8MB4 数据库

```sql
create database test2 default character set utf8mb4 collate utf8mb4_general_ci
```

> 1. 数据库名称不需要添加单引号
>
> 2. collate
>
>    collate 指定数据库用来排序的规则，规则 名中 ci 表示`Case insensitive`  意为排序时大小不敏感。general 表示该字符集默认的排序规则。
>
>    在 MySQL 8.0 以下的版本中，默认编码为 `latin1` ，默认 collate 为`latin1_swedish_ci`, MySQL 8.0 以上版本中，默认编码为 `utf8mb4`， 默认collate 为 `utf8mb4_0900_ai_ci`。
>
>    使用 `show collation` 可以查看所有支持的规则。

### ##查看数据库字符集

```mysql
select schema_name, default_character_set_name, default_collation_name from information_schema.schemata where schema_name='test1';
```

得到的结果是：

```bash
mysql> select schema_name, default_character_set_name, default_collation_name from information_schema.schemata where schema_name='test1';
+-------------+----------------------------+------------------------+
| SCHEMA_NAME | DEFAULT_CHARACTER_SET_NAME | DEFAULT_COLLATION_NAME |
+-------------+----------------------------+------------------------+
| test1       | utf8                       | utf8_general_ci        |
+-------------+----------------------------+------------------------+
1 row in set (0.00 sec)
```



### ##修改数据库字符集

```mysql
alter database test1 default character set utf8 collate set utf8_general_ci;
```

### ##删除数据库

```mysql
drop database test1;
```



## #数据库用户管理

### ##用户创建

```bash
create user 'test'@'%' identified by '123456'; # 此用户只有登录权限
```



### ##用户权限控制

#### 修改密码

```mysql
# 修改自身密码
set password = password('123456789');
# 修改他人密码 本用户必须有管理权限
set password for 'test'@'%' = password('123456789');
```

#### 赋予权限

```mysql
grant select, delete, create on test4.test to 'test'@'%'; #直接给 test用户赋予权限
grant select, delete, create on test4.test to 'test'@'%' identified by '123456'; #直接给 test 用赋予权限并修改密码，如果用户不存在则创建用户并赋予权限。
grant all privileges on test4.test to 'test'@'%', # 赋予test用户 test4.test 的全部权限，其中 privileges 可省去。 ??TODO
grant all on test4.* to 'test'@'%'; #将test4 中所有对象的所有权限赋予test用户。
grant all on test4.* to 'test'@'%' with grant option ; #将test4 中所有对象的所有权限赋予test用户，并该权限可以传播。
grant all on *.* to 'test'@'%'; #将所有表的所有权限赋予test用户。

flush privileges; # 刷新用户权限。
```

#### 查看权限

```mysql
show grants from 'test'@'%';
```

#### 回收权限

```mysql
revoke all on test4.* from 'test'@'%';
revoke all on *.* from 'test'@'%';
```

#### 用户删除

 ```mysql
drop user 'test'@'%';
 ```

#### 用户修改

```mysql
rename user 'test'@'%' to 'test1'@'%'; # 用户修改
update
```

#### 查看所有用户

```mysql
# 在 mysql 数据库下
select user, host from user;
```

## 数据库 CURD

### ##SQL 导入外部 txt 文件

1. 创建目标表

   ```mysql
   create table pet (
       name VARCHAR(20),
       owner VARCHAR(20),
       species VARCHAR(20),
       sex CHAR(1),
       birth DATE,
       death DATE
   );
   ```

2. 创建 txt 文件

   ```txt
   Fluffy  Harold  cat     f       1993-02-04      \N
   Claws   Gwen    cat     m       1994-03-17      \N
   Buffy   Harold  dog     f       1989-05-13      \N
   Fang    Benny   dog     m       1990-08-27      \N
   Bowser  Diane   dog     m       1979-08-31      1995-07-29
   Chirpy  Gwen    bird    f       1998-09-11      \N
   Whistler        Gwen    bird    \N      1997-12-09      \N
   Slim    Benny   snake   m       1996-04-29      \N      
   ```

   > 不同数据之前千万要用制表符(Tab) 分隔，否则导入数据会出问题。

3. 导入

   ```mysql
   load data local infile '/data/pet.txt' into table pet;
   ```

### ##UPDATE

```mysql
update pet set birth='1989-08-31' where name = 'Bowser';
```

**待续...**