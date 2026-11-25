"""
health.py - Health check and uptime router
"""

import time
from fastapi import APIRouter
from models.article import HealthResponse
from services.cache_service import cache_service

router = APIRouter(tags=["Health"])

START_TIME = time.time()


@router.get("/health", response_model=HealthResponse)
def get_health():
    """
    Check whether the TechBrief backend is running, along with cache status and uptime.
    """
    uptime = time.time() - START_TIME
    cached_count = cache_service.count("all_articles")
    cache_age = cache_service.get_age("all_articles")

    return HealthResponse(
        status="healthy",
        service="TechBrief API",
        version="1.0.0",
        cached_articles_count=cached_count,
        cache_age_seconds=round(cache_age, 2) if cache_age is not None else None,
        uptime_seconds=round(uptime, 2),
    )


@router.get("/")
def get_root():
    """
    Root welcome endpoint and quick documentation links.
    """
    return {
        "app": "TechBrief API",
        "description": "AI-Powered Tech News Summarizer using Claude Haiku",
        "version": "1.0.0",
        "status": "online",
        "docs_url": "/docs",
        "endpoints": {
            "GET /news": "Get latest 2-sentence AI-summarized tech news",
            "GET /categories": "Get available tech categories",
            "GET /health": "Backend health and cache status",
        },
    }
