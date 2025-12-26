import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/finnhub_models.dart';

/// Events Section - Shows upcoming earnings and events
class EventsSection extends StatelessWidget {
  final List<EarningsEvent> earnings;
  final VoidCallback? onViewAll;

  const EventsSection({
    super.key,
    required this.earnings,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (earnings.isEmpty) {
      return const SizedBox.shrink();
    }

    final nextEarnings = earnings.isNotEmpty ? earnings.first : null;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Events',
                style: ThryveTypography.titleSmall.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
              ),
              if (onViewAll != null)
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
          const SizedBox(height: 16),
          
          if (nextEarnings != null)
            _buildEarningsCard(context, nextEarnings, isDark),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context, EarningsEvent event, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThryveColors.accent.withValues(alpha: 0.1),
            ThryveColors.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThryveColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThryveColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: ThryveColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earnings',
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Text(
                  event.date,
                  style: ThryveTypography.bodyMedium.copyWith(
                    color: ThryveColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (event.hour.isNotEmpty)
                  Text(
                    event.formattedHour,
                    style: ThryveTypography.caption.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThryveColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mic,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'Earnings call',
                  style: ThryveTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
