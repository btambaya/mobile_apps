import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/finnhub_models.dart';

/// Stock News Card - Displays a single news item
class StockNewsCard extends StatelessWidget {
  final StockNews news;
  final VoidCallback? onTap;

  const StockNewsCard({
    super.key,
    required this.news,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ThryveColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News image
            if (news.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  news.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                ),
              )
            else
              _buildPlaceholderImage(),
            
            const SizedBox(width: 12),
            
            // News content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.headline,
                    style: ThryveTypography.titleSmall.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThryveColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          news.source,
                          style: ThryveTypography.caption.copyWith(
                            color: ThryveColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        news.timeAgo,
                        style: ThryveTypography.caption.copyWith(
                          color: ThryveColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // External link indicator
            Icon(
              Icons.open_in_new,
              size: 16,
              color: ThryveColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: ThryveColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.article_outlined,
        color: ThryveColors.accent,
        size: 32,
      ),
    );
  }
}

/// Stock News List - Displays list of news with optional limit
class StockNewsList extends StatelessWidget {
  final List<StockNews> news;
  final int? limit;
  final Function(StockNews)? onNewsTap;
  final VoidCallback? onViewAll;

  const StockNewsList({
    super.key,
    required this.news,
    this.limit,
    this.onNewsTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayNews = limit != null ? news.take(limit!).toList() : news;

    if (news.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onViewAll != null && limit != null && news.length > limit!)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest News',
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'See all',
                    style: ThryveTypography.labelMedium.copyWith(
                      color: ThryveColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        ...displayNews.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StockNewsCard(
            news: item,
            onTap: () => onNewsTap?.call(item),
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.newspaper_outlined,
            size: 48,
            color: ThryveColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No news available',
            style: ThryveTypography.titleSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          Text(
            'Check back later for updates',
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
