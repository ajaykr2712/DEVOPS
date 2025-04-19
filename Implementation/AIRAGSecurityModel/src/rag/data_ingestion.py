"""Data ingestion module for AIRAG Security Model.
Handles loading, preprocessing, and normalization of security datasets for RAG pipeline."""
import os
import pandas as pd
from typing import List, Dict, Any

class DataIngestion:
    """
    Handles loading, preprocessing, and normalization of security datasets for RAG pipeline.
    Expected CSV format: Each row represents a security incident or document with relevant fields.
    """
    def __init__(self, data_dir: str):
        self.data_dir = data_dir

    def load_csv(self, filename: str) -> pd.DataFrame:
        path = os.path.join(self.data_dir, filename)
        if not os.path.exists(path):
            raise FileNotFoundError(f"File not found: {path}")
        df = pd.read_csv(path)
        return df

    def preprocess(self, df: pd.DataFrame) -> pd.DataFrame:
        # Example: Lowercase all text columns, drop duplicates, handle missing values
        for col in df.select_dtypes(include=["object"]):
            df[col] = df[col].str.lower().fillna("")
        df = df.drop_duplicates()
        df = df.fillna("")
        return df

    def load_and_preprocess(self, filename: str) -> pd.DataFrame:
        df = self.load_csv(filename)
        return self.preprocess(df)

    def load_multiple(self, filenames: List[str]) -> List[pd.DataFrame]:
        return [self.load_and_preprocess(f) for f in filenames]