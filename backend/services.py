"""
services.py - Backward compatibility shim.
Directs callers to the modular services package.
"""

from services.rss_service import rss_service
from services.ai_service import ai_service
from services.cache_service import cache_service


def get_latest_news():
    """
    Backward-compatible function returning raw dictionaries if requested.
    """
    articles = rss_service.get_latest_news()
    return [a.dict() if hasattr(a, "dict") else a.model_dump() for a in articles]


__all__ = ["rss_service", "ai_service", "cache_service", "get_latest_news"]
