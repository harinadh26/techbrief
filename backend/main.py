
"""
main.py - TechBrief FastAPI Application Entry Point
"""

import os
import asyncio
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

load_dotenv()

from routers.health import router as health_router
from routers.categories import router as categories_router
from routers.news import router as news_router
from services.rss_service import rss_service

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("techbrief.scheduler")


async def automatic_news_checker():
    """Check RSS feeds every 60 seconds."""
    while True:
        try:
            logger.info("Automatic news check started.")
            await asyncio.to_thread(rss_service.refresh_new_articles)
            logger.info("Automatic news check completed.")
        except Exception:
            logger.exception("Automatic news check failed.")

        await asyncio.sleep(60)


@asynccontextmanager
async def lifespan(app: FastAPI):
    task = asyncio.create_task(automatic_news_checker())
    logger.info("TechBrief automatic news checker started.")

    try:
        yield
    finally:
        task.cancel()
        try:
            await task
        except asyncio.CancelledError:
            pass
        logger.info("TechBrief automatic news checker stopped.")


app = FastAPI(
    title="TechBrief API",
    description="AI-Powered Tech News Summarizer",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health_router)
app.include_router(categories_router)
app.include_router(news_router)


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", "8000"))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
