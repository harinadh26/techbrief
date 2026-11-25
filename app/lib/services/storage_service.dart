/// storage_service.dart - Persistent Local Storage using SharedPreferences
/// Handles local offline bookmarks, theme mode persistence, and custom API base URL across Web & Mobile.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Loads all bookmarked articles from local persistent storage
  Future<List<Article>> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList(AppConstants.keyBookmarks);
      if (rawList == null || rawList.isEmpty) {
        return [];
      }
      return rawList.map((itemStr) {
        final Map<String, dynamic> jsonMap = json.decode(itemStr);
        final article = Article.fromJson(jsonMap);
        article.isBookmarked = true;
        return article;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves the complete list of bookmarks to local storage
  Future<bool> saveBookmarks(List<Article> bookmarks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = bookmarks.map((a) {
        final map = a.toJson();
        map['is_bookmarked'] = true;
        return json.encode(map);
      }).toList();
      return await prefs.setStringList(AppConstants.keyBookmarks, rawList);
    } catch (e) {
      return false;
    }
  }

  /// Adds a single article to bookmarks
  Future<List<Article>> addBookmark(Article article) async {
    final list = await loadBookmarks();
    if (!list.any((a) => a.id == article.id || a.link == article.link)) {
      article.isBookmarked = true;
      list.insert(0, article);
      await saveBookmarks(list);
    }
    return list;
  }

  /// Removes an article from bookmarks
  Future<List<Article>> removeBookmark(String articleId) async {
    final list = await loadBookmarks();
    list.removeWhere((a) => a.id == articleId);
    await saveBookmarks(list);
    return list;
  }

  /// Loads stored theme mode (default: false for light mode)
  Future<bool> loadIsDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.keyIsDarkMode) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Saves theme mode
  Future<void> saveIsDarkMode(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsDarkMode, isDark);
    } catch (_) {}
  }

  /// Loads configured backend Base URL
  Future<String> loadBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(AppConstants.keyBaseUrl);
      if (stored != null && stored.trim().isNotEmpty) {
        // If on Web in Chrome, ensure it doesn't try to use 10.0.2.2 or physical phone IP unless requested
        if (kIsWeb && stored.contains('10.0.2.2')) {
          return AppConstants.defaultLocalhostBaseUrl;
        }
        return stored.trim();
      }
      return AppConstants.defaultBaseUrl;
    } catch (e) {
      return AppConstants.defaultBaseUrl;
    }
  }

  /// Saves configured backend Base URL
  Future<void> saveBaseUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyBaseUrl, url.trim());
    } catch (_) {}
  }
}
