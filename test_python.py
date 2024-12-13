#!/usr/bin/python
import psycopg2

# conn = psycopg2.connect(database="dbsc", user="testuser2", password="DBlab@123", host="124.70.63.102", port="26000")
conn = psycopg2.connect(database="db_test", user="user_test", password="DBlab@123456", host="120.46.137.179", port="5432")
cur = conn.cursor()

# 查询结果
# cur.execute("SELECT * FROM student;")
cur.execute("SHOW ALL;")
rows = cur.fetchall()

for row in rows:
    # print("sno = ", row[0])
    # print("sname = ", row[1])
    # print("sgender = ", row[2])
    # print("sbirth = ", row[3])
    # print("sdept = ", row[4])
    print(row)

conn.commit()
conn.close()
