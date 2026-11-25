/// constants.dart - Global constants for TechBrief

import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'TechBrief';
  static const String appTagline = 'AI-Powered Tech News Summarizer';
  static const String appVersion = '1.0.0';

  // Network Defaults
  // http://localhost:8000 for Chrome Web / Desktop
  // http://10.167.171.225:8000 for Physical Android Device over local Wi-Fi
  // http://10.0.2.2:8000 for Android Emulator
  static const String defaultLocalhostBaseUrl = 'http://localhost:8000';
  static const String defaultPhysicalPhoneBaseUrl = 'http://10.167.171.225:8000';
  static const String defaultEmulatorBaseUrl = 'http://10.0.2.2:8000';

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return defaultLocalhostBaseUrl;
    }
    // On physical Android phone or emulator:
    return defaultPhysicalPhoneBaseUrl;
  }

  // Storage Keys
  static const String keyBookmarks = 'techbrief_bookmarks';
  static const String keyIsDarkMode = 'techbrief_is_dark_mode';
  static const String keyBaseUrl = 'techbrief_base_url';

  // News Categories
  static const List<String> categories = [
    'All',
    'Artificial Intelligence',
    'Technology',
    'Startups',
    'Gadgets',
    'Software',
    'Cybersecurity',
  ];

  // News Sources
  static const List<String> newsSources = [
    'TechCrunch',
    'The Verge',
    'VentureBeat',
  ];
}
