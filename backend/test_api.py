import sys
import os

# Ensure backend directory is in path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi.testclient import TestClient
from main import app

print("Initializing TestClient for FastAPI...")
client = TestClient(app)

print("--- Testing GET / ---")
response_root = client.get("/")
print("Status Code:", response_root.status_code)
print("Response JSON:", response_root.json())
assert response_root.status_code == 200, "Root endpoint failed!"

print("\n--- Testing GET /news ---")
response_news = client.get("/news")
print("Status Code:", response_news.status_code)
articles = response_news.json()
print("Articles received:", len(articles))
assert response_news.status_code == 200, "News endpoint failed!"
assert len(articles) > 0, "No articles returned!"

sample = articles[0]
print("\nSample Article Structure:")
print(" - Title:   ", sample.get("title")[:60] + "...")
print(" - Source:  ", sample.get("source"))
print(" - Category:", sample.get("category"))
print(" - Summary: ", sample.get("summary"))
print(" - Link:    ", sample.get("link"))

for key in ["title", "source", "category", "summary", "link"]:
    assert key in sample, f"Missing key '{key}' in article response!"

print("\nALL BACKEND API TESTS PASSED SUCCESSFULLY!")
