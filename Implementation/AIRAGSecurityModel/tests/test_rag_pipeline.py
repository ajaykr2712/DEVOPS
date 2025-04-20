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

def api_post(client, endpoint, payload):
    return client.post(endpoint, json=payload)

@pytest.mark.parametrize("endpoint,payload,expected_status,expected_key,expected_value", [
    ("/search", {"query": "nonexistent threat", "top_k": 2}, 200, "results", []),
    ("/ingest", {"filename": "test_security_data.csv"}, 200, "status", "success"),
    ("/search", {"query": "malware", "top_k": 2}, 200, "results", None),
    ("/generate", {"query": "How to detect phishing?", "top_k": 2, "max_length": 32}, 200, "answer", None),
    ("/ingest", {"filename": "does_not_exist.csv"}, None, None, None)
])
def test_api_calls(endpoint, payload, expected_status, expected_key, expected_value):
    client = TestClient(app)
    resp = api_post(client, endpoint, payload)
    if endpoint == "/ingest" and payload["filename"] == "does_not_exist.csv":
        assert resp.status_code == 400 or resp.status_code == 404
    else:
        assert resp.status_code == expected_status
        if expected_key:
            if expected_value is not None:
                assert resp.json()[expected_key] == expected_value
            else:
                assert expected_key in resp.json()