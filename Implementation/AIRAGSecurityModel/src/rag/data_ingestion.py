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
        """
        Loads a CSV file from the data directory.
        Args:
            filename (str): Name of the CSV file to load.
        Returns:
            pd.DataFrame: Loaded DataFrame.
        Raises:
            FileNotFoundError: If the file does not exist.
        """
        path = os.path.join(self.data_dir, filename)
        if not os.path.exists(path):
            raise FileNotFoundError(f"File not found: {path}")
        df = pd.read_csv(path)
        return df

    def preprocess(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Preprocesses the DataFrame by lowercasing text columns, dropping duplicates, and filling missing values.
        Args:
            df (pd.DataFrame): Input DataFrame.
        Returns:
            pd.DataFrame: Preprocessed DataFrame.
        """
        # Example: Lowercase all text columns, drop duplicates, handle missing values
        for col in df.select_dtypes(include=["object"]):
            df[col] = df[col].str.lower().fillna("")
        df = df.drop_duplicates()
        df = df.fillna("")
        return df

    def load_and_preprocess(self, filename: str) -> pd.DataFrame:
        """
        Loads a CSV file and applies preprocessing.
        Args:
            filename (str): Name of the CSV file to load and preprocess.
        Returns:
            pd.DataFrame: Preprocessed DataFrame.
        """
        df = self.load_csv(filename)
        return self.preprocess(df)

    def load_multiple(self, filenames: List[str]) -> List[pd.DataFrame]:
        """
        Loads and preprocesses multiple CSV files.
        Args:
            filenames (List[str]): List of CSV filenames.
        Returns:
            List[pd.DataFrame]: List of preprocessed DataFrames.
        """
        return [self.load_and_preprocess(f) for f in filenames]