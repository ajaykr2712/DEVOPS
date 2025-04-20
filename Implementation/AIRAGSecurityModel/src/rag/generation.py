"""Generation module for AIRAG Security Model.
Handles context-aware response generation using OpenAI GPT or HuggingFace Transformers."""
from typing import List
from transformers import pipeline, AutoTokenizer, AutoModelForSeq2SeqLM

class Generator:
    """
    Generates context-aware responses using a specified transformer model.
    Args:
        model_name (str): Name of the HuggingFace model to use.
    """
    def __init__(self, model_name: str = "google/flan-t5-large") -> None:
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
        self.generator = pipeline("text2text-generation", model=self.model, tokenizer=self.tokenizer)

    def generate(self, context: str, query: str, max_length: int = 256) -> str:
        """
        Generate a response based on context and query.
        Args:
            context (str): The context string.
            query (str): The query string.
            max_length (int): Maximum length of the generated answer.
        Returns:
            str: Generated answer text.
        """
        prompt = f"Context: {context}\nQuery: {query}\nAnswer:"
        result = self.generator(prompt, max_length=max_length, do_sample=True, top_p=0.95, num_return_sequences=1)
        return result[0]["generated_text"].strip()

    def batch_generate(self, contexts: List[str], queries: List[str], max_length: int = 256) -> List[str]:
        """
        Generate responses for multiple context-query pairs.
        Args:
            contexts (List[str]): List of context strings.
            queries (List[str]): List of query strings.
            max_length (int): Maximum length of each generated answer.
        Returns:
            List[str]: List of generated answer texts.
        """
        return [self.generate(ctx, qry, max_length) for ctx, qry in zip(contexts, queries)]