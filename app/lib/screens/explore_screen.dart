/// explore_screen.dart - News Categories & Search Screen for TechBrief

import 'package:flutter/material.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/news_card.dart';
import '../widgets/search_bar_widget.dart';
import 'article_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final NewsProvider provider;

  const ExploreScreen({Key? key, required this.provider}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.provider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          article: article,
          isBookmarked: article.isBookmarked,
          onBookmarkToggle: () => widget.provider.toggleBookmark(article),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final articles = widget.provider.filteredArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore & Search'),
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Search by title, source, or topic...',
            onChanged: (val) {
              setState(() {});
              widget.provider.setSearchQuery(val);
            },
            onClear: () {
              _searchController.clear();
              setState(() {});
              widget.provider.clearSearch();
            },
          ),

          // Categories Horizontal Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: widget.provider.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = widget.provider.categories[index];
                final isSelected =
                    cat.toLowerCase() == widget.provider.selectedCategory.toLowerCase();

                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => widget.provider.setCategory(cat),
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextNavy),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Search stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${articles.length} ${articles.length == 1 ? 'article' : 'articles'} found',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                if (widget.provider.searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    'for "${widget.provider.searchQuery}"',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Articles List / Empty Results
          Expanded(
            child: articles.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Matching Articles',
                    message: widget.provider.searchQuery.isNotEmpty
                        ? 'No articles match "${widget.provider.searchQuery}". Try different keywords or switch categories.'
                        : 'No stories available in this category.',
                    buttonText: 'Clear Search',
                    onButtonPressed: () {
                      _searchController.clear();
                      widget.provider.clearSearch();
                      widget.provider.setCategory('All');
                    },
                  )
                : ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return NewsCard(
                        article: article,
                        onTap: () => _navigateToDetail(context, article),
                        onBookmarkToggle: () =>
                            widget.provider.toggleBookmark(article),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
