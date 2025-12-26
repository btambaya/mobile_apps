import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/finnhub_models.dart';

/// Key Stats Grid - Displays key financial metrics in a grid layout
class KeyStatsGrid extends StatelessWidget {
  final BasicFinancials? financials;
  final double? currentPrice;
  final double? dayHigh;
  final double? dayLow;
  final double? volume;

  const KeyStatsGrid({
    super.key,
    this.financials,
    this.currentPrice,
    this.dayHigh,
    this.dayLow,
    this.volume,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            'Key Stats',
            style: ThryveTypography.titleSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'P/E Ratio',
                  value: financials?.peRatio != null 
                      ? financials!.peRatio!.toStringAsFixed(2) 
                      : 'N/A',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'EPS',
                  value: financials?.eps != null 
                      ? '\$${financials!.eps!.toStringAsFixed(2)}' 
                      : 'N/A',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Market Cap',
                  value: financials?.formattedMarketCap ?? 'N/A',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Div. Yield',
                  value: financials?.dividendYield != null 
                      ? '${financials!.dividendYield!.toStringAsFixed(2)}%' 
                      : 'N/A',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 52 Week Range
          if (financials?.week52High != null && financials?.week52Low != null) ...[
            _build52WeekRange(isDark),
            const SizedBox(height: 16),
          ],
          
          // Day Range
          if (dayHigh != null && dayLow != null)
            _buildDayRange(isDark),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Volume',
                  value: _formatVolume(volume),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Avg Volume',
                  value: _formatVolume(financials?.avgVolume),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThryveTypography.caption.copyWith(
            color: ThryveColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: ThryveTypography.titleSmall.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _build52WeekRange(bool isDark) {
    final low = financials!.week52Low!;
    final high = financials!.week52High!;
    final range = high - low;
    final position = currentPrice != null && range > 0
        ? ((currentPrice! - low) / range).clamp(0.0, 1.0)
        : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '52 Week Range',
          style: ThryveTypography.caption.copyWith(
            color: ThryveColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '\$${low.toStringAsFixed(0)}',
              style: ThryveTypography.labelSmall.copyWith(
                color: ThryveColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: ThryveColors.divider,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: position,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: ThryveColors.accentGradient,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: position * 100 - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ThryveColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${high.toStringAsFixed(0)}',
              style: ThryveTypography.labelSmall.copyWith(
                color: ThryveColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayRange(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: "Day's Low",
            value: '\$${dayLow?.toStringAsFixed(2) ?? 'N/A'}',
            isDark: isDark,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            label: "Day's High",
            value: '\$${dayHigh?.toStringAsFixed(2) ?? 'N/A'}',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  String _formatVolume(double? vol) {
    if (vol == null) return 'N/A';
    if (vol >= 1000000) return '${(vol / 1000000).toStringAsFixed(2)}M';
    if (vol >= 1000) return '${(vol / 1000).toStringAsFixed(2)}K';
    return vol.toStringAsFixed(0);
  }
}
