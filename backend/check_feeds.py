import feedparser
import httpx

urls = [
    ("TechCrunch", "https://techcrunch.com/feed/"),
    ("The Verge", "https://www.theverge.com/rss/index.xml"),
    ("VentureBeat General", "https://venturebeat.com/feed/"),
    ("VentureBeat AI", "https://venturebeat.com/category/ai/feed/")
]

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 TechBrief/1.0"
}

for name, url in urls:
    try:
        r = httpx.get(url, headers=headers, timeout=12.0, follow_redirects=True)
        feed = feedparser.parse(r.text)
        print(f"{name}: status {r.status_code}, entries: {len(feed.entries)}")
        if feed.entries:
            e = feed.entries[0]
            print(f"   Sample Title: {e.get('title')}")
            print(f"   Date: {e.get('published') or e.get('updated')}")
    except Exception as ex:
        print(f"{name} error: {ex}")
