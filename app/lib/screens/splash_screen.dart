/// splash_screen.dart - Branded Startup Splash Screen for TechBrief

import 'package:flutter/material.dart';
import '../providers/news_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  final NewsProvider newsProvider;

  const SplashScreen({Key? key, required this.newsProvider}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Navigate to Main Navigation Screen after 2.0s
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) =>
                MainNavigationScreen(provider: widget.newsProvider),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branded Logo Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.aiBadgePurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.newspaper_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Title
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tech',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : AppColors.lightTextNavy,
                      ),
                    ),
                    Text(
                      'Brief',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                // Subtle Loading Indicator
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.primaryBlue : AppColors.primaryBlueHover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
