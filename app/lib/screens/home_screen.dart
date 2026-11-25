/// home_screen.dart - Main TechBrief News Dashboard

import 'package:flutter/material.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final NewsProvider provider;

  const HomeScreen({
    Key? key,
    required this.provider,
  }) : super(key: key);

  void _navigateToDetail(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          article: article,
          isBookmarked: article.isBookmarked,
          onBookmarkToggle: () => provider.toggleBookmark(article),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final articles = provider.filteredArticles;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.aiBadgePurple],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: isDark ? Colors.white : AppColors.lightTextNavy,
                ),
                children: const [
                  TextSpan(text: 'Tech'),
                  TextSpan(
                    text: 'Brief',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Refresh Button
          IconButton(
            icon: provider.isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh news',
            onPressed: provider.isLoading || provider.isRefreshing
                ? null
                : () => provider.refreshNews(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshNews(),
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Subheader banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'LATEST AI BRIEFS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981), // Emerald online dot
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '3 Feeds • 30m Cache',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CategoryChips(
                  categories: provider.categories,
                  selectedCategory: provider.selectedCategory,
                  onCategorySelected: (cat) => provider.setCategory(cat),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 6)),

            // Content Area: Loading / Error / Empty / List
            if (provider.isLoading)
              const SliverToBoxAdapter(child: LoadingShimmerWidget())
            else if (provider.errorMessage != null && provider.articles.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.cloud_off_rounded,
                  title: 'Unable to Load News',
                  message: provider.errorMessage!,
                  buttonText: 'Retry Connection',
                  onButtonPressed: () => provider.loadNews(),
                ),
              )
            else if (articles.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.article_outlined,
                  title: 'No Articles Found',
                  message: 'No articles found under "${provider.selectedCategory}". Pull to refresh or try another category.',
                  buttonText: 'Show All News',
                  onButtonPressed: () => provider.setCategory('All'),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final article = articles[index];
                    return NewsCard(
                      article: article,
                      onTap: () => _navigateToDetail(context, article),
                      onBookmarkToggle: () => provider.toggleBookmark(article),
                    );
                  },
                  childCount: articles.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
