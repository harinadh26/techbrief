"""
news.py - News aggregation and AI summarization router
"""

from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query
from models.article import Article
from services.rss_service import rss_service, OFFICIAL_CATEGORIES

router = APIRouter(tags=["News"])


@router.get("/news", response_model=List[Article])
def get_news(
    category: Optional[str] = Query(
        None,
        description="Filter articles by category (e.g. 'Artificial Intelligence', 'Startups', 'Cybersecurity')"
    ),
    refresh: bool = Query(
        False,
        description="Set to true to force refresh RSS feeds and bypass cache"
    ),
    limit: Optional[int] = Query(
        None,
        ge=1,
        le=50,
        description="Maximum number of articles to return"
    ),
):
    """
    Fetches the 4 latest articles from TechCrunch, The Verge, and VentureBeat (12 total),
    generates 2-sentence Claude AI summaries, caches for 30 minutes, and returns the list.
    """
    try:
        articles = rss_service.get_latest_news(force_refresh=refresh)

        # Apply category filter if requested
        if category and category.lower() != "all":
            articles = [
                a for a in articles
                if a.category.lower() == category.lower()
            ]

        # Apply limit if requested
        if limit is not None:
            articles = articles[:limit]

        return articles

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred while fetching news summaries: {str(e)}"
        )
