/// bookmarks_screen.dart - Saved Reading List for TechBrief

import 'package:flutter/material.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  final NewsProvider provider;

  const BookmarksScreen({Key? key, required this.provider}) : super(key: key);

  void _navigateToDetail(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          article: article,
          isBookmarked: true,
          onBookmarkToggle: () => provider.toggleBookmark(article),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = provider.bookmarks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Bookmarks'),
        actions: [
          if (bookmarks.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${bookmarks.length} saved',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: bookmarks.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.bookmark_border_rounded,
              title: 'No Bookmarks Yet',
              message:
                  'Tap the bookmark icon on any news card to save articles here for quick offline reference.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final article = bookmarks[index];
                return Dismissible(
                  key: Key(article.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  onDismissed: (_) {
                    provider.removeBookmark(article.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed "${article.title}"'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: NewsCard(
                    article: article,
                    onTap: () => _navigateToDetail(context, article),
                    onBookmarkToggle: () => provider.toggleBookmark(article),
                  ),
                );
              },
            ),
    );
  }
}
