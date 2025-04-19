"""API module for AIRAG Security Model.
Exposes endpoints for document ingestion, retrieval, and generation via FastAPI."""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from src.rag.data_ingestion import DataIngestion
from src.rag.retrieval import Retriever
from src.rag.generation import Generator
from src.rag.dashboard import router as dashboard_router
from src.rag.auth import get_current_user
import os
import logging

router = APIRouter()

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger("AIRAGSecurityModel")

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

class ThreatDetectionRequest(BaseModel):
    document: str

class FeedbackRequest(BaseModel):
    query: str
    answer: str
    feedback: str

router.include_router(dashboard_router)
@router.post("/threat-detect", dependencies=[Depends(get_current_user)])
def detect_threat(req: ThreatDetectionRequest):
    try:
        # Placeholder for advanced threat detection logic
        # In production, integrate with a real threat detection model or service
        suspicious_keywords = ["phishing", "malware", "unauthorized", "trojan", "ransomware"]
        detected = any(word in req.document.lower() for word in suspicious_keywords)
        logger.info(f"Threat detection run on document. Detected: {detected}")
        return {"threat_detected": detected}
    except Exception as e:
        logger.error(f"Threat detection error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/feedback", dependencies=[Depends(get_current_user)])
def submit_feedback(req: FeedbackRequest):
    try:
        # Log feedback for monitoring and future active learning
        logger.info(f"Feedback received: Query='{req.query}', Answer='{req.answer}', Feedback='{req.feedback}'")
        # In production, store feedback in a database or file for active learning
        return {"status": "feedback received"}
    except Exception as e:
        logger.error(f"Feedback submission error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/ingest", dependencies=[Depends(get_current_user)])
def ingest_data(req: IngestRequest):
    try:
        if not req.filename or not req.filename.endswith('.csv'):
            logger.warning("Invalid filename provided for ingestion.")
            raise ValueError("Invalid filename. Only CSV files are supported.")
        df = ingestor.load_and_preprocess(req.filename)
        docs = df.astype(str).agg(' '.join, axis=1).tolist()
        retriever.build_index(docs)
        logger.info(f"Ingested {len(docs)} documents from {req.filename}.")
        return {"status": "success", "num_docs": len(docs)}
    except Exception as e:
        logger.error(f"Ingestion error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/search", dependencies=[Depends(get_current_user)])
def search(req: SearchRequest):
    try:
        if not req.query or not isinstance(req.top_k, int) or req.top_k <= 0:
            logger.warning("Invalid search parameters.")
            raise ValueError("Query must be non-empty and top_k must be a positive integer.")
        results = retriever.search(req.query, req.top_k)
        logger.info(f"Search performed for query '{req.query}' with top_k={req.top_k}.")
        return {"results": [{"document": doc, "score": score} for doc, score in results]}
    except Exception as e:
        logger.error(f"Search error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/generate", dependencies=[Depends(get_current_user)])
def generate(req: GenerateRequest):
    try:
        if not req.query or not isinstance(req.top_k, int) or req.top_k <= 0 or not isinstance(req.max_length, int) or req.max_length <= 0:
            logger.warning("Invalid generation parameters.")
            raise ValueError("Query must be non-empty, top_k and max_length must be positive integers.")
        results = retriever.search(req.query, req.top_k)
        context = '\n'.join([doc for doc, _ in results])
        answer = generator.generate(context, req.query, max_length=req.max_length)
        logger.info(f"Generated answer for query '{req.query}' with context length {len(context)}.")
        return {"answer": answer, "context": context}
    except Exception as e:
        logger.error(f"Generation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))