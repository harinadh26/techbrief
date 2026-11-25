"""
main.py - TechBrief FastAPI Application Entry Point
Exposes /news, /health, /categories with CORS and Swagger documentation.
"""

import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Load environment variables (.env file)
load_dotenv()

from routers.health import router as health_router
from routers.categories import router as categories_router
from routers.news import router as news_router

app = FastAPI(
    title="TechBrief API",
    description="AI-Powered Tech News Summarizer using Claude Haiku and FastAPI. "
                "Aggregates news from TechCrunch, The Verge, and VentureBeat into 2-sentence summaries.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Enable CORS for cross-platform Flutter access (Android Emulator, iOS, Web, Localhost)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register modular routers
app.include_router(health_router)
app.include_router(categories_router)
app.include_router(news_router)


if __name__ == "__main__":
    import uvicorn
    # Bind to 0.0.0.0 so both localhost and Android emulators (10.0.2.2) can connect
    port = int(os.getenv("PORT", "8000"))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
