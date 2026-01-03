---
name: LLM Applications Expert
description: LangChain, RAG, embeddings, vector databases, AI agents, och prompt engineering för 2026.
---

# LLM Applications Best Practices

## Projektstruktur

```
llm-app/
├── src/
│   ├── agents/              # AI agents
│   │   ├── __init__.py
│   │   └── research_agent.py
│   ├── chains/              # LangChain chains
│   │   ├── __init__.py
│   │   └── qa_chain.py
│   ├── embeddings/          # Embedding logic
│   │   └── embed.py
│   ├── prompts/             # Prompt templates
│   │   └── templates.py
│   ├── retrieval/           # RAG components
│   │   ├── __init__.py
│   │   ├── loader.py
│   │   └── retriever.py
│   ├── tools/               # Agent tools
│   │   └── search.py
│   └── utils/
│       └── tokens.py
├── data/
│   ├── documents/           # Source documents
│   └── vectorstore/         # Persisted embeddings
├── tests/
├── .env
└── requirements.txt
```

## LangChain Basics

### Simple Chain
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Components
llm = ChatOpenAI(model="gpt-4o", temperature=0)
prompt = ChatPromptTemplate.from_messages([
    ("system", "Du är en hjälpsam assistent som svarar koncist."),
    ("human", "{input}"),
])
output_parser = StrOutputParser()

# Chain med LCEL (LangChain Expression Language)
chain = prompt | llm | output_parser

# Kör
response = chain.invoke({"input": "Vad är RAG?"})
```

### Structured Output
```python
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_core.output_parsers import PydanticOutputParser

class MovieReview(BaseModel):
    title: str = Field(description="Filmens titel")
    rating: int = Field(description="Betyg 1-10")
    summary: str = Field(description="Kort sammanfattning")
    pros: list[str] = Field(description="Fördelar")
    cons: list[str] = Field(description="Nackdelar")

parser = PydanticOutputParser(pydantic_object=MovieReview)

prompt = ChatPromptTemplate.from_messages([
    ("system", "Analysera filmrecensionen. {format_instructions}"),
    ("human", "{review}"),
]).partial(format_instructions=parser.get_format_instructions())

chain = prompt | llm | parser
review: MovieReview = chain.invoke({"review": review_text})
```

## RAG (Retrieval-Augmented Generation)

### Document Loading
```python
from langchain_community.document_loaders import (
    PyPDFLoader,
    TextLoader,
    DirectoryLoader,
    WebBaseLoader,
)
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Ladda dokument
loader = DirectoryLoader("./docs", glob="**/*.pdf", loader_cls=PyPDFLoader)
documents = loader.load()

# Chunking
splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", ".", "!", "?", ",", " ", ""],
)
chunks = splitter.split_documents(documents)
```

### Vector Store
```python
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma, FAISS, Pinecone

# Embeddings
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")

# Chroma (lokal, bra för utveckling)
vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./data/vectorstore",
)

# FAISS (snabb, in-memory)
vectorstore = FAISS.from_documents(chunks, embeddings)
vectorstore.save_local("./data/faiss_index")

# Pinecone (managed, skalbar)
from pinecone import Pinecone
pc = Pinecone(api_key="...")
vectorstore = PineconeVectorStore.from_documents(
    chunks, embeddings, index_name="my-index"
)
```

### RAG Chain
```python
from langchain_core.runnables import RunnablePassthrough
from langchain_core.prompts import ChatPromptTemplate

# Retriever
retriever = vectorstore.as_retriever(
    search_type="mmr",  # Maximum Marginal Relevance
    search_kwargs={"k": 5, "fetch_k": 10},
)

# Prompt
rag_prompt = ChatPromptTemplate.from_messages([
    ("system", """Svara på frågan baserat på följande kontext.
Om du inte kan svara baserat på kontexten, säg det.

Kontext:
{context}"""),
    ("human", "{question}"),
])

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

# RAG Chain
rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | rag_prompt
    | llm
    | StrOutputParser()
)

answer = rag_chain.invoke("Vad säger dokumenten om X?")
```

### Advanced RAG
```python
# Hybrid search (keyword + semantic)
from langchain.retrievers import EnsembleRetriever
from langchain_community.retrievers import BM25Retriever

