import os
import pytest
from fastapi.testclient import TestClient
from src.main import app

test_data_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../data/test_security_data.csv'))

@pytest.fixture(scope="module", autouse=True)
def setup_and_teardown():
    import pandas as pd
    df = pd.DataFrame({
        "event": ["phishing attempt", "malware detected", "normal login"],
        "details": ["Suspicious email", "Trojan found", "User login"]
    })
    os.makedirs(os.path.dirname(test_data_path), exist_ok=True)
    df.to_csv(test_data_path, index=False)
    yield
    if os.path.exists(test_data_path):
        os.remove(test_data_path)

def test_search_no_results():
    client = TestClient(app)
    resp = client.post("/search", json={"query": "nonexistent threat", "top_k": 2})
    assert resp.status_code == 200
    assert resp.json()["results"] == []
def test_ingest_search_generate():
    client = TestClient(app)
    # Ingest
    resp = client.post("/ingest", json={"filename": "test_security_data.csv"})
    assert resp.status_code == 200
    assert resp.json()["status"] == "success"
    # Search
    resp = client.post("/search", json={"query": "malware", "top_k": 2})
    assert resp.status_code == 200
    assert "results" in resp.json()
    # Generate
    resp = client.post("/generate", json={"query": "How to detect phishing?", "top_k": 2, "max_length": 32})
    assert resp.status_code == 200
    assert "answer" in resp.json()
def test_ingest_invalid_file():
    client = TestClient(app)
    resp = client.post("/ingest", json={"filename": "does_not_exist.csv"})
    assert resp.status_code == 400 or resp.status_code == 404