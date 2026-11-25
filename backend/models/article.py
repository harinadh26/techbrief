"""
article.py - Pydantic data schemas for TechBrief API
"""

from typing import List, Optional
from pydantic import BaseModel, Field


class Article(BaseModel):
    id: str = Field(..., description="Unique article hash/identifier")
    title: str = Field(..., description="Headline of the article")
    link: str = Field(..., description="URL to the original full article")
    source: str = Field(..., description="Name of the news publication (TechCrunch, The Verge, VentureBeat)")
    published_date: str = Field(..., description="Publication date string")
    summary: str = Field(..., description="AI-generated 2-sentence summary")
    category: str = Field(..., description="One of the official tech categories")


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str
    cached_articles_count: int
    cache_age_seconds: Optional[float]
    uptime_seconds: float


class CategoriesResponse(BaseModel):
    categories: List[str]
