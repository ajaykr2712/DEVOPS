import uvicorn
from fastapi import FastAPI
from src.rag.api import router as api_router

app = FastAPI(title="AIRAG Security Model API", description="Expert-level Retrieval-Augmented Generation for Security Threat Analysis")
app.include_router(api_router)

\"""Main entry point for the AIRAG Security Model API.
Initializes FastAPI app and launches the server for expert-level security threat analysis using Retrieval-Augmented Generation (RAG)."""
def main():
    print("Starting AIRAG Security Model API...")
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)

if __name__ == "__main__":
    main()