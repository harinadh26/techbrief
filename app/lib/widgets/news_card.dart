/// news_card.dart - Modern News Card with 2-Sentence AI Summary

import 'package:flutter/material.dart';
import '../models/article.dart';
import '../theme/app_colors.dart';
import 'ai_badge.dart';

class NewsCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const NewsCard({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onBookmarkToggle,
  }) : super(key: key);

  Color _getSourceColor(String source) {
    if (source.contains('TechCrunch')) {
      return AppColors.techCrunchColor;
    } else if (source.contains('Verge')) {
      return AppColors.theVergeColor;
    } else if (source.contains('VentureBeat')) {
      return AppColors.ventureBeatColor;
    }
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sourceColor = _getSourceColor(article.source);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Source Tag, Date & Bookmark Action
                Row(
                  children: [
                    // Source Indicator Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: sourceColor.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: sourceColor.withOpacity(isDark ? 0.4 : 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        article.source,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? sourceColor.withOpacity(0.9) : sourceColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Publication Date
                    Expanded(
                      child: Text(
                        article.publishedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Category Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Bookmark Button
                    IconButton(
                      icon: Icon(
                        article.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: article.isBookmarked
                            ? AppColors.primaryBlue
                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                        size: 22,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: onBookmarkToggle,
                      tooltip: article.isBookmarked ? 'Remove bookmark' : 'Save bookmark',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Article Headline
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextNavy,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // AI Summary Container (2 Short Sentences)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withOpacity(0.6)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Badge
                      const AiBadge(compact: true),
                      const SizedBox(height: 8),
                      // 2-Sentence Summary Text
                      Text(
                        article.summary,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Tap to read prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Details & Article',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
