"""
categories.py - News categories router
"""

from fastapi import APIRouter
from models.article import CategoriesResponse
from services.rss_service import OFFICIAL_CATEGORIES

router = APIRouter(tags=["Categories"])


@router.get("/categories", response_model=CategoriesResponse)
def get_categories():
    """
    Return available tech news categories.
    """
    return CategoriesResponse(categories=OFFICIAL_CATEGORIES)
