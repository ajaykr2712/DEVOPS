# AI-Powered RAG Model for Security Threat Analysis

This project implements an AI-Powered Retrieval-Augmented Generation (RAG) model specifically for security threat analysis.

## Structure

- `src/`: Source code for the RAG model, data processing, and API (if applicable).
- `data/`: Datasets used for training and retrieval (e.g., threat intelligence reports, logs).
- `models/`: Pre-trained models or model checkpoints.
- `config/`: Configuration files for the model, data sources, and environment variables. Modular and reusable for different environments.
- `notebooks/`: Jupyter notebooks for experimentation and analysis.
- `docs/`: Project documentation and API reference.

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
  curl -X POST "http://localhost:8000/ingest" -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{"filename": "your_data.csv"}'
  ```
- Search documents:
  ```bash
  curl -X POST "http://localhost:8000/search" -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{"query": "malware", "top_k": 3}'
  ```
- Generate answer:
  ```bash
  curl -X POST "http://localhost:8000/generate" -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{"query": "How to detect phishing?", "top_k": 2, "max_length": 64}'
  ```
- Advanced: Threat detection (requires authentication):
  ```bash
  curl -X POST "http://localhost:8000/threat-detect" -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{"document": "Suspicious login attempt detected."}'
  ```
- Advanced: Submit feedback (requires authentication):
  ```bash
  curl -X POST "http://localhost:8000/feedback" -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{"query": "malware", "answer": "Malware detected.", "feedback": "correct"}'
  ```

## Deployment

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
2. **Start the API server:**
   ```bash
   python -m src.main
   ```
3. **(Optional) Run tests:**
   ## Testing
   
   To run the test suite and verify the RAG pipeline:
   
   ```bash
   pytest tests/
   ```
   
   This will execute all tests, including pipeline and integration checks.
4. **Docker deployment:**
   ```bash
   docker build -t airag-security-model .
   docker run -p 8000:8000 airag-security-model
   ```

## Best Practices & Enhancements
- Modular, reusable code structure for ingestion, retrieval, generation, and threat intelligence.
- Optimized core logic for efficiency and scalability.
- Improved error handling and logging throughout the codebase for easier debugging and monitoring.
- Simplified and robust test setup/teardown using pytest fixtures and modular test utilities.
- Configuration management via the `config/` directory for environment-specific settings.
- Security best practices: authentication required for sensitive endpoints, non-root Docker user, and secure API design.
- See `docs/` for further technical documentation and API reference.

## Notes
- Ensure you have the required model weights downloaded for both retrieval and generation modules.
- For production, configure authentication and secure API endpoints appropriately.
- Contributions and suggestions for further enhancements are welcome!