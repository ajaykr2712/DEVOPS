"""Generation module for AIRAG Security Model.
Handles context-aware response generation using OpenAI GPT or HuggingFace Transformers."""
from typing import List
from transformers import pipeline, AutoTokenizer, AutoModelForSeq2SeqLM

class Generator:
    def __init__(self, model_name: str = "google/flan-t5-large"):
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
        self.generator = pipeline("text2text-generation", model=self.model, tokenizer=self.tokenizer)

    def generate(self, context: str, query: str, max_length: int = 256) -> str:
        prompt = f"Context: {context}\nQuery: {query}\nAnswer:"
        result = self.generator(prompt, max_length=max_length, do_sample=True, top_p=0.95, num_return_sequences=1)
        return result[0]["generated_text"].strip()

    def batch_generate(self, contexts: List[str], queries: List[str], max_length: int = 256) -> List[str]:
        prompts = [f"Context: {c}\nQuery: {q}\nAnswer:" for c, q in zip(contexts, queries)]
        results = self.generator(prompts, max_length=max_length, do_sample=True, top_p=0.95, num_return_sequences=1)
        return [r["generated_text"].strip() for r in results]