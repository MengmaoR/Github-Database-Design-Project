#!/usr/bin/python
import psycopg2
import os

# SQL 文件路径
FILE_PATH = './sql'

def execute_sql(sql_file_name, split, conn, cur):
    sql_file_path = os.path.join(FILE_PATH, sql_file_name)

    with open(sql_file_path, 'r', encoding='utf-8') as file:
        sql_script = file.readlines()

     # 剔除注释行
    filtered_commands = [line.strip() for line in sql_script if not line.strip().startswith('--') and line.strip()]

    # 将有效的 SQL 语句合并为一个字符串
    sql_commands = ' '.join(filtered_commands).split(split)

    for command in sql_commands:
        command = command.strip()
        if command:
            # print(f'Executing command:\n{command}')
            try:
                cur.execute(command)
                print(f'Successfully executed command: {command}\n')
            except Exception as e:
                print(f'Error executing command: {command}\n{e}')
                conn.rollback()  # 回滚事务
                break

    # 提交事务
    conn.commit()

def drop(conn, cur):
    sql_file_name = 'drop.sql'
    split = ';'
    execute_sql(sql_file_name, split, conn, cur)


def create_table(conn, cur):
    sql_file_name = 'create_table.sql'
    split = ';'
    execute_sql(sql_file_name, split, conn, cur)

def create_view(conn, cur):
    sql_file_name = 'create_view.sql'
    split = ';'
    execute_sql(sql_file_name, split, conn, cur)

def create_trigger(conn, cur):
    sql_file_name = 'create_trigger.sql'
    split = '##'
    execute_sql(sql_file_name, split, conn, cur)

def create_procedure(conn, cur):
    sql_file_name = 'create_procedure.sql'
    split = '##'
    execute_sql(sql_file_name, split, conn, cur)

def recreate(conn, cur):
    drop(conn, cur)
    create_table(conn, cur)
    create_view(conn, cur)
    create_trigger(conn, cur)
    create_procedure(conn, cur)

def reinsert(conn, cur):
    drop(conn, cur)
    create_table(conn, cur)
    create_view(conn, cur)
    create_procedure(conn, cur)

if __name__ == '__main__':
    # 连接数据库
    with open('./db_link.txt', 'r', encoding='utf-8') as file:
        db_link = file.readlines()

    db_link = [line.strip() for line in db_link if line.strip()]

    config = ''.join(db_link).split(',')

    # 数据库连接配置
    DB_CONFIG = {
        "database": config[0],
        "user": config[1],
        "password": config[2],
        "host": config[3],
        "port": config[4],
    }

    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    create_procedure(conn, cur)
    # recreate(conn, cur)

    conn.close()    