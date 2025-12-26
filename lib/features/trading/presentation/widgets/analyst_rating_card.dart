import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/finnhub_models.dart';

/// Analyst Rating Card - Shows Buy/Hold/Sell consensus and distribution
class AnalystRatingCard extends StatelessWidget {
  final AnalystRecommendation? recommendation;
  final VoidCallback? onTap;

  const AnalystRatingCard({
    super.key,
    this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (recommendation == null) {
      return _buildEmptyState(isDark);
    }

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
                  'Analyst Ratings',
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: ThryveColors.textSecondary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Consensus badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getConsensusColor(recommendation!.consensus).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recommendation!.consensus,
                    style: ThryveTypography.titleMedium.copyWith(
                      color: _getConsensusColor(recommendation!.consensus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${recommendation!.totalAnalysts} Analysts',
                  style: ThryveTypography.bodySmall.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Distribution bars
            _buildDistributionBar(
              label: 'Buy',
              percentage: recommendation!.buyPercentage,
              color: ThryveColors.success,
            ),
            const SizedBox(height: 8),
            _buildDistributionBar(
              label: 'Hold',
              percentage: recommendation!.holdPercentage,
              color: ThryveColors.info,
            ),
            const SizedBox(height: 8),
            _buildDistributionBar(
              label: 'Sell',
              percentage: recommendation!.sellPercentage,
              color: ThryveColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar({
    required String label,
    required double percentage,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 45,
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: ThryveTypography.labelMedium.copyWith(
              color: color,
            ),
            textAlign: TextAlign.right,
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
            Icons.analytics_outlined,
            size: 40,
            color: ThryveColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No analyst ratings available',
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConsensusColor(String consensus) {
    switch (consensus.toLowerCase()) {
      case 'buy':
      case 'strong buy':
        return ThryveColors.success;
      case 'sell':
      case 'strong sell':
        return ThryveColors.error;
      default:
        return ThryveColors.info;
    }
  }
}
