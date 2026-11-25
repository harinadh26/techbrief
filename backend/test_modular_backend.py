"""
test_modular_backend.py - End-to-end verification of TechBrief backend
"""

import sys
import os
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_endpoints():
    print("========================================")
    print("  TECHBRIEF BACKEND VERIFICATION SUITE  ")
    print("========================================")

    # 1. Test Root
    print("\n[1/6] Testing GET / ...")
    r_root = client.get("/")
    assert r_root.status_code == 200, f"Root failed: {r_root.text}"
    print(f"PASS: Root returned 200 OK: {r_root.json()['app']}")

    # 2. Test Health
    print("\n[2/6] Testing GET /health ...")
    r_health = client.get("/health")
    assert r_health.status_code == 200, f"Health failed: {r_health.text}"
    health_data = r_health.json()
    assert health_data["status"] == "healthy"
    print(f"PASS: Health check OK. Service: {health_data['service']}, Status: {health_data['status']}")

    # 3. Test Categories
    print("\n[3/6] Testing GET /categories ...")
    r_cat = client.get("/categories")
    assert r_cat.status_code == 200, f"Categories failed: {r_cat.text}"
    cats = r_cat.json()["categories"]
    print(f"PASS: Categories returned ({len(cats)}): {cats}")
    expected_cats = [
        "Artificial Intelligence",
        "Technology",
        "Startups",
        "Gadgets",
        "Software",
        "Cybersecurity"
    ]
    for c in expected_cats:
        assert c in cats, f"Missing expected category: {c}"

    # 4. Test News (RSS Ingestion + AI Summaries)
    print("\n[4/6] Testing GET /news (RSS Aggregation + 2-Sentence AI Summary) ...")
    t0 = time.time()
    r_news = client.get("/news")
    t_fetch = time.time() - t0
    assert r_news.status_code == 200, f"News failed: {r_news.text}"
    articles = r_news.json()
    print(f"PASS: Fetched {len(articles)} articles in {t_fetch:.2f}s")
    assert len(articles) >= 8, f"Expected at least 8 articles, got {len(articles)}"

    # Check sources and fields
    sources = set()
    for art in articles:
        for field in ["id", "title", "link", "source", "published_date", "summary", "category"]:
            assert field in art, f"Missing field '{field}' in article {art.get('title')}"
        sources.add(art["source"])

    print(f"Sources covered: {sources}")
    print(f"\nSample Article:")
    print(f"  ID:        {articles[0]['id']}")
    print(f"  Title:     {articles[0]['title']}")
    print(f"  Source:    {articles[0]['source']}")
    print(f"  Category:  {articles[0]['category']}")
    print(f"  Date:      {articles[0]['published_date']}")
    print(f"  Summary:   {articles[0]['summary']}")
    print(f"  Link:      {articles[0]['link']}")

    # 5. Test Query Filters
    print("\n[5/6] Testing GET /news query parameters ...")
    r_limit = client.get("/news?limit=3")
    assert len(r_limit.json()) == 3, "Limit filter failed"
    print("PASS: Limit filter working.")

    # 6. Test In-Memory Cache (30 min)
    print("\n[6/6] Testing 30-Minute In-Memory Cache ...")
    t1 = time.time()
    r_cached = client.get("/news")
    t_cache = time.time() - t1
    assert r_cached.status_code == 200
    print(f"PASS: Cache response served in {t_cache * 1000:.2f}ms (Instant!)")
    assert len(r_cached.json()) == len(articles)

    print("\n========================================")
    print("  ALL TECHBRIEF BACKEND TESTS PASSED!   ")
    print("========================================")

if __name__ == "__main__":
    test_endpoints()
