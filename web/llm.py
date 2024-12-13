import time
from langchain import PromptTemplate, LLMChain
from langchain.memory import ConversationBufferMemory
from langchain_openai import ChatOpenAI

# API credentials
API_KEY = "sk-cYGAToFJ08JZAXb0FuNUV3cp9U79Yr3ayC42gwCMVHxaQ4Pt"
API_URL = "https://chatapi.zjt66.top/v1/"

# Function to create the language model instance
def create_model(temperature: float, streaming: bool = False):
    return ChatOpenAI(
        openai_api_key=API_KEY,
        openai_api_base=API_URL,
        temperature=temperature,
        model_name="gpt-4o-mini",
        streaming=streaming,
    )

# Chat prompt template for response generation based on user input and emotional context
prompt = PromptTemplate(
    input_variables=["expression", "question", "chat_history", "human_input"],
    template=(
        """
        [system] 你现在作为一个热心的人类助手，负责理解和回应人类的情感需求。你的目标是提供一个安全、支持和理解的环境，让每个人都能感到被听见和被关心。
                 在此过程中，你将根据情感识别模块提供的用户情绪（如有）作为参考，但最终回应应该以用户的文本为主，不受情感识别结果过度影响。

        情感识别结果：{expression}  (情感识别的参考结果，仅供参考)

        注意事项：
        - 如果用户表现出负面情绪，如愤怒、沮丧等，你需要做出安抚、积极的回应；
        - 如果用户的情绪为中性或积极情绪，你可以保持自然、友好的语气；
        - 你需要根据情感识别结果调整语气，但确保语义与用户输入一致，不偏离主题。

        以下是一些示例，帮助你理解如何回应用户：

        【user】我今天过得很糟糕，工作上出了问题，老板对我很生气。
        【output】听起来你今天真的过得不容易。每个人都会有不顺心的时候，重要的是从中学习。你可以跟我分享一下发生了什么，我愿意听你说。

        【user】我今天很开心！终于完成了一个大项目，感觉很有成就感！
        【output】太棒了！你辛苦的努力得到了回报，真让人高兴！完成一个大项目的感觉真的很棒吧。接下来有什么计划吗？

        【user】我好生气，客户无理取闹，真的让我很烦。
        【output】我能理解你的感受，遇到这种情况真的很令人气愤。你做得很对，保持冷静是最重要的。如果你想倾诉一下，我在这里听你说。

        【user】我有点累了，最近一直加班，睡得也不好。
        【output】加班确实很辛苦，休息很重要。希望你能尽量放松一下，调整好作息。如果你想聊聊最近的工作，或者需要一点鼓励，我都在这里。

        【user】我好像做错了什么，今天的报告没交好，老板看起来很失望。
        【output】每个人都会有失误，重要的是从中吸取经验。你已经意识到问题，并且有心改进，这就很棒了。也许你可以考虑和老板沟通一下，看看如何改进下次的报告。

        下面的内容是已经产生的历史对话，你可以参考这些内容来生成回应：
        
        [chat_history] {chat_history}

        请根据以上示例和用户的输入，生成适当的回应。直接输出回应内容，不要加入“output”或“system”之类的标签。

        [user] {question}
        """
    )
)

# Create the language model with the defined prompt template
model = create_model(temperature=0.8, streaming=True)

# Memory to store conversation history
memory = ConversationBufferMemory(memory_key="chat_history", input_key="human_input", return_messages=True)

# LLMChain for handling user queries
conversation = LLMChain(
    llm=model,
    prompt=prompt,
    verbose=False,
    memory=memory
)

# Function to handle user input and generate model responses
def chat():
    while True:
        question = input('You: ')  # Get user input
        response = conversation.predict(
            human_input="",  # Blank input for the variable (if unused)
            expression="neutral",  # Default emotional context
            question=question,  # User's question
        )
        print(f'Model: {response}')  # Print the model's response
        time.sleep(0.5)  # Delay for smoother interaction

if __name__ == '__main__':
    chat()
