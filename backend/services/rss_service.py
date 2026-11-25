"""
rss_service.py - Aggregates tech news from TechCrunch, The Verge, and VentureBeat
Parses RSS feeds, sanitizes text, categorizes topics, and coordinates Claude AI summaries.
"""

import hashlib
import logging
import re
from datetime import datetime
from email.utils import parsedate_to_datetime
from typing import List, Dict, Optional
import feedparser
import httpx
from bs4 import BeautifulSoup

from models.article import Article
from .ai_service import ai_service
from .cache_service import cache_service

logger = logging.getLogger("techbrief.rss")

# Target RSS Sources
FEEDS = [
    {
        "name": "TechCrunch",
        "url": "https://techcrunch.com/feed/",
        "default_category": "Startups",
    },
    {
        "name": "The Verge",
        "url": "https://www.theverge.com/rss/index.xml",
        "default_category": "Gadgets",
    },
    {
        "name": "VentureBeat",
        "url": "https://venturebeat.com/feed/",
        "default_category": "Artificial Intelligence",
    },
]

OFFICIAL_CATEGORIES = [
    "Artificial Intelligence",
    "Technology",
    "Startups",
    "Gadgets",
    "Software",
    "Cybersecurity",
]

USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 TechBrief/1.0"
)


class RSSService:
    def __init__(self):
        self.http_client = httpx.Client(
            headers={"User-Agent": USER_AGENT},
            timeout=15.0,
            follow_redirects=True,
        )

    def clean_html(self, raw_html: str) -> str:
        if not raw_html:
            return ""
        try:
            soup = BeautifulSoup(raw_html, "html.parser")
            # Remove scripts and style tags
            for s in soup(["script", "style"]):
                s.extract()
            text = soup.get_text(separator=" ")
        except Exception:
            text = re.sub(r"<[^>]+>", " ", raw_html)
        return " ".join(text.split())

    def format_date(self, entry: Dict) -> str:
        """
        Extracts and formats publication date into a clean, human-readable string.
        """
        raw_date = entry.get("published") or entry.get("updated") or entry.get("pubDate")
        if not raw_date:
            return datetime.utcnow().strftime("%b %d, %Y")

        try:
            dt = parsedate_to_datetime(raw_date)
            return dt.strftime("%b %d, %Y • %I:%M %p")
        except Exception:
            pass

        try:
            # Try ISO 8601 (used by The Verge atom feeds)
            cleaned = raw_date.replace("Z", "+00:00")
            dt = datetime.fromisoformat(cleaned)
            return dt.strftime("%b %d, %Y • %I:%M %p")
        except Exception:
            pass

        return str(raw_date)[:22]

    def classify_category(self, title: str, text: str, default_cat: str) -> str:
        """
        Sensibly assigns one of the 6 official categories based on content keywords.
        Categories: Artificial Intelligence, Technology, Startups, Gadgets, Software, Cybersecurity
        """
        content = f"{title} {text}".lower()

        # 1. Cybersecurity
        if any(w in content for w in [
            "security", "cyber", "breach", "hack", "ransomware", "malware",
            "vulnerability", "phishing", "spyware", "cve-", "ddos", "exploit", "privacy"
        ]):
            return "Cybersecurity"

        # 2. Artificial Intelligence
        if any(w in content for w in [
            " ai ", "ai,", "ai.", "artificial intelligence", "llm", "gpt", "claude", "gemini",
            "openai", "anthropic", "machine learning", "deep learning", "neural network",
            "generative ai", "diffusion model", "copilot"
        ]):
            return "Artificial Intelligence"

        # 3. Startups
        if any(w in content for w in [
            "funding", "seed round", "series a", "series b", "series c", "venture capital",
            "raised $", "valuation", "investor", "founder", "startup", "y combinator", "ipo"
        ]):
            return "Startups"

        # 4. Gadgets
        if any(w in content for w in [
            "phone", "smartphone", "earbuds", "headphones", "headset", "smartwatch",
            "watch", "camera", "display", "foldable", "pixel 9", "iphone", "galaxy s",
            "hardware", "vr", "quest 3", "drone", "tablet", "ipad", "laptop", "macbook"
        ]):
            return "Gadgets"

        # 5. Software
        if any(w in content for w in [
            "software", "app ", "apps ", "update", "os", "windows 11", "macos", "android",
            "ios", "browser", "chrome", "linux", "programming", "developer", "api", "framework"
        ]):
            return "Software"

        # 6. Technology (General / Fallback)
        if default_cat in OFFICIAL_CATEGORIES:
            return default_cat
        return "Technology"

    def fetch_articles_from_feed(self, feed_info: Dict, limit_per_source: int = 4) -> List[Dict]:
        """
        Fetches up to `limit_per_source` items from an individual RSS source.
        """
        source_name = feed_info["name"]
        feed_url = feed_info["url"]
        default_cat = feed_info["default_category"]
        raw_items = []

        try:
            resp = self.http_client.get(feed_url)
            if resp.status_code != 200:
                logger.warning(f"Feed {source_name} returned HTTP {resp.status_code}")
                return []

            parsed = feedparser.parse(resp.text)
            entries = parsed.entries[:limit_per_source]

            for entry in entries:
                title = entry.get("title", "").strip()
                link = entry.get("link", "").strip()
                if not title or not link:
                    continue

                # Extract content
                content = ""
                if "content" in entry and len(entry["content"]) > 0:
                    content = entry["content"][0].get("value", "")
                elif "summary" in entry:
                    content = entry["summary"]
                elif "description" in entry:
                    content = entry["description"]

                clean_text = self.clean_html(content)
                pub_date = self.format_date(entry)
                category = self.classify_category(title, clean_text, default_cat)
                
                # Generate stable article id
                article_id = hashlib.md5(f"{source_name}:{link}".encode("utf-8")).hexdigest()[:12]

                raw_items.append({
                    "id": article_id,
                    "title": title,
                    "link": link,
                    "source": source_name,
                    "published_date": pub_date,
                    "clean_text": clean_text,
                    "category": category,
                })

        except Exception as e:
            logger.error(f"Error fetching {source_name} RSS: {e}")

        return raw_items

    def get_latest_news(self, force_refresh: bool = False) -> List[Article]:
        """
        Retrieves news from cache if valid, otherwise aggregates from all 3 feeds
        and summarizes via Claude AI.
        """
        cache_key = "all_articles"

        if not force_refresh:
            cached_data = cache_service.get(cache_key)
            if cached_data is not None:
                logger.info("Serving articles from 30-minute memory cache.")
                return cached_data

        logger.info("Fetching fresh RSS news from TechCrunch, The Verge, and VentureBeat...")
        all_raw: List[Dict] = []
        for feed in FEEDS:
            items = self.fetch_articles_from_feed(feed, limit_per_source=4)
            all_raw.extend(items)

        # Deduplicate by link
        seen_links = set()
        unique_raw = []
        for item in all_raw:
            if item["link"] not in seen_links:
                seen_links.add(item["link"])
                unique_raw.append(item)

        # Generate summaries
        articles: List[Article] = []
        for item in unique_raw:
            try:
                summary = ai_service.summarize_article(
                    title=item["title"],
                    content=item["clean_text"],
                )
                article = Article(
                    id=item["id"],
                    title=item["title"],
                    link=item["link"],
                    source=item["source"],
                    published_date=item["published_date"],
                    summary=summary,
                    category=item["category"],
                )
                articles.append(article)
            except Exception as e:
                logger.error(f"Error processing article '{item.get('title')}': {e}")

        # Store in cache
        if articles:
            cache_service.set(cache_key, articles)

        return articles


# Global shared singleton RSS service instance
rss_service = RSSService()
