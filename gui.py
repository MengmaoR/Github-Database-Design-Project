import tkinter as tk
from tkinter import messagebox
import psycopg2

def execute_sql():
    try:
        # 获取用户输入的 SQL 命令
        sql_command = sql_text.get("1.0", tk.END).strip()

        if not sql_command:
            messagebox.showwarning("Input Error", "Please enter an SQL command.")
            return

        # 连接数据库
        conn = psycopg2.connect(
            database="db_test",
            user="user_test",
            password="DBlab@123456",
            host="120.46.137.179",
            port="5432"
        )
        cur = conn.cursor()

        # 执行 SQL 命令
        cur.execute(sql_command)

        # 如果是查询命令，获取并显示结果
        if sql_command.strip().lower().startswith("select"):
            rows = cur.fetchall()
            result_text.delete(1.0, tk.END)
            for row in rows:
                result_text.insert(tk.END, str(row) + "\n")
        else:
            conn.commit()
            result_text.delete(1.0, tk.END)
            result_text.insert(tk.END, f"SQL command executed successfully.\nAffected rows: {cur.rowcount}")

        # 关闭连接
        cur.close()
        conn.close()

    except Exception as e:
        messagebox.showerror("Error", f"An error occurred: {e}")

# 设置 Tkinter 窗口
root = tk.Tk()
root.title("PostgreSQL Database GUI")
root.geometry("600x500")

# SQL 输入框标签
sql_label = tk.Label(root, text="Enter SQL Command:")
sql_label.pack(pady=10)

# 多行输入框
sql_text = tk.Text(root, height=6, width=70)
sql_text.pack(pady=5)

# 执行按钮
execute_button = tk.Button(root, text="Execute SQL", command=execute_sql)
execute_button.pack(pady=10)

# 查询结果文本框
result_label = tk.Label(root, text="Execution Results:")
result_label.pack(pady=10)

result_text = tk.Text(root, height=10, width=70)
result_text.pack(pady=5)

# 启动 GUI
root.mainloop()
