import psycopg2
import random
import string

# 连接到数据库
conn = psycopg2.connect(database="db_test", user="user_test", password="DBlab@123456", host="120.46.137.179", port="5432")
cur = conn.cursor()

# 插入 100 条数据
for i in range(100):
    # 生成随机的学生姓名
    s_name = ''.join(random.choices(string.ascii_letters, k=5))  # 生成一个长度为 5 的随机名字
    s_age = random.randint(18, 25)  # 年龄在 18 到 25 之间随机选择
    cur.execute("INSERT INTO student (s_name, s_age) VALUES (%s, %s)", (s_name, s_age))

# 提交事务
conn.commit()

# 关闭连接
cur.close()
conn.close()

print("插入 100 条数据成功！")
