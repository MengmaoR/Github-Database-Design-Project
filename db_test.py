#!/usr/bin/python
import psycopg2
import os

conn = psycopg2.connect(database="db_test", user="user_test", password="DBlab@123456", host="120.46.137.179", port="5432")
cur = conn.cursor()

# 读取 SQL 文件并执行所有 SQL 语句
sql_file_path = '/Users/tianxj/Desktop/编程/数据库实践/github_db.sql'

with open(sql_file_path, 'r', encoding='utf-8') as file:
    sql_script = file.read()

# 分割 SQL 语句
sql_commands = sql_script.split(';')

for command in sql_commands:
    command = command.strip()
    if command:
        try:
            cur.execute(command)
        except Exception as e:
            print(f'Error executing command: {command}\n{e}')

# 查询结果
# cur.execute("SHOW ALL;")
cur.execute("SELECT * FROM student;")
rows = cur.fetchall()

for row in rows:
    print(row)

conn.commit()
conn.close()
