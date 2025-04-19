# Expert-level Dockerfile for AIRAG Security Model
FROM python:3.10-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy requirements and install
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src ./src
COPY models ./models
COPY data ./data

# Expose API port
EXPOSE 8000

# Security: Use a non-root user
RUN useradd -m airaguser && chown -R airaguser /app
USER airaguser

# Run the API
CMD ["python", "-m", "src.main"]