bm25_retriever = BM25Retriever.from_documents(chunks)
semantic_retriever = vectorstore.as_retriever()

hybrid_retriever = EnsembleRetriever(
    retrievers=[bm25_retriever, semantic_retriever],
    weights=[0.4, 0.6],
)

# Reranking
from langchain.retrievers import ContextualCompressionRetriever
from langchain_cohere import CohereRerank

reranker = CohereRerank(model="rerank-english-v3.0", top_n=3)
compression_retriever = ContextualCompressionRetriever(
    base_compressor=reranker,
    base_retriever=retriever,
)

# Self-query (metadata filtering)
from langchain.retrievers.self_query.base import SelfQueryRetriever

retriever = SelfQueryRetriever.from_llm(
    llm=llm,
    vectorstore=vectorstore,
    document_contents="Produktkatalog",
    metadata_field_info=[
        {"name": "category", "type": "string", "description": "Produktkategori"},
        {"name": "price", "type": "float", "description": "Pris i SEK"},
    ],
)
```

## AI Agents

### ReAct Agent
```python
from langchain.agents import create_react_agent, AgentExecutor
from langchain_core.tools import Tool
from langchain import hub

# Tools
def search_web(query: str) -> str:
    """Söker på webben efter information."""
    # Implementation
    return results

def calculate(expression: str) -> str:
    """Beräknar matematiska uttryck."""
    return str(eval(expression))

tools = [
    Tool(name="search", func=search_web, description="Söker på webben"),
    Tool(name="calculator", func=calculate, description="Räknar ut matematik"),
]

# Agent
prompt = hub.pull("hwchase17/react")
agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_iterations=5,
    handle_parsing_errors=True,
)

result = agent_executor.invoke({"input": "Vad är 15% av Sveriges BNP 2024?"})
```

### Tool Calling Agent (modernare)
```python
from langchain_core.tools import tool
from langchain.agents import create_tool_calling_agent, AgentExecutor

@tool
def get_weather(city: str) -> str:
    """Hämtar väder för en stad."""
    # API call
    return f"Soligt, 22°C i {city}"

@tool
def search_database(query: str) -> list[dict]:
    """Söker i produktdatabasen."""
    # DB query
    return [{"name": "Produkt", "price": 100}]

tools = [get_weather, search_database]

