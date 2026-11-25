/// article.dart - Domain Model for News Article in TechBrief

class Article {
  final String id;
  final String title;
  final String link;
  final String source;
  final String publishedDate;
  final String summary;
  final String category;
  bool isBookmarked;

  Article({
    required this.id,
    required this.title,
    required this.link,
    required this.source,
    required this.publishedDate,
    required this.summary,
    required this.category,
    this.isBookmarked = false,
  });

  /// Factory constructor to convert JSON map from FastAPI backend into an Article instance
  factory Article.fromJson(Map<String, dynamic> json) {
    // Generate fallback id if backend returns empty id
    final title = json['title'] ?? 'Untitled Article';
    final link = json['link'] ?? '';
    final id = json['id'] ?? (title.hashCode.toString());

    return Article(
      id: id.toString(),
      title: title,
      link: link,
      source: json['source'] ?? 'Tech News',
      publishedDate: json['published_date'] ?? 'Recently',
      summary: json['summary'] ?? 'No summary available.',
      category: json['category'] ?? 'Technology',
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }

  /// Converts Article instance to JSON map for local SharedPreferences persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'source': source,
      'published_date': publishedDate,
      'summary': summary,
      'category': category,
      'is_bookmarked': isBookmarked,
    };
  }

  /// Creates a copy of this Article with updated fields
  Article copyWith({
    String? id,
    String? title,
    String? link,
    String? source,
    String? publishedDate,
    String? summary,
    String? category,
    bool? isBookmarked,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      source: source ?? this.source,
      publishedDate: publishedDate ?? this.publishedDate,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
