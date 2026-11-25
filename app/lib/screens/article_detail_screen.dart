/// article_detail_screen.dart - Full Article Details & Browser Launcher

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_badge.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const ArticleDetailScreen({
    Key? key,
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  }) : super(key: key);

  Color _getSourceColor(String source) {
    if (source.contains('TechCrunch')) return AppColors.techCrunchColor;
    if (source.contains('Verge')) return AppColors.theVergeColor;
    if (source.contains('VentureBeat')) return AppColors.ventureBeatColor;
    return AppColors.primaryBlue;
  }

  Future<void> _launchOriginalArticle(BuildContext context) async {
    if (article.link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No article link provided.')),
      );
      return;
    }

    final Uri url = Uri.parse(article.link);
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open browser for: ${article.link}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching browser: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sourceColor = _getSourceColor(article.source);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Brief'),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isBookmarked ? AppColors.primaryBlue : null,
            ),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Save bookmark',
            onPressed: onBookmarkToggle,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'Open in browser',
            onPressed: () => _launchOriginalArticle(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata Row: Source & Date & Category
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sourceColor.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sourceColor.withOpacity(isDark ? 0.5 : 0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    article.source,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? sourceColor.withOpacity(0.9) : sourceColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  article.publishedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Complete Article Title
            Text(
              article.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                height: 1.3,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextNavy,
              ),
            ),

            const SizedBox(height: 24),

            // AI Summary Highlight Box (2 Short Sentences)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AiBadge(compact: false),
                  const SizedBox(height: 14),
                  Text(
                    article.summary,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Verified from RSS feed & summarized via Claude Haiku',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Summary Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this Story',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This brief is aggregated directly from ${article.source} RSS feed and filtered into "${article.category}". '
                    'To read the comprehensive reporting, journalism notes, and community discussion, open the full original article below.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Read Full Article Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _launchOriginalArticle(context),
                icon: const Icon(Icons.launch_rounded, size: 20),
                label: const Text(
                  'Read Full Article',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
