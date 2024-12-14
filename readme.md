# Github-Database-Design-Project

## 项目简介
本项目基于 Github 网站的基础数据，设计了一个数据库，用于存储 Github 网站上的用户、仓库、代码、问题、评论等信息。项目包含了数据库的设计文档、数据库的创建脚本、数据库的生成脚本、数据库的管理脚本、数据库的交互脚本等。

## 数据库连接
要将项目脚本连接至您的数据库，需先在主目录下创建一个db_link.txt文件，并在其中写入您的数据库配置信息，格式如下：
``` ./db_link.txt
your_database,
your_user,
your_password,
your_host,
your_port
```

## 数据库管理
执行 ./db_manage.py 脚本可以对数据库结构进行管理，包括创建和删除表、视图及触发器。
``` shell
python3 db_manage.py
```

## 随机生成数据
执行 ./db_generate.py 脚本可以基于faker库随机生成数据并插入数据库，数据涵盖所有表及视图，并可符合所有表级约束条件。但由于触发器的存在，插入数据时可能会出现约束冲突，此时会跳过该条数据的插入。
``` shell
python3 db_generate.py
```

## 数据库交互
执行 ./web/app.py 脚本可以启动一个简单的web应用，用于与数据库进行交互，网页将会运行在本地的5000端口。网页允许输入 SQL 语句进行查询，并可与生成式 AI 进行问答，以辅助用户编写 SQL 语句。
``` shell
python3 web/app.py
```

## 作者
- MengmaoR
- lifang535
- iPhone38