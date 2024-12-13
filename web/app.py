# TODO: AI 网页 markdown 显示

from flask import Flask, render_template, request, jsonify
import psycopg2
from psycopg2 import sql
import json
from langchain import PromptTemplate, LLMChain
from langchain.memory import ConversationBufferMemory
from langchain_openai import ChatOpenAI
import time

app = Flask(__name__)

# 数据库连接配置
DB_CONFIG = {
    "database": "db_test",
    "user": "user_test",
    "password": "DBlab@123456",
    "host": "120.46.137.179",
    "port": "5432"
}

# SQL 历史记录
history = []
history_limit = 5  # 默认最大历史记录行数

# 大模型对话历史记录
chat_history = []

# 创建大模型实例
# API_KEY = "sk-cYGAToFJ08JZAXb0FuNUV3cp9U79Yr3ayC42gwCMVHxaQ4Pt"
# API_URL = "https://chatapi.zjt66.top/v1/"
API_KEY = "sk-v8N6R9Vyb94UcYx7RRMPBtRoE3HDz9Oht6fZxsgikwUn51p4"
API_URL = "https://xiaoai.plus/v1/"

def create_model(temperature: float, streaming: bool = False):
    return ChatOpenAI(
        openai_api_key=API_KEY,
        openai_api_base=API_URL,
        temperature=temperature,
        model_name="gpt-4o-mini",
        streaming=streaming,
    )


model = create_model(temperature=0.8, streaming=False)
memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
prompt = PromptTemplate(
    input_variables=["question", "chat_history"],
    template=(
        "The user is asking:\n\n"
        "{question}\n\n"
        "This is the conversation history:\n\n"
        "{chat_history}\n\n"
        "Provide an accurate and helpful response."
    ),
)
conversation = LLMChain(llm=model, prompt=prompt, memory=memory, verbose=False)


def format_query_result(rows, columns):
    """格式化查询结果"""
    if not rows:
        return "No rows selected."
    output = []
    output.append(' | '.join(columns))
    output.append('-' * len(output[-1]))
    for row in rows:
        output.append(' | '.join(str(cell) for cell in row))
    return "\n".join(output)


def execute_sql_command(command):
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute(command)
        if command.strip().lower().startswith("select"):
            rows = cur.fetchall()
            columns = [desc[0] for desc in cur.description]
            result = format_query_result(rows, columns)
        else:
            conn.commit()
            result = f"{command.strip()} executed successfully. Affected rows: {cur.rowcount}"
        cur.close()
        conn.close()
        return {"status": "success", "message": result}
    except Exception as e:
        return {"status": "error", "message": str(e)}


def add_to_history(sql_command, result):
    global history
    history.append({"sql": sql_command, "result": result})
    if len(history) > history_limit:
        history.pop(0)


@app.route("/")
def index():
    return render_template("index.html", history=history, chat_history=chat_history, history_limit=history_limit)


@app.route("/execute_sql", methods=["POST"])
def execute_sql():
    sql_command = request.form["sql_command"]
    result = execute_sql_command(sql_command)
    add_to_history(sql_command, result)
    return jsonify(result)


@app.route("/set_history_limit", methods=["POST"])
def set_history_limit():
    global history_limit
    try:
        history_limit = int(request.form["history_limit"])
        return jsonify({"status": "success", "message": f"History limit set to {history_limit}"})
    except ValueError:
        return jsonify({"status": "error", "message": "Invalid history limit value"})


@app.route("/ask_model", methods=["POST"])
def ask_model():
    global chat_history
    question = request.form["question"]
    try:
        response = conversation.predict(question=question)
        chat_history.append({"question": question, "response": response})
        if len(chat_history) > history_limit:
            chat_history.pop(0)
        return jsonify({"status": "success", "response": response})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})


if __name__ == "__main__":
    app.run(debug=True)
    