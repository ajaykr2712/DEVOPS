"""Expert-level tests for AIRAG Security Model RAG pipeline."""
import pytest
from fastapi.testclient import TestClient
from src.main import app
import os
import pandas as pd

test_data_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../data/test_security_data.csv'))

def setup_module(module):
    # Create a small test CSV file for ingestion
    df = pd.DataFrame({
        'incident': ['Phishing detected', 'Malware infection', 'Unauthorized access'],
        'details': ['User reported suspicious email', 'Antivirus flagged trojan', 'Login from unusual location']
    })
    os.makedirs(os.path.dirname(test_data_path), exist_ok=True)
    df.to_csv(test_data_path, index=False)

def teardown_module(module):
    if os.path.exists(test_data_path):
        os.remove(test_data_path)

def test_ingest_and_search_and_generate():
    client = TestClient(app)
    # Ingest test data
    resp = client.post("/ingest", json={"filename": "test_security_data.csv"})
    assert resp.status_code == 200
    assert resp.json()["status"] == "success"
    # Search
    resp = client.post("/search", json={"query": "phishing", "top_k": 2})
    assert resp.status_code == 200
    assert "results" in resp.json()
    # Generate
    resp = client.post("/generate", json={"query": "How to handle phishing?", "top_k": 2, "max_length": 64})
    assert resp.status_code == 200
    assert "answer" in resp.json()