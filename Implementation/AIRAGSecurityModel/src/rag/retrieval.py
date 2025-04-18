"""Retrieval module for AIRAG Security Model.
Implements vector-based semantic retrieval using FAISS and sentence-transformers."""
import os
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer
from typing import List, Tuple

class Retriever:
    def __init__(self, model_name: str = "all-MiniLM-L6-v2", index_path: str = None):
        self.model = SentenceTransformer(model_name)
        self.index = None
        self.index_path = index_path
        self.embeddings = None
        self.documents = []

    def build_index(self, documents: List[str]):
        self.documents = documents
        self.embeddings = self.model.encode(documents, show_progress_bar=True)
        dim = self.embeddings.shape[1]
        self.index = faiss.IndexFlatL2(dim)
        self.index.add(np.array(self.embeddings, dtype=np.float32))
        if self.index_path:
            faiss.write_index(self.index, self.index_path)

    def load_index(self):
        if self.index_path and os.path.exists(self.index_path):
            self.index = faiss.read_index(self.index_path)
        else:
            raise FileNotFoundError("Index file not found.")

    def search(self, query: str, top_k: int = 5) -> List[Tuple[str, float]]:
        query_vec = self.model.encode([query])
        D, I = self.index.search(np.array(query_vec, dtype=np.float32), top_k)
        results = [(self.documents[i], float(D[0][idx])) for idx, i in enumerate(I[0])]
        return results