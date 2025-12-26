import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Similar Stocks Row - Shows related stocks from same sector
class SimilarStocksRow extends StatelessWidget {
  final List<SimilarStock> stocks;
  final Function(String symbol)? onStockTap;

  const SimilarStocksRow({
    super.key,
    required this.stocks,
    this.onStockTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (stocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Similar to',
            style: ThryveTypography.titleSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                final stock = stocks[index];
                return Padding(
                  padding: EdgeInsets.only(right: index < stocks.length - 1 ? 12 : 0),
                  child: _buildStockCard(stock, isDark),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(SimilarStock stock, bool isDark) {
    final isPositive = stock.changePercent >= 0;

    return GestureDetector(
      onTap: () => onStockTap?.call(stock.symbol),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? ThryveColors.divider.withValues(alpha: 0.5) : ThryveColors.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (stock.logoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      stock.logoUrl!,
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => _buildPlaceholderLogo(stock.symbol),
                    ),
                  )
                else
                  _buildPlaceholderLogo(stock.symbol),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stock.symbol,
                    style: ThryveTypography.labelLarge.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${stock.price.toStringAsFixed(2)}',
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? ThryveColors.success : ThryveColors.error).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(1)}%',
                    style: ThryveTypography.labelSmall.copyWith(
                      color: isPositive ? ThryveColors.success : ThryveColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderLogo(String symbol) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: ThryveColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol[0] : '?',
          style: ThryveTypography.labelSmall.copyWith(
            color: ThryveColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Model for similar stock display
class SimilarStock {
  final String symbol;
  final String? name;
  final double price;
  final double changePercent;
  final String? logoUrl;

  SimilarStock({
    required this.symbol,
    this.name,
    required this.price,
    required this.changePercent,
    this.logoUrl,
  });
}
