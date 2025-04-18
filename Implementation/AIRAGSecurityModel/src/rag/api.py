"""API module for AIRAG Security Model.
Exposes endpoints for document ingestion, retrieval, and generation via FastAPI."""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from src.rag.data_ingestion import DataIngestion
from src.rag.retrieval import Retriever
from src.rag.generation import Generator
import os

router = APIRouter()

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../data'))
ingestor = DataIngestion(data_dir)
retriever = Retriever()
generator = Generator()

class IngestRequest(BaseModel):
    filename: str

class SearchRequest(BaseModel):
    query: str
    top_k: int = 5

class GenerateRequest(BaseModel):
    query: str
    top_k: int = 5
    max_length: int = 256

@router.post("/ingest")
def ingest_data(req: IngestRequest):
    try:
        df = ingestor.load_and_preprocess(req.filename)
        docs = df.astype(str).agg(' '.join, axis=1).tolist()
        retriever.build_index(docs)
        return {"status": "success", "num_docs": len(docs)}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/search")
def search(req: SearchRequest):
    try:
        results = retriever.search(req.query, req.top_k)
        return {"results": [{"document": doc, "score": score} for doc, score in results]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/generate")
def generate(req: GenerateRequest):
    try:
        results = retriever.search(req.query, req.top_k)
        context = '\n'.join([doc for doc, _ in results])
        answer = generator.generate(context, req.query, max_length=req.max_length)
        return {"answer": answer, "context": context}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))