/// main.dart - TechBrief Flutter Application Entry Point
/// Initializes local configurations, manages Light/Dark ThemeMode,
/// and launches the branded SplashScreen.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'providers/news_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style on mobile platforms
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(const TechBriefApp());
}

class TechBriefApp extends StatefulWidget {
  const TechBriefApp({Key? key}) : super(key: key);

  @override
  State<TechBriefApp> createState() => _TechBriefAppState();
}

class _TechBriefAppState extends State<TechBriefApp> {
  late final NewsProvider _newsProvider;

  @override
  void initState() {
    super.initState();
    _newsProvider = NewsProvider();
    _newsProvider.init();
  }

  @override
  void dispose() {
    _newsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _newsProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'TechBrief',
          debugShowCheckedModeBanner: false,
          themeMode: _newsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: SplashScreen(newsProvider: _newsProvider),
        );
      },
    );
  }
}
