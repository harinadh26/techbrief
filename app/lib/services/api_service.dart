/// api_service.dart - Backend API Client for TechBrief
/// Cross-platform HTTP communication (Web, Android, iOS, Desktop)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storage = StorageService();

  /// Gets current active Base URL from local storage or returns platform default
  Future<String> getBaseUrl() async {
    return await _storage.loadBaseUrl();
  }

  /// Fetches latest summarized articles from GET /news
  Future<List<Article>> fetchNews({String? category, bool refresh = false}) async {
    final baseUrl = await getBaseUrl();
    
    // Build query parameters
    final Map<String, String> queryParams = {};
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams['category'] = category;
    }
    if (refresh) {
      queryParams['refresh'] = 'true';
    }

    final uri = Uri.parse('$baseUrl/news').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 45)); // LLM & feeds ingestion timeout allowance

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception(
            'Server responded with HTTP ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error connecting to $baseUrl: ${e.message}');
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('XMLHttpRequest') || errStr.contains('Failed to fetch') || errStr.contains('SocketException')) {
        throw Exception(
            'Cannot connect to backend server at $baseUrl.\n'
            '• Ensure FastAPI backend is running (python main.py)\n'
            '• Verify that http://localhost:8000/health opens in your browser.');
      }
      throw Exception('Failed to load news summaries: $e');
    }
  }

  /// Fetches official categories list from GET /categories
  Future<List<String>> fetchCategories() async {
    final baseUrl = await getBaseUrl();
    final uri = Uri.parse('$baseUrl/categories');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> list = data['categories'] ?? [];
        return ['All', ...list.map((c) => c.toString())];
      }
    } catch (_) {}
    return AppConstants.categories;
  }

  /// Checks server health status from GET /health
  Future<Map<String, dynamic>> checkHealth({String? customUrl}) async {
    final baseUrl = (customUrl != null && customUrl.isNotEmpty)
        ? customUrl
        : await getBaseUrl();
    final uri = Uri.parse('$baseUrl/health');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        return {'status': 'error', 'code': response.statusCode};
      }
    } catch (e) {
      return {'status': 'offline', 'error': e.toString()};
    }
  }
}
