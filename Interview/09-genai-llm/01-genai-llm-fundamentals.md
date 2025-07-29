# GenAI/LLM Fundamentals

## Table of Contents
1. [Overview](#overview)
2. [LangChain Framework](#langchain-framework)
3. [Prompt Engineering](#prompt-engineering)
4. [Retrieval-Augmented Generation (RAG)](#retrieval-augmented-generation-rag)
5. [LLM Evaluation & Testing](#llm-evaluation--testing)
6. [Safety & Guardrails](#safety--guardrails)
7. [Vector Databases](#vector-databases)
8. [Fine-tuning & Training](#fine-tuning--training)
9. [Production Deployment](#production-deployment)
10. [Interview Questions & Answers](#interview-questions--answers)

## Overview

Generative AI and Large Language Models (LLMs) are transforming software development and user experiences. Key concepts include:

- **Foundation Models**: Pre-trained models like GPT, Claude, LLaMA
- **Prompt Engineering**: Crafting effective inputs to guide model behavior
- **RAG**: Combining retrieval systems with generation for up-to-date, factual responses
- **Fine-tuning**: Adapting models for specific tasks or domains
- **Safety**: Implementing guardrails and content filtering

## LangChain Framework

### Basic LangChain Implementation

```python
import os
from typing import List, Dict, Any, Optional
from langchain.llms import OpenAI
from langchain.chat_models import ChatOpenAI
from langchain.prompts import PromptTemplate, ChatPromptTemplate
from langchain.chains import LLMChain, SimpleSequentialChain
from langchain.memory import ConversationBufferMemory, ConversationSummaryMemory
from langchain.callbacks import StdOutCallbackHandler
from langchain.schema import BaseOutputParser
from langchain.agents import Tool, AgentExecutor, create_react_agent
from langchain.tools import DuckDuckGoSearchRun
import json

# Set up OpenAI API key
# os.environ["OPENAI_API_KEY"] = "your-api-key"

class JsonOutputParser(BaseOutputParser):
    """Parse LLM output into JSON"""
    
    def parse(self, text: str) -> Dict[str, Any]:
        try:
            # Extract JSON from the response
            start = text.find('{')
            end = text.rfind('}') + 1
            if start != -1 and end != 0:
                json_str = text[start:end]
                return json.loads(json_str)
            else:
                return {"error": "No valid JSON found", "raw_text": text}
        except json.JSONDecodeError:
            return {"error": "Invalid JSON", "raw_text": text}

class LangChainExample:
    def __init__(self):
        self.llm = ChatOpenAI(
            temperature=0.7,
            model="gpt-3.5-turbo",
            max_tokens=500
        )
        self.memory = ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True
        )
    
    def basic_completion(self, prompt: str) -> str:
        """Simple LLM completion"""
        response = self.llm.predict(prompt)
        return response
    
    def templated_prompt(self, template: str, **kwargs) -> str:
        """Use prompt template with variables"""
        prompt = PromptTemplate(
            input_variables=list(kwargs.keys()),
            template=template
        )
        
        chain = LLMChain(llm=self.llm, prompt=prompt)
        response = chain.run(**kwargs)
        return response
    
    def conversational_chain(self, user_input: str) -> str:
        """Conversation with memory"""
        prompt = ChatPromptTemplate.from_messages([
            ("system", "You are a helpful AI assistant. Keep track of our conversation context."),
            ("human", "{input}")
        ])
        
        chain = LLMChain(
            llm=self.llm,
            prompt=prompt,
            memory=self.memory
        )
        
        response = chain.run(input=user_input)
        return response
    
    def structured_output_chain(self, user_query: str) -> Dict[str, Any]:
        """Generate structured JSON output"""
        template = """
        You are a data extraction expert. Extract the following information from the user query:
        - intent: The main purpose/intent of the query
        - entities: Important entities mentioned (people, places, dates, etc.)
        - sentiment: Positive, negative, or neutral
        - confidence: Your confidence level (0-1)
        
        User Query: {query}
        
        Return your response as a valid JSON object with the above fields.
        """
        
        prompt = PromptTemplate(
            input_variables=["query"],
            template=template
        )
        
        chain = LLMChain(
            llm=self.llm,
            prompt=prompt,
            output_parser=JsonOutputParser()
        )
        
        response = chain.run(query=user_query)
        return response

class CustomAgent:
    """Custom agent with tools"""
    
    def __init__(self):
        self.llm = ChatOpenAI(temperature=0)
        self.tools = self._setup_tools()
        self.agent = self._create_agent()
    
    def _setup_tools(self) -> List[Tool]:
        """Setup available tools for the agent"""
        
        def calculator(expression: str) -> str:
            """Calculate mathematical expressions"""
            try:
                result = eval(expression)  # Note: Use ast.literal_eval in production
                return f"The result is: {result}"
            except Exception as e:
                return f"Error calculating {expression}: {e}"
        
        def text_analyzer(text: str) -> str:
            """Analyze text for word count, character count, etc."""
            words = len(text.split())
            chars = len(text)
            lines = len(text.split('\n'))
            return f"Text analysis: {words} words, {chars} characters, {lines} lines"
        
        search_tool = DuckDuckGoSearchRun()
        
        return [
            Tool(
                name="Calculator",
                func=calculator,
                description="Useful for mathematical calculations. Input should be a valid mathematical expression."
            ),
            Tool(
                name="TextAnalyzer",
                func=text_analyzer,
                description="Analyze text for word count, character count, and line count."
            ),
            Tool(
                name="Search",
                func=search_tool.run,
                description="Search the internet for current information."
            )
        ]
    
    def _create_agent(self):
        """Create ReAct agent"""
        prompt_template = """
        You are a helpful assistant with access to tools. Use the following format:

        Question: the input question you must answer
        Thought: you should always think about what to do
        Action: the action to take, should be one of [{tool_names}]
        Action Input: the input to the action
        Observation: the result of the action
        ... (this Thought/Action/Action Input/Observation can repeat N times)
        Thought: I now know the final answer
        Final Answer: the final answer to the original input question

        Question: {input}
        Thought: {agent_scratchpad}
        """
        
        agent = create_react_agent(
            llm=self.llm,
            tools=self.tools,
            prompt=PromptTemplate.from_template(prompt_template)
        )
        
        return AgentExecutor(
            agent=agent,
            tools=self.tools,
            verbose=True,
            max_iterations=5
        )
    
    def run(self, query: str) -> str:
        """Run agent with query"""
        try:
            response = self.agent.invoke({"input": query})
            return response["output"]
        except Exception as e:
            return f"Error running agent: {e}"

# Sequential chain example
class DocumentProcessor:
    def __init__(self):
        self.llm = ChatOpenAI(temperature=0.3)
    
    def process_document(self, text: str) -> Dict[str, str]:
        """Process document through multiple chains"""
        
        # Chain 1: Summarize
        summary_prompt = PromptTemplate(
            input_variables=["text"],
            template="Summarize the following text in 2-3 sentences:\n\n{text}"
        )
        summary_chain = LLMChain(llm=self.llm, prompt=summary_prompt)
        
        # Chain 2: Extract key points
        keypoints_prompt = PromptTemplate(
            input_variables=["summary"],
            template="Extract 3-5 key points from this summary:\n\n{summary}"
        )
        keypoints_chain = LLMChain(llm=self.llm, prompt=keypoints_prompt)
        
        # Chain 3: Generate action items
        actions_prompt = PromptTemplate(
            input_variables=["keypoints"],
            template="Based on these key points, suggest 2-3 action items:\n\n{keypoints}"
        )
        actions_chain = LLMChain(llm=self.llm, prompt=actions_prompt)
        
        # Create sequential chain
        overall_chain = SimpleSequentialChain(
            chains=[summary_chain, keypoints_chain, actions_chain],
            verbose=True
        )
        
        # Process
        summary = summary_chain.run(text=text)
        keypoints = keypoints_chain.run(summary=summary)
        actions = actions_chain.run(keypoints=keypoints)
        
        return {
            "original_text": text,
            "summary": summary,
            "key_points": keypoints,
            "action_items": actions
        }

# Example usage
async def langchain_examples():
    lc = LangChainExample()
    
    # Basic completion
    response = lc.basic_completion("Explain quantum computing in simple terms")
    print("Basic completion:", response)
    
    # Templated prompt
    template = "Write a {style} email about {topic} to {audience}"
    email = lc.templated_prompt(
        template,
        style="professional",
        topic="project deadline",
        audience="team members"
    )
    print("Templated email:", email)
    
    # Conversational
    conv1 = lc.conversational_chain("Hello, I'm working on a Python project")
    print("Conversation 1:", conv1)
    
    conv2 = lc.conversational_chain("Can you help me with error handling?")
    print("Conversation 2:", conv2)
    
    # Structured output
    structured = lc.structured_output_chain("I'm really frustrated with this slow computer!")
    print("Structured output:", structured)
    
    # Agent example
    agent = CustomAgent()
    agent_response = agent.run("What is 25 * 37 + 100? Also analyze the word count of this sentence.")
    print("Agent response:", agent_response)
```

## Prompt Engineering

### Advanced Prompt Engineering Techniques

```python
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from enum import Enum

class PromptType(Enum):
    ZERO_SHOT = "zero_shot"
    FEW_SHOT = "few_shot"
    CHAIN_OF_THOUGHT = "chain_of_thought"
    TREE_OF_THOUGHT = "tree_of_thought"
    ROLE_PLAYING = "role_playing"

@dataclass
class PromptExample:
    input: str
    output: str
    explanation: Optional[str] = None

class PromptEngineer:
    """Advanced prompt engineering techniques"""
    
    def __init__(self, llm):
        self.llm = llm
    
    def zero_shot_prompt(self, task: str, context: str = "") -> str:
        """Simple direct prompting"""
        prompt = f"""
        Task: {task}
        {f"Context: {context}" if context else ""}
        
        Please provide a clear and accurate response.
        """
        return prompt.strip()
    
    def few_shot_prompt(self, task: str, examples: List[PromptExample], 
                       new_input: str) -> str:
        """Few-shot learning with examples"""
        prompt = f"Task: {task}\n\nExamples:\n"
        
        for i, example in enumerate(examples, 1):
            prompt += f"\nExample {i}:\n"
            prompt += f"Input: {example.input}\n"
            prompt += f"Output: {example.output}\n"
            if example.explanation:
                prompt += f"Explanation: {example.explanation}\n"
        
        prompt += f"\nNow solve this:\nInput: {new_input}\nOutput:"
        return prompt
    
    def chain_of_thought_prompt(self, problem: str, domain: str = "") -> str:
        """Chain of thought reasoning"""
        prompt = f"""
        Problem: {problem}
        {f"Domain: {domain}" if domain else ""}
        
        Let's solve this step by step:
        
        Step 1: First, let me understand what we're being asked to do.
        Step 2: Then, I'll identify the key information and constraints.
        Step 3: Next, I'll work through the logic systematically.
        Step 4: Finally, I'll provide the answer with reasoning.
        
        Let me work through this:
        """
        return prompt.strip()
    
    def role_playing_prompt(self, role: str, task: str, context: str = "") -> str:
        """Role-based prompting"""
        prompt = f"""
        You are a {role}. {context}
        
        Your task: {task}
        
        Please respond in character, using your expertise and perspective as a {role}.
        Consider the specific knowledge, vocabulary, and approach that a {role} would use.
        """
        return prompt.strip()
    
    def self_consistency_prompt(self, problem: str, num_attempts: int = 3) -> List[str]:
        """Generate multiple reasoning paths for consistency"""
        base_prompt = self.chain_of_thought_prompt(problem)
        
        variations = []
        for i in range(num_attempts):
            varied_prompt = f"""
            {base_prompt}
            
            Attempt {i+1}: Please solve this using a different approach or reasoning path.
            """
            variations.append(varied_prompt)
        
        return variations
    
    def instruction_tuned_prompt(self, instruction: str, input_data: str,
                               format_spec: str = "") -> str:
        """Instruction-following format"""
        prompt = f"""
        ### Instruction:
        {instruction}
        
        ### Input:
        {input_data}
        
        {f"### Format: {format_spec}" if format_spec else ""}
        
        ### Response:
        """
        return prompt.strip()

class PromptOptimizer:
    """Optimize prompts for better performance"""
    
    def __init__(self, llm):
        self.llm = llm
    
    def test_prompt_variations(self, base_prompt: str, variations: List[str],
                             test_inputs: List[str]) -> Dict[str, Dict]:
        """Test different prompt variations"""
        results = {}
        
        for i, variation in enumerate([base_prompt] + variations):
            results[f"variation_{i}"] = {
                "prompt": variation,
                "results": []
            }
            
            for test_input in test_inputs:
                full_prompt = f"{variation}\n\nInput: {test_input}\nOutput:"
                # response = self.llm.predict(full_prompt)
                response = f"Mock response for variation {i}"  # Placeholder
                
                results[f"variation_{i}"]["results"].append({
                    "input": test_input,
                    "output": response
                })
        
        return results
    
    def optimize_prompt_length(self, prompt: str, target_length: int = 500) -> str:
        """Optimize prompt length while preserving meaning"""
        if len(prompt) <= target_length:
            return prompt
        
        # Simple optimization: remove redundant words and phrases
        optimized = prompt
        
        # Remove redundant phrases
        redundant_phrases = [
            "please note that",
            "it's important to",
            "keep in mind that",
            "make sure to",
            "don't forget to"
        ]
        
        for phrase in redundant_phrases:
            optimized = optimized.replace(phrase, "")
        
        # Consolidate multiple spaces
        optimized = " ".join(optimized.split())
        
        return optimized
    
    def add_safety_guidelines(self, prompt: str) -> str:
        """Add safety guidelines to prompts"""
        safety_prefix = """
        Please ensure your response is helpful, harmless, and honest. 
        Avoid generating content that is offensive, biased, or potentially harmful.
        If you're unsure about something, please say so rather than guessing.
        
        """
        
        return safety_prefix + prompt

# Specialized prompt templates
class CodePromptTemplates:
    """Templates for code-related tasks"""
    
    @staticmethod
    def code_review_prompt(code: str, language: str) -> str:
        return f"""
        Please review the following {language} code and provide feedback on:
        1. Code quality and best practices
        2. Potential bugs or issues
        3. Performance considerations
        4. Security concerns
        5. Suggestions for improvement
        
        Code:
        ```{language}
        {code}
        ```
        
        Please structure your review with clear sections and specific recommendations.
        """
    
    @staticmethod
    def code_explanation_prompt(code: str, language: str, audience: str = "beginner") -> str:
        return f"""
        Explain the following {language} code to a {audience} programmer.
        Break down what each part does and explain any complex concepts.
        
        Code:
        ```{language}
        {code}
        ```
        
        Please provide:
        1. Overall purpose of the code
        2. Step-by-step explanation
        3. Key concepts used
        4. Example of how it works
        """
    
    @staticmethod
    def debugging_prompt(code: str, error_message: str, language: str) -> str:
        return f"""
        I'm getting an error in my {language} code. Please help me debug it.
        
        Code:
        ```{language}
        {code}
        ```
        
        Error message:
        ```
        {error_message}
        ```
        
        Please:
        1. Identify the root cause of the error
        2. Explain why this error occurred
        3. Provide a corrected version of the code
        4. Suggest how to prevent similar errors in the future
        """

class DataAnalysisPrompts:
    """Templates for data analysis tasks"""
    
    @staticmethod
    def data_analysis_prompt(data_description: str, question: str) -> str:
        return f"""
        I have a dataset with the following characteristics:
        {data_description}
        
        Question: {question}
        
        Please provide:
        1. Suggested analysis approach
        2. Appropriate visualization methods
        3. Statistical tests to consider
        4. Potential insights to look for
        5. Python code example using pandas/matplotlib
        """
    
    @staticmethod
    def ml_model_selection_prompt(problem_type: str, data_info: str, 
                                 constraints: str = "") -> str:
        return f"""
        I need to build a machine learning model for the following problem:
        
        Problem type: {problem_type}
        Data information: {data_info}
        {f"Constraints: {constraints}" if constraints else ""}
        
        Please recommend:
        1. Suitable algorithms for this problem
        2. Data preprocessing steps
        3. Feature engineering techniques
        4. Evaluation metrics to use
        5. Potential challenges and solutions
        """

# Example usage
def prompt_engineering_examples():
    # Mock LLM for demonstration
    class MockLLM:
        def predict(self, prompt):
            return f"Mock response to: {prompt[:100]}..."
    
    llm = MockLLM()
    engineer = PromptEngineer(llm)
    
    # Zero-shot example
    zero_shot = engineer.zero_shot_prompt(
        "Classify the sentiment of this text",
        "Customer service response classification"
    )
    print("Zero-shot prompt:", zero_shot)
    
    # Few-shot example
    examples = [
        PromptExample("I love this product!", "Positive", "Expresses clear satisfaction"),
        PromptExample("This is terrible quality", "Negative", "Indicates dissatisfaction"),
        PromptExample("It's okay, nothing special", "Neutral", "Lukewarm response")
    ]
    
    few_shot = engineer.few_shot_prompt(
        "Classify sentiment",
        examples,
        "The delivery was fast but packaging was poor"
    )
    print("Few-shot prompt:", few_shot)
    
    # Chain of thought
    cot = engineer.chain_of_thought_prompt(
        "If a train travels 120 miles in 2 hours, and then 180 miles in 3 hours, what's the average speed?",
        "Physics/Math"
    )
    print("Chain of thought prompt:", cot)
    
    # Role playing
    role_prompt = engineer.role_playing_prompt(
        "senior software architect",
        "Design a microservices architecture for an e-commerce platform",
        "You have 10+ years of experience building scalable systems"
    )
    print("Role playing prompt:", role_prompt)
    
    # Code-specific prompts
    code_review = CodePromptTemplates.code_review_prompt(
        "def factorial(n):\n    if n <= 1: return 1\n    return n * factorial(n-1)",
        "Python"
    )
    print("Code review prompt:", code_review)

# Run examples
# prompt_engineering_examples()
```

## Retrieval-Augmented Generation (RAG)

### Complete RAG Implementation

```python
import numpy as np
import faiss
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
import json
import pickle
from sentence_transformers import SentenceTransformer
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.document_loaders import TextLoader, PyPDFLoader, WebBaseLoader
from langchain.embeddings import OpenAIEmbeddings, HuggingFaceEmbeddings
from langchain.vectorstores import FAISS, Chroma
from langchain.retrievers import BM25Retriever
import chromadb
from sklearn.metrics.pairwise import cosine_similarity

@dataclass
class Document:
    content: str
    metadata: Dict[str, Any]
    embedding: Optional[np.ndarray] = None
    id: Optional[str] = None

class VectorStore:
    """Custom vector store implementation"""
    
    def __init__(self, embedding_model: str = "all-MiniLM-L6-v2"):
        self.embedding_model = SentenceTransformer(embedding_model)
        self.documents: List[Document] = []
        self.index = None
        self.dimension = None
    
    def add_documents(self, documents: List[Document]):
        """Add documents to the vector store"""
        for doc in documents:
            if doc.embedding is None:
                doc.embedding = self.embedding_model.encode(doc.content)
            self.documents.append(doc)
        
        self._build_index()
    
    def _build_index(self):
        """Build FAISS index from document embeddings"""
        if not self.documents:
            return
        
        embeddings = np.array([doc.embedding for doc in self.documents])
        self.dimension = embeddings.shape[1]
        
        # Create FAISS index
        self.index = faiss.IndexFlatIP(self.dimension)  # Inner product for cosine similarity
        
        # Normalize embeddings for cosine similarity
        faiss.normalize_L2(embeddings)
        self.index.add(embeddings)
    
    def similarity_search(self, query: str, k: int = 5, threshold: float = 0.7) -> List[Tuple[Document, float]]:
        """Search for similar documents"""
        if not self.index:
            return []
        
        # Encode query
        query_embedding = self.embedding_model.encode([query])
        faiss.normalize_L2(query_embedding)
        
        # Search
        scores, indices = self.index.search(query_embedding, k)
        
        results = []
        for score, idx in zip(scores[0], indices[0]):
            if score >= threshold:
                results.append((self.documents[idx], float(score)))
        
        return results
    
    def save(self, filepath: str):
        """Save vector store to disk"""
        data = {
            'documents': self.documents,
            'dimension': self.dimension
        }
        
        with open(filepath, 'wb') as f:
            pickle.dump(data, f)
        
        if self.index:
            faiss.write_index(self.index, f"{filepath}.index")
    
    def load(self, filepath: str):
        """Load vector store from disk"""
        with open(filepath, 'rb') as f:
            data = pickle.load(f)
        
        self.documents = data['documents']
        self.dimension = data['dimension']
        
        try:
            self.index = faiss.read_index(f"{filepath}.index")
        except:
            self._build_index()

class DocumentProcessor:
    """Process and chunk documents for RAG"""
    
    def __init__(self, chunk_size: int = 1000, chunk_overlap: int = 200):
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap,
            separators=["\n\n", "\n", " ", ""]
        )
    
    def process_text(self, text: str, metadata: Dict[str, Any] = None) -> List[Document]:
        """Process text into chunks"""
        chunks = self.text_splitter.split_text(text)
        documents = []
        
        for i, chunk in enumerate(chunks):
            doc_metadata = metadata.copy() if metadata else {}
            doc_metadata.update({
                'chunk_id': i,
                'chunk_size': len(chunk),
                'total_chunks': len(chunks)
            })
            
            documents.append(Document(
                content=chunk,
                metadata=doc_metadata,
                id=f"{metadata.get('source', 'unknown')}_{i}"
            ))
        
        return documents
    
    def process_file(self, filepath: str) -> List[Document]:
        """Process file based on extension"""
        if filepath.endswith('.txt'):
            loader = TextLoader(filepath)
        elif filepath.endswith('.pdf'):
            loader = PyPDFLoader(filepath)
        else:
            raise ValueError(f"Unsupported file type: {filepath}")
        
        documents = loader.load()
        processed_docs = []
        
        for doc in documents:
            chunks = self.process_text(
                doc.page_content,
                {'source': filepath, **doc.metadata}
            )
            processed_docs.extend(chunks)
        
        return processed_docs

class HybridRetriever:
    """Hybrid retrieval combining vector search and keyword search"""
    
    def __init__(self, vector_store: VectorStore, documents: List[Document],
                 vector_weight: float = 0.7):
        self.vector_store = vector_store
        self.vector_weight = vector_weight
        self.keyword_weight = 1 - vector_weight
        
        # Create BM25 retriever for keyword search
        texts = [doc.content for doc in documents]
        self.bm25_retriever = BM25Retriever.from_texts(texts)
        self.bm25_retriever.k = 10
    
    def retrieve(self, query: str, k: int = 5) -> List[Tuple[Document, float]]:
        """Hybrid retrieval combining vector and keyword search"""
        
        # Vector search
        vector_results = self.vector_store.similarity_search(query, k=k*2)
        
        # Keyword search
        keyword_docs = self.bm25_retriever.get_relevant_documents(query)
        
        # Combine and rerank results
        all_results = {}
        
        # Add vector search results
        for doc, score in vector_results:
            doc_id = doc.id or doc.content[:50]
            all_results[doc_id] = {
                'document': doc,
                'vector_score': score,
                'keyword_score': 0.0
            }
        
        # Add keyword search results
        for i, doc in enumerate(keyword_docs[:k*2]):
            # Create a simple keyword score based on position
            keyword_score = 1.0 - (i / len(keyword_docs))
            doc_id = doc.page_content[:50]  # Simple ID based on content
            
            if doc_id in all_results:
                all_results[doc_id]['keyword_score'] = keyword_score
            else:
                # Find matching document in vector store
                matching_doc = None
                for vector_doc in self.vector_store.documents:
                    if vector_doc.content.startswith(doc.page_content[:50]):
                        matching_doc = vector_doc
                        break
                
                if matching_doc:
                    all_results[doc_id] = {
                        'document': matching_doc,
                        'vector_score': 0.0,
                        'keyword_score': keyword_score
                    }
        
        # Calculate hybrid scores and sort
        final_results = []
        for result in all_results.values():
            hybrid_score = (
                self.vector_weight * result['vector_score'] +
                self.keyword_weight * result['keyword_score']
            )
            final_results.append((result['document'], hybrid_score))
        
        final_results.sort(key=lambda x: x[1], reverse=True)
        return final_results[:k]

class RAGSystem:
    """Complete RAG system implementation"""
    
    def __init__(self, llm, embedding_model: str = "all-MiniLM-L6-v2"):
        self.llm = llm
        self.vector_store = VectorStore(embedding_model)
        self.document_processor = DocumentProcessor()
        self.retriever = None
    
    def add_documents(self, documents: List[str], metadata_list: List[Dict] = None):
        """Add documents to the knowledge base"""
        if metadata_list is None:
            metadata_list = [{}] * len(documents)
        
        processed_docs = []
        for doc, metadata in zip(documents, metadata_list):
            chunks = self.document_processor.process_text(doc, metadata)
            processed_docs.extend(chunks)
        
        self.vector_store.add_documents(processed_docs)
        self.retriever = HybridRetriever(self.vector_store, processed_docs)
    
    def add_files(self, filepaths: List[str]):
        """Add files to the knowledge base"""
        processed_docs = []
        for filepath in filepaths:
            docs = self.document_processor.process_file(filepath)
            processed_docs.extend(docs)
        
        self.vector_store.add_documents(processed_docs)
        self.retriever = HybridRetriever(self.vector_store, processed_docs)
    
    def generate_answer(self, question: str, max_context_length: int = 4000) -> Dict[str, Any]:
        """Generate answer using RAG"""
        if not self.retriever:
            return {"answer": "No knowledge base available", "sources": []}
        
        # Retrieve relevant documents
        relevant_docs = self.retriever.retrieve(question, k=5)
        
        if not relevant_docs:
            return {"answer": "No relevant information found", "sources": []}
        
        # Prepare context
        context_parts = []
        sources = []
        current_length = 0
        
        for doc, score in relevant_docs:
            if current_length + len(doc.content) > max_context_length:
                break
            
            context_parts.append(f"Source: {doc.metadata.get('source', 'Unknown')}\n{doc.content}")
            sources.append({
                "content": doc.content[:200] + "..." if len(doc.content) > 200 else doc.content,
                "metadata": doc.metadata,
                "relevance_score": score
            })
            current_length += len(doc.content)
        
        context = "\n\n---\n\n".join(context_parts)
        
        # Generate prompt
        prompt = f"""
        Based on the following context, please answer the question. If the answer cannot be found in the context, please say so.
        
        Context:
        {context}
        
        Question: {question}
        
        Answer:
        """
        
        # Generate response
        answer = self.llm.predict(prompt) if hasattr(self.llm, 'predict') else "Mock answer based on context"
        
        return {
            "answer": answer,
            "sources": sources,
            "context_used": context,
            "question": question
        }
    
    def evaluate_retrieval(self, test_questions: List[str], 
                          expected_sources: List[List[str]]) -> Dict[str, float]:
        """Evaluate retrieval quality"""
        if not self.retriever:
            return {"error": "No retriever available"}
        
        total_recall = 0.0
        total_precision = 0.0
        
        for question, expected in zip(test_questions, expected_sources):
            retrieved_docs = self.retriever.retrieve(question, k=10)
            retrieved_sources = [doc.metadata.get('source', '') for doc, _ in retrieved_docs]
            
            # Calculate recall and precision
            retrieved_set = set(retrieved_sources)
            expected_set = set(expected)
            
            if expected_set:
                recall = len(retrieved_set.intersection(expected_set)) / len(expected_set)
                total_recall += recall
            
            if retrieved_set:
                precision = len(retrieved_set.intersection(expected_set)) / len(retrieved_set)
                total_precision += precision
        
        num_questions = len(test_questions)
        return {
            "average_recall": total_recall / num_questions,
            "average_precision": total_precision / num_questions,
            "f1_score": 2 * (total_recall * total_precision) / (total_recall + total_precision) if (total_recall + total_precision) > 0 else 0
        }

# Advanced RAG techniques
class AdvancedRAG(RAGSystem):
    """Advanced RAG with query rewriting and response fusion"""
    
    def __init__(self, llm, embedding_model: str = "all-MiniLM-L6-v2"):
        super().__init__(llm, embedding_model)
        self.query_rewriter = QueryRewriter(llm)
        self.response_fusion = ResponseFusion(llm)
    
    def generate_answer_advanced(self, question: str) -> Dict[str, Any]:
        """Generate answer with query rewriting and response fusion"""
        
        # Step 1: Rewrite query for better retrieval
        rewritten_queries = self.query_rewriter.rewrite_query(question)
        
        # Step 2: Retrieve for each query variant
        all_docs = []
        for query in rewritten_queries:
            docs = self.retriever.retrieve(query, k=3)
            all_docs.extend(docs)
        
        # Step 3: Deduplicate and rank
        unique_docs = self._deduplicate_documents(all_docs)
        
        # Step 4: Generate multiple candidate answers
        candidate_answers = []
        for i in range(min(3, len(rewritten_queries))):
            answer_data = self.generate_answer(rewritten_queries[i])
            candidate_answers.append(answer_data["answer"])
        
        # Step 5: Fuse responses
        final_answer = self.response_fusion.fuse_responses(question, candidate_answers)
        
        return {
            "answer": final_answer,
            "original_question": question,
            "rewritten_queries": rewritten_queries,
            "sources": [{"content": doc.content[:200], "score": score} for doc, score in unique_docs[:5]],
            "candidate_answers": candidate_answers
        }
    
    def _deduplicate_documents(self, docs: List[Tuple[Document, float]]) -> List[Tuple[Document, float]]:
        """Remove duplicate documents based on content similarity"""
        if not docs:
            return []
        
        unique_docs = [docs[0]]
        
        for doc, score in docs[1:]:
            is_duplicate = False
            for existing_doc, _ in unique_docs:
                # Simple similarity check (can be improved with embedding similarity)
                if self._text_similarity(doc.content, existing_doc.content) > 0.8:
                    is_duplicate = True
                    break
            
            if not is_duplicate:
                unique_docs.append((doc, score))
        
        return sorted(unique_docs, key=lambda x: x[1], reverse=True)
    
    def _text_similarity(self, text1: str, text2: str) -> float:
        """Calculate text similarity (simplified)"""
        words1 = set(text1.lower().split())
        words2 = set(text2.lower().split())
        
        intersection = words1.intersection(words2)
        union = words1.union(words2)
        
        return len(intersection) / len(union) if union else 0.0

class QueryRewriter:
    """Rewrite queries for better retrieval"""
    
    def __init__(self, llm):
        self.llm = llm
    
    def rewrite_query(self, query: str, num_variants: int = 3) -> List[str]:
        """Generate query variants for better retrieval"""
        prompt = f"""
        Given the following question, generate {num_variants} alternative ways to ask the same question.
        These alternatives should help retrieve more relevant information from a knowledge base.
        
        Original question: {query}
        
        Alternative questions:
        1.
        2.
        3.
        """
        
        # Mock response for demonstration
        variants = [
            query,  # Original
            f"What information is available about {query.lower()}?",
            f"Can you explain {query.lower()} in detail?"
        ]
        
        return variants

class ResponseFusion:
    """Fuse multiple candidate responses"""
    
    def __init__(self, llm):
        self.llm = llm
    
    def fuse_responses(self, question: str, candidate_answers: List[str]) -> str:
        """Combine multiple answers into a coherent response"""
        if len(candidate_answers) == 1:
            return candidate_answers[0]
        
        prompt = f"""
        Question: {question}
        
        I have multiple candidate answers to this question. Please synthesize them into a single, coherent, and comprehensive answer.
        
        Candidate answers:
        """
        
        for i, answer in enumerate(candidate_answers, 1):
            prompt += f"\nAnswer {i}: {answer}\n"
        
        prompt += "\nSynthesized answer:"
        
        # Mock fusion for demonstration
        return f"Based on multiple sources: {candidate_answers[0]}"

# Example usage
def rag_example():
    # Mock LLM
    class MockLLM:
        def predict(self, prompt):
            return "This is a mock response based on the provided context."
    
    # Create RAG system
    llm = MockLLM()
    rag = RAGSystem(llm)
    
    # Add sample documents
    documents = [
        "Python is a high-level programming language known for its simplicity and readability.",
        "Machine learning is a subset of artificial intelligence that enables computers to learn from data.",
        "Docker is a containerization platform that allows applications to run in isolated environments.",
        "Kubernetes is an orchestration platform for managing containerized applications at scale."
    ]
    
    metadata = [
        {"source": "python_guide.txt", "topic": "programming"},
        {"source": "ml_basics.txt", "topic": "machine_learning"},
        {"source": "docker_intro.txt", "topic": "containerization"},
        {"source": "k8s_overview.txt", "topic": "orchestration"}
    ]
    
    rag.add_documents(documents, metadata)
    
    # Generate answer
    result = rag.generate_answer("What is Python and why is it popular?")
    
    print("Question:", result["question"])
    print("Answer:", result["answer"])
    print("Sources:", [s["metadata"]["source"] for s in result["sources"]])

# Run example
# rag_example()
```

## Interview Questions and Answers

| # | Difficulty | Question | Answer |
|---|------------|----------|---------|
| 1 | Easy | What is generative AI? | AI systems that can create new content like text, images, code, audio |
| 2 | Easy | What is an LLM? | Large Language Model - neural network trained on vast text data |
| 3 | Easy | What is GPT? | Generative Pre-trained Transformer - architecture for language models |
| 4 | Easy | What is a prompt? | Input text given to AI model to generate desired output |
| 5 | Easy | What is prompt engineering? | Crafting effective prompts to get better AI responses |
| 6 | Easy | What is fine-tuning? | Adapting pre-trained model to specific task with additional training |
| 7 | Easy | What is temperature in AI? | Parameter controlling randomness in model outputs (0-2) |
| 8 | Easy | What is token? | Basic unit of text processing in language models |
| 9 | Easy | What is context window? | Maximum number of tokens model can process at once |
| 10 | Easy | What is embedding? | Vector representation of text capturing semantic meaning |
| 11 | Easy | What is transformer architecture? | Neural network design using attention mechanisms |
| 12 | Easy | What is attention mechanism? | Method for models to focus on relevant parts of input |
| 13 | Easy | What is RAG? | Retrieval-Augmented Generation - combining retrieval with generation |
| 14 | Easy | What is vector database? | Database optimized for storing and searching vector embeddings |
| 15 | Easy | What is LangChain? | Framework for building applications with language models |
| 16 | Medium | What is few-shot learning? | Teaching model through examples in prompt without training |
| 17 | Medium | What is zero-shot learning? | Model performing tasks without specific training examples |
| 18 | Medium | What is chain-of-thought prompting? | Encouraging model to show reasoning steps |
| 19 | Medium | What is hallucination in AI? | When model generates false or nonsensical information |
| 20 | Medium | What is model alignment? | Making AI systems behave according to human values |
| 21 | Medium | What is RLHF? | Reinforcement Learning from Human Feedback for model improvement |
| 22 | Medium | What is model quantization? | Reducing model size by using lower precision numbers |
| 23 | Medium | What is model distillation? | Training smaller model to mimic larger model's behavior |
| 24 | Medium | What is inference optimization? | Techniques to speed up model prediction time |
| 25 | Medium | What is prompt injection? | Security attack manipulating AI through malicious prompts |
| 26 | Medium | What is semantic search? | Search based on meaning rather than exact keywords |
| 27 | Medium | What is vector similarity? | Measuring closeness between embeddings using cosine similarity |
| 28 | Medium | What is chunking in RAG? | Breaking documents into smaller pieces for retrieval |
| 29 | Medium | What is retrieval in RAG? | Finding relevant information to augment generation |
| 30 | Medium | What is LangGraph? | Framework for building stateful, multi-actor applications |
| 31 | Hard | How to implement RAG pipeline? | Document ingestion, chunking, embedding, vector storage, retrieval, generation |
| 32 | Hard | What is agent framework? | System where AI can use tools and make decisions autonomously |
| 33 | Hard | What is ReAct pattern? | Reasoning and Acting - AI thinking through problems step by step |
| 34 | Hard | What is tool calling/function calling? | AI's ability to use external functions and APIs |
| 35 | Hard | What is multi-modal AI? | AI systems processing multiple data types (text, image, audio) |
| 36 | Hard | What is model evaluation? | Measuring AI performance using metrics like BLEU, ROUGE, perplexity |
| 37 | Hard | What is A/B testing for AI? | Comparing different model versions or prompting strategies |
| 38 | Hard | What is model monitoring? | Tracking AI performance and behavior in production |
| 39 | Hard | What is data privacy in AI? | Protecting sensitive information in training and inference |
| 40 | Hard | What is bias in AI models? | Unfair treatment of certain groups in AI outputs |
| 41 | Hard | What is model interpretability? | Understanding how AI models make decisions |
| 42 | Hard | What is adversarial examples? | Inputs designed to fool AI models |
| 43 | Hard | What is red teaming for AI? | Testing AI systems for vulnerabilities and misuse |
| 44 | Hard | What is AI safety? | Ensuring AI systems are beneficial and don't cause harm |
| 45 | Hard | What is constitutional AI? | Training AI to follow principles and be helpful/harmless |
| 46 | Expert | How to build production LLM pipeline? | MLOps, model serving, scaling, monitoring, versioning |
| 47 | Expert | What is mixture of experts? | Architecture using multiple specialized models |
| 48 | Expert | What is reinforcement learning for LLMs? | Training models through reward systems |
| 49 | Expert | What is federated learning? | Training models across distributed data without centralizing |
| 50 | Expert | What is differential privacy? | Adding noise to protect individual privacy in datasets |
| 51 | Expert | What is model compression techniques? | Pruning, quantization, distillation for efficient deployment |
| 52 | Expert | What is edge AI deployment? | Running AI models on edge devices with resource constraints |
| 53 | Expert | What is AI governance? | Policies and processes for responsible AI development |
| 54 | Expert | What is synthetic data generation? | Creating artificial training data using AI |
| 55 | Expert | What is continual learning? | AI systems learning new tasks without forgetting old ones |
