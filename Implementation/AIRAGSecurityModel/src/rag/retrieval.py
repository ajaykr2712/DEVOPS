"""Retrieval module for AIRAG Security Model.
Implements vector-based semantic retrieval using FAISS and sentence-transformers."""
import os
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer
from typing import List, Tuple, Optional
import threading

class Retriever:
    """
    Implements vector-based semantic retrieval using FAISS and sentence-transformers.
    If index_path is provided, the FAISS index will be saved/loaded from disk for persistence.
    Optimized for memory efficiency and thread safety.
    """
    def __init__(self, model_name: str = "all-MiniLM-L6-v2", index_path: Optional[str] = None):
        self.model = SentenceTransformer(model_name)
        self.index = None
        self.index_path = index_path
        self.embeddings = None
        self.documents = []
        self.lock = threading.Lock()

    def build_index(self, documents: List[str]):
        with self.lock:
            self.documents = documents
            self.embeddings = self.model.encode(documents, show_progress_bar=True, batch_size=32, normalize_embeddings=True)
            dim = self.embeddings.shape[1]
            self.index = faiss.IndexFlatL2(dim)
            self.index.add(np.array(self.embeddings, dtype=np.float32))
            if self.index_path:
                faiss.write_index(self.index, self.index_path)

    def load_index(self):
        with self.lock:
            if self.index_path and os.path.exists(self.index_path):
                self.index = faiss.read_index(self.index_path)
            else:
                raise FileNotFoundError("Index file not found.")

    def search(self, query: str, top_k: int = 5) -> List[Tuple[str, float]]:
        if self.index is None:
            raise RuntimeError("FAISS index is not initialized. Call build_index or load_index first.")
        query_vec = self.model.encode([query], normalize_embeddings=True)
        D, I = self.index.search(np.array(query_vec, dtype=np.float32), top_k)
        results = []
        for idx, i in enumerate(I[0]):
            if 0 <= i < len(self.documents):
                results.append((self.documents[i], float(D[0][idx])))
        return results