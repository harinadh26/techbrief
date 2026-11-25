"""
cache_service.py - In-memory thread-safe caching layer with TTL
Default TTL: 30 minutes (1800 seconds)
"""

import time
import threading
from typing import Any, Optional, Dict


class CacheService:
    def __init__(self, default_ttl_seconds: int = 1800):
        self._ttl = default_ttl_seconds
        self._cache: Dict[str, Any] = {}
        self._timestamps: Dict[str, float] = {}
        self._lock = threading.Lock()

    def get(self, key: str) -> Optional[Any]:
        with self._lock:
            if key not in self._cache:
                return None
            age = time.time() - self._timestamps[key]
            if age > self._ttl:
                # Expired
                del self._cache[key]
                del self._timestamps[key]
                return None
            return self._cache[key]

    def set(self, key: str, value: Any, ttl: Optional[int] = None) -> None:
        with self._lock:
            self._cache[key] = value
            self._timestamps[key] = time.time()

    def get_age(self, key: str) -> Optional[float]:
        with self._lock:
            if key in self._timestamps:
                return time.time() - self._timestamps[key]
            return None

    def clear(self) -> None:
        with self._lock:
            self._cache.clear()
            self._timestamps.clear()

    def count(self, key: str) -> int:
        with self._lock:
            val = self._cache.get(key)
            if isinstance(val, list):
                return len(val)
            return 1 if val is not None else 0


# Global shared singleton cache instance
cache_service = CacheService(default_ttl_seconds=1800)
