# AI-Powered RAG Model for Security Threat Analysis

This project implements an AI-Powered Retrieval-Augmented Generation (RAG) model specifically for security threat analysis.

## Structure

- `src/`: Source code for the RAG model, data processing, and API (if applicable).
- `data/`: Datasets used for training and retrieval (e.g., threat intelligence reports, logs).
- `models/`: Pre-trained models or model checkpoints.
- `config/`: Configuration files for the model, data sources, etc.
- `notebooks/`: Jupyter notebooks for experimentation and analysis.
- `docs/`: Project documentation.

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd AIRAGSecurityModel
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the API server:
   ```bash
   python -m src.main
   ```

## Usage Examples

- Ingest data:
  ```bash
  curl -X POST "http://localhost:8000/ingest" -H "Content-Type: application/json" -d '{"filename": "your_data.csv"}'
  ```
- Search documents:
  ```bash
  curl -X POST "http://localhost:8000/search" -H "Content-Type: application/json" -d '{"query": "malware", "top_k": 3}'
  ```
- Generate answer:
  ```bash
  curl -X POST "http://localhost:8000/generate" -H "Content-Type: application/json" -d '{"query": "How to detect phishing?", "top_k": 2, "max_length": 64}'
  ```