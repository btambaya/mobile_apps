import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/finnhub_models.dart';

/// Price Target Card - Shows analyst price targets with visual range indicator
class PriceTargetCard extends StatelessWidget {
  final PriceTarget? priceTarget;
  final double currentPrice;
  final VoidCallback? onTap;

  const PriceTargetCard({
    super.key,
    this.priceTarget,
    required this.currentPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (priceTarget == null) {
      return _buildEmptyState(isDark);
    }

    final upside = priceTarget!.upsidePercentage(currentPrice);
    final isPositive = upside >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Targets',
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? ThryveColors.success : ThryveColors.error).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${upside.toStringAsFixed(1)}%',
                    style: ThryveTypography.labelMedium.copyWith(
                      color: isPositive ? ThryveColors.success : ThryveColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Average target price
            Text(
              '\$${priceTarget!.targetMean.toStringAsFixed(2)}',
              style: ThryveTypography.headlineMedium.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
            Text(
              '~12 month avg. target',
              style: ThryveTypography.bodySmall.copyWith(
                color: ThryveColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Price range visualization
            _buildPriceRange(isDark, isPositive),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRange(bool isDark, bool isPositive) {
    final range = priceTarget!.targetHigh - priceTarget!.targetLow;
    if (range <= 0) return const SizedBox.shrink();
    
    // Calculate positions as percentages
    final currentPosition = ((currentPrice - priceTarget!.targetLow) / range).clamp(0.0, 1.0);
    final meanPosition = ((priceTarget!.targetMean - priceTarget!.targetLow) / range).clamp(0.0, 1.0);

    return Column(
      children: [
        // Range bar with markers
        SizedBox(
          height: 60,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background gradient line
                  Positioned(
                    top: 30,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ThryveColors.error.withValues(alpha: 0.5),
                            ThryveColors.warning.withValues(alpha: 0.5),
                            ThryveColors.success.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Current price marker
                  Positioned(
                    left: (width * currentPosition) - 6,
                    top: 20,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: ThryveColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: ThryveColors.accent.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${currentPrice.toStringAsFixed(0)}',
                          style: ThryveTypography.caption.copyWith(
                            color: ThryveColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Average target marker (dashed line visual)
                  Positioned(
                    left: (width * meanPosition) - 1,
                    top: 10,
                    child: Column(
                      children: [
                        Container(
                          width: 2,
                          height: 20,
                          color: isPositive ? ThryveColors.success : ThryveColors.error,
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isPositive ? ThryveColors.success : ThryveColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        
        // High/Low labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPriceLabel('Low', priceTarget!.targetLow, ThryveColors.error),
            _buildPriceLabel('Avg', priceTarget!.targetMean, isPositive ? ThryveColors.success : ThryveColors.error),
            _buildPriceLabel('High', priceTarget!.targetHigh, ThryveColors.success),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceLabel(String label, double price, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: ThryveTypography.caption.copyWith(
            color: ThryveColors.textTertiary,
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(0)}',
          style: ThryveTypography.labelMedium.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
        children: [
          Icon(
            Icons.trending_up_outlined,
            size: 40,
            color: ThryveColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No price targets available',
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
