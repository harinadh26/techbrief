from .health import router as health_router
from .categories import router as categories_router
from .news import router as news_router

__all__ = ["health_router", "categories_router", "news_router"]
