from flask import Flask, render_template, request, jsonify
from dotenv import load_dotenv
import os
import time
from langchain_groq import ChatGroq
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate
from langchain.chains import create_retrieval_chain
from langchain_community.vectorstores import FAISS
from langchain_community.document_loaders import PyPDFDirectoryLoader
from langchain_google_genai import GoogleGenerativeAIEmbeddings

app = Flask(__name__)

load_dotenv()

# Load environment variables
groq_api_key = os.getenv('GROQ_API_KEY')
google_api_key = os.getenv('GOOGLE_API_KEY')

# Initialize session state variables
def initialize_session_state():
    if not hasattr(initialize_session_state, 'vectors'):
        initialize_session_state.embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
        initialize_session_state.loader = PyPDFDirectoryLoader("./pdfFiles")  # Data Ingestion
        initialize_session_state.docs = initialize_session_state.loader.load()  # Document Loading
        initialize_session_state.text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)  # Chunk Creation
        initialize_session_state.final_documents = initialize_session_state.text_splitter.split_documents(initialize_session_state.docs[:20])  # Splitting
        initialize_session_state.vectors = FAISS.from_documents(initialize_session_state.final_documents, initialize_session_state.embeddings)  # Vector creation

llm = ChatGroq(groq_api_key=groq_api_key, model_name="gemma-7b-it")

prompt = ChatPromptTemplate.from_template(
    """
    Answer the questions based on the provided context only.
    Please provide the most accurate response based on the question
    <context>
        {context}
    <context>
    Questions:{input}
    """
)

def retrieve_documents(input_prompt):
    initialize_session_state()

    # Create document chain and retrieval chain
    document_chain = create_stuff_documents_chain(llm, prompt)
    retriever = initialize_session_state.vectors.as_retriever()
    retrieval_chain = create_retrieval_chain(retriever, document_chain)

    # Measure response time
    start = time.process_time()
    response = retrieval_chain.invoke({'input': input_prompt})
    response_time = time.process_time() - start

    return {
        'response_time': response_time,
        'answer': response['answer'],
        'context': [doc.page_content for doc in response["context"]]
    }

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    input_prompt = data.get('message', '')

    if input_prompt:
        response = retrieve_documents(input_prompt)
        return jsonify({
            'answer': response['answer'],
            'response_time': response['response_time'],
            'context': response['context']
        })
    return jsonify({'answer': 'No input provided.'})

if __name__ == "__main__":
    app.run(debug=True)