prompt = ChatPromptTemplate.from_messages([
    ("system", "Du är en hjälpsam assistent med tillgång till verktyg."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])

agent = create_tool_calling_agent(llm, tools, prompt)
executor = AgentExecutor(agent=agent, tools=tools)

result = executor.invoke({"input": "Hur är vädret i Stockholm?"})
```

### Multi-Agent System
```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
import operator

class AgentState(TypedDict):
    messages: Annotated[list, operator.add]
    next_agent: str

def researcher(state: AgentState) -> AgentState:
    """Forskar och samlar information."""
    # Research logic
    return {"messages": [research_result], "next_agent": "writer"}

def writer(state: AgentState) -> AgentState:
    """Skriver baserat på research."""
    # Writing logic
    return {"messages": [written_content], "next_agent": "reviewer"}

def reviewer(state: AgentState) -> AgentState:
    """Granskar och ger feedback."""
    # Review logic
    return {"messages": [feedback], "next_agent": "end"}

# Graph
workflow = StateGraph(AgentState)
workflow.add_node("researcher", researcher)
workflow.add_node("writer", writer)
workflow.add_node("reviewer", reviewer)

workflow.set_entry_point("researcher")
workflow.add_edge("researcher", "writer")
workflow.add_edge("writer", "reviewer")
workflow.add_edge("reviewer", END)

app = workflow.compile()
result = app.invoke({"messages": [], "next_agent": "researcher"})
```

## Prompt Engineering

### System Prompts
```python
SYSTEM_PROMPT = """Du är en expert på {domain}.

## Instruktioner
- Svara alltid på svenska
- Var koncis men fullständig
- Om du är osäker, säg det
- Citera källor när möjligt

## Format
Strukturera svar med:
1. Kort sammanfattning
2. Detaljerad förklaring
3. Exempel (om relevant)
4. Källor

## Begränsningar
- Svara endast på frågor inom {domain}
- Ge inga medicinska/juridiska råd
- Spekulera inte om framtiden
"""
```

### Few-shot Prompting
```python
from langchain_core.prompts import FewShotPromptTemplate, PromptTemplate

examples = [
    {"input": "Hej, hur mår du?", "output": "positive"},
    {"input": "Det här är skit", "output": "negative"},
    {"input": "Okej produkt", "output": "neutral"},
]

example_prompt = PromptTemplate(
    input_variables=["input", "output"],
    template="Text: {input}\nSentiment: {output}",
)

few_shot_prompt = FewShotPromptTemplate(
    examples=examples,
    example_prompt=example_prompt,
    prefix="Klassificera sentiment i texten.",
    suffix="Text: {input}\nSentiment:",
    input_variables=["input"],
)
```

### Chain of Thought
```python
cot_prompt = """Lösa detta steg för steg:

Fråga: {question}

Tänk igenom detta noggrant:
1. Vad frågas det efter?
2. Vilken information har vi?
3. Vilka steg behövs för att lösa det?
4. Utför varje steg
5. Verifiera svaret

Steg-för-steg lösning:"""
```

## Säkerhet

### Prompt Injection Protection
```python
def sanitize_input(user_input: str) -> str:
    """Sanerar användarinput."""
    # Ta bort potentiellt farliga mönster
    dangerous_patterns = [
        r"ignore previous instructions",
        r"disregard.*instructions",
        r"you are now",
        r"new persona",
    ]
    for pattern in dangerous_patterns:
        user_input = re.sub(pattern, "[FILTERED]", user_input, flags=re.I)
    return user_input

def validate_output(output: str, allowed_topics: list[str]) -> bool:
    """Validerar att output är inom tillåtna ämnen."""
    # Implementera content filtering
    pass
```

### Rate Limiting
```python
from functools import lru_cache
import time

class RateLimiter:
    def __init__(self, max_requests: int, window_seconds: int):
        self.max_requests = max_requests
        self.window = window_seconds
        self.requests = {}

    def is_allowed(self, user_id: str) -> bool:
        now = time.time()
        user_requests = self.requests.get(user_id, [])
        # Rensa gamla requests
        user_requests = [t for t in user_requests if now - t < self.window]
        if len(user_requests) >= self.max_requests:
            return False
        user_requests.append(now)
        self.requests[user_id] = user_requests
        return True

limiter = RateLimiter(max_requests=10, window_seconds=60)
```

## Evaluation

### RAG Evaluation
```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness,
    answer_relevancy,
    context_precision,
    context_recall,
)

# Evaluation dataset
eval_data = {
    "question": ["Vad är X?", "Hur fungerar Y?"],
    "answer": ["X är...", "Y fungerar genom..."],
    "contexts": [["Kontext om X..."], ["Kontext om Y..."]],
    "ground_truth": ["X är faktiskt...", "Y fungerar egentligen..."],
}

result = evaluate(
    dataset=eval_data,
    metrics=[faithfulness, answer_relevancy, context_precision],
)
print(result)
```

## Deployment

### Streaming
```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse

app = FastAPI()

@app.post("/chat")
async def chat(message: str):
    async def generate():
        async for chunk in chain.astream({"input": message}):
            yield f"data: {chunk}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(generate(), media_type="text/event-stream")
```

### Caching
```python
from langchain.cache import SQLiteCache
from langchain.globals import set_llm_cache

# Cache LLM responses
set_llm_cache(SQLiteCache(database_path=".langchain.db"))

# Semantic cache (sparar liknande frågor)
from langchain.cache import RedisSemanticCache
set_llm_cache(RedisSemanticCache(
    redis_url="redis://localhost:6379",
    embedding=embeddings,
))
```

## Best Practices

1. **Chunk size matters** - Experimentera med 500-2000 tokens
2. **Overlap** - 10-20% overlap mellan chunks
3. **Metadata** - Spara källa, sida, datum för filtering
4. **Reranking** - Förbättrar relevans signifikant
5. **Evaluation** - Mät faithfulness, relevancy, groundedness
6. **Caching** - Spara dyra API calls
7. **Streaming** - Bättre UX för längre svar
8. **Guardrails** - Validera input OCH output
