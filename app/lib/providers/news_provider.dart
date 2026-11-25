/// news_provider.dart - Central State Management for TechBrief
/// Handles news feeds, 30-min cached articles, search filtering, local persistent bookmarks,
/// dark/light theme switching, and backend URL settings.

import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class NewsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // News State
  List<Article> _articles = [];
  List<Article> _bookmarks = [];
  List<String> _categories = AppConstants.categories;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Filter & Search
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // App Settings
  bool _isDarkMode = false;
  int _activeNavIndex = 0;
  String _baseUrl = AppConstants.defaultEmulatorBaseUrl;
  Map<String, dynamic>? _lastHealthCheck;
  bool _isTestingConnection = false;

  // Getters
  List<Article> get articles => _articles;
  List<Article> get bookmarks => _bookmarks;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isDarkMode => _isDarkMode;
  int get activeNavIndex => _activeNavIndex;
  String get baseUrl => _baseUrl;
  Map<String, dynamic>? get lastHealthCheck => _lastHealthCheck;
  bool get isTestingConnection => _isTestingConnection;

  /// Initializes provider data from persistent local storage
  Future<void> init() async {
    _isDarkMode = await _storageService.loadIsDarkMode();
    _baseUrl = await _storageService.loadBaseUrl();
    _bookmarks = await _storageService.loadBookmarks();
    notifyListeners();

    // Fetch initial news and categories
    await Future.wait([
      _loadNewsInternal(showLoadingIndicator: true),
      _loadCategoriesInternal(),
    ]);
  }

  /// Sets the active bottom navigation tab
  void setActiveNavIndex(int index) {
    if (_activeNavIndex != index) {
      _activeNavIndex = index;
      notifyListeners();
    }
  }

  /// Toggles between light and dark themes and saves preference locally
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.saveIsDarkMode(_isDarkMode);
  }

  /// Sets the selected category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Updates current search query
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  /// Clears active search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Public reload news (e.g. from Pull-to-refresh or refresh button)
  Future<void> refreshNews() async {
    _isRefreshing = true;
    notifyListeners();
    await _loadNewsInternal(showLoadingIndicator: false, forceRefresh: true);
    _isRefreshing = false;
    notifyListeners();
  }

  /// Initial load or retry on error
  Future<void> loadNews() async {
    await _loadNewsInternal(showLoadingIndicator: true);
  }

  Future<void> _loadNewsInternal({
    bool showLoadingIndicator = true,
    bool forceRefresh = false,
  }) async {
    if (showLoadingIndicator) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _apiService.fetchNews(refresh: forceRefresh);
      
      // Sync bookmark states
      final bookmarkIds = _bookmarks.map((b) => b.id).toSet();
      final bookmarkLinks = _bookmarks.map((b) => b.link).toSet();

      for (var article in fetched) {
        if (bookmarkIds.contains(article.id) || bookmarkLinks.contains(article.link)) {
          article.isBookmarked = true;
        }
      }

      _articles = fetched;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCategoriesInternal() async {
    try {
      final cats = await _apiService.fetchCategories();
      if (cats.isNotEmpty) {
        _categories = cats;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Toggles an article's bookmark status and persists to disk
  Future<void> toggleBookmark(Article article) async {
    final existingIndex = _bookmarks.indexWhere(
      (b) => b.id == article.id || b.link == article.link,
    );

    if (existingIndex >= 0) {
      // Remove bookmark
      _bookmarks.removeAt(existingIndex);
      article.isBookmarked = false;
      // Update in main list
      for (var a in _articles) {
        if (a.id == article.id || a.link == article.link) {
          a.isBookmarked = false;
        }
      }
      await _storageService.saveBookmarks(_bookmarks);
    } else {
      // Add bookmark
      article.isBookmarked = true;
      _bookmarks.insert(0, article);
      // Update in main list
      for (var a in _articles) {
        if (a.id == article.id || a.link == article.link) {
          a.isBookmarked = true;
        }
      }
      await _storageService.saveBookmarks(_bookmarks);
    }
    notifyListeners();
  }

  /// Checks if an article is currently bookmarked
  bool isBookmarked(String articleId) {
    return _bookmarks.any((b) => b.id == articleId);
  }

  /// Removes a bookmark directly by id
  Future<void> removeBookmark(String articleId) async {
    _bookmarks.removeWhere((b) => b.id == articleId);
    for (var a in _articles) {
      if (a.id == articleId) {
        a.isBookmarked = false;
      }
    }
    notifyListeners();
    await _storageService.saveBookmarks(_bookmarks);
  }

  /// Updates configured Backend Base URL and reloads data
  Future<void> updateBaseUrl(String newUrl) async {
    _baseUrl = newUrl.trim();
    await _storageService.saveBaseUrl(_baseUrl);
    notifyListeners();
    await refreshNews();
  }

  /// Tests connectivity to backend server
  Future<void> testConnection([String? customUrl]) async {
    _isTestingConnection = true;
    _lastHealthCheck = null;
    notifyListeners();

    try {
      final result = await _apiService.checkHealth(
        customUrl: customUrl ?? _baseUrl,
      );
      _lastHealthCheck = result;
    } catch (e) {
      _lastHealthCheck = {'status': 'offline', 'error': e.toString()};
    } finally {
      _isTestingConnection = false;
      notifyListeners();
    }
  }

  /// Returns filtered articles based on selected category chip & search query
  List<Article> get filteredArticles {
    return _articles.where((article) {
      // 1. Category Filter
      final matchesCategory = _selectedCategory == 'All' ||
          article.category.toLowerCase() == _selectedCategory.toLowerCase();

      if (!matchesCategory) return false;

      // 2. Search Query Filter (Title, Source, Category, Summary)
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      return article.title.toLowerCase().contains(query) ||
          article.source.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query);
    }).toList();
  }

  /// Returns filtered bookmarks based on search query
  List<Article> get filteredBookmarks {
    if (_searchQuery.isEmpty) return _bookmarks;
    final query = _searchQuery.toLowerCase();
    return _bookmarks.where((b) {
      return b.title.toLowerCase().contains(query) ||
          b.source.toLowerCase().contains(query) ||
          b.category.toLowerCase().contains(query) ||
          b.summary.toLowerCase().contains(query);
    }).toList();
  }
}
