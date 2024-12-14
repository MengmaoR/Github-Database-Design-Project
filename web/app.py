from flask import Flask, render_template, request, jsonify
import psycopg2
from psycopg2 import sql
from langchain import PromptTemplate, LLMChain
from langchain.memory import ConversationBufferMemory
from langchain_openai import ChatOpenAI

app = Flask(__name__)

# 用于存储历史记录
sql_history = []
ai_history = []

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

# 创建大模型实例
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
        "You're now an expert in database management and openGauss. "
        "The user is asking:\n\n"
        "{question}\n\n"
        "The database is based on openGauss\n\n"
        "This is the conversation history:\n\n"
        "{chat_history}\n\n"
        "Provide an accurate and helpful response, and give user the sql command to execute.\n\n"
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
        print(f"try connect to database: {DB_CONFIG}")
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

@app.route("/")
def index():
    return render_template("index.html", sql_history=sql_history, ai_history=ai_history)

@app.route("/execute_sql", methods=["POST"])
def execute_sql():
    sql_command = request.form["sql_command"]
    result = execute_sql_command(sql_command)
    
    # 保存 SQL 历史记录
    sql_history.append({"sql": sql_command, "result": result['message']})
    return jsonify(result)

@app.route("/ask_model", methods=["POST"])
def ask_model():
    question = request.form["question"]
    try:
        response = conversation.predict(question=question)
        
        # 保存 AI 聊天历史记录
        ai_history.append({"user": question, "ai": response})
        
        return jsonify({"status": "success", "response": response})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route("/clear_sql_history", methods=["POST"])
def clear_sql_history():
    global sql_history
    sql_history = []  # Clear the SQL history
    return jsonify({"status": "success"})

@app.route("/clear_ai_history", methods=["POST"])
def clear_ai_history():
    global ai_history
    ai_history = []  # Clear the AI history
    return jsonify({"status": "success"})

if __name__ == "__main__":
    app.run(debug=True)
    