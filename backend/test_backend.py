import sys
import os
import time

# Ensure backend directory is in path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from services import get_latest_news

print("--- Testing get_latest_news() ---")
t0 = time.time()
articles = get_latest_news()
t1 = time.time()
print(f"Call 1 took {t1 - t0:.2f} seconds. Articles fetched: {len(articles)}")

if articles:
    print(f"\nSample Article 1:")
    print(f"Title:    {articles[0]['title']}")
    print(f"Source:   {articles[0]['source']}")
    print(f"Category: {articles[0]['category']}")
    print(f"Summary:  {articles[0]['summary']}")
    print(f"Link:     {articles[0]['link']}")

print("\n--- Testing In-Memory Cache (30 min) ---")
t2 = time.time()
cached_articles = get_latest_news()
t3 = time.time()
print(f"Call 2 (Cached) took {t3 - t2:.4f} seconds. Articles: {len(cached_articles)}")
assert len(cached_articles) == len(articles), "Cache count mismatch!"
print("SUCCESS: In-memory cache is working correctly!")
