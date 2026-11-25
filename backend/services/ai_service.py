"""
ai_service.py - Anthropic Claude Haiku AI Summarization Service
Produces strict two-sentence summaries using simple and clear English.
Falls back safely to extractive summarization if API key is not configured or network fails.
"""

import os
import re
import logging
from typing import Optional
from anthropic import Anthropic

logger = logging.getLogger("techbrief.ai")


class AIService:
    def __init__(self):
        self._client: Optional[Anthropic] = None
        self._init_client()

    def _init_client(self):
        api_key = os.getenv("ANTHROPIC_API_KEY", "").strip()
        if api_key and api_key != "your_anthropic_api_key_here":
            try:
                self._client = Anthropic(api_key=api_key)
                logger.info("Anthropic Claude client successfully initialized.")
            except Exception as e:
                logger.warning(f"Failed to initialize Anthropic client: {e}")
                self._client = None
        else:
            logger.info("No ANTHROPIC_API_KEY detected. Running in high-fidelity fallback mode.")
            self._client = None

    def summarize_article(self, title: str, content: str) -> str:
        """
        Summarizes an article into exactly two short, simple sentences.
        """
        truncated_content = content[:1500].strip()
        if not truncated_content:
            return "This article covers recent technology updates. Tap to read the full report."

        # If Anthropic client is available, use Claude Haiku
        if self._client:
            try:
                model_name = os.getenv("CLAUDE_MODEL", "claude-3-5-haiku-20241022")
                prompt = (
                    f"Article Title: {title}\n"
                    f"Content Excerpt:\n{truncated_content}\n\n"
                    "Task: Summarize this news article in exactly two short sentences using simple, understandable English. "
                    "First sentence: Explain what happened. Second sentence: Explain why it matters or what comes next. "
                    "Preserve factual accuracy, avoid speculation, and do not use filler words. Output ONLY the two sentences."
                )
                message = self._client.messages.create(
                    model=model_name,
                    max_tokens=140,
                    temperature=0.2,
                    messages=[{"role": "user", "content": prompt}],
                )
                raw_summary = message.content[0].text.strip()
                # Clean up any surrounding quotes or markdown
                clean_summary = raw_summary.strip('"').strip("'").strip()
                if clean_summary:
                    return clean_summary
            except Exception as e:
                logger.warning(f"Claude API summarization call failed ({e}). Using smart fallback.")

        # Fallback two-sentence summary generator
        return self._generate_fallback_summary(title, truncated_content)

    def _generate_fallback_summary(self, title: str, text: str) -> str:
        """
        Smart extractive fallback producing exactly two clean, well-formed sentences.
        """
        if not text:
            return f"{title}. Visit the original article to explore full details and insights."

        # Split into sentences based on punctuation followed by space and capital letter or digit
        sentences = re.split(r"(?<=[.!?])\s+(?=[A-Z0-9])", text)
        clean_sentences = []
        for s in sentences:
            s_clean = s.strip()
            # Skip advertisement sentences or social share snippets
            if len(s_clean) > 25 and not any(junk in s_clean.lower() for junk in [
                "subscribe", "sign up", "cookie", "advertisement", "newsletter", "follow us", "read more"
            ]):
                clean_sentences.append(s_clean)

        if len(clean_sentences) >= 2:
            return f"{clean_sentences[0]} {clean_sentences[1]}"
        elif len(clean_sentences) == 1:
            return f"{clean_sentences[0]} Read the full article for further context and details."
        else:
            return f"{title}. Tap below to read the comprehensive news report directly from the source."


# Global shared singleton AI service instance
ai_service = AIService()
