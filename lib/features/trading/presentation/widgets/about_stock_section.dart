import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/finnhub_models.dart';

/// About Stock Section - Company description and info
class AboutStockSection extends StatefulWidget {
  final CompanyProfile? profile;
  final String? description;

  const AboutStockSection({
    super.key,
    this.profile,
    this.description,
  });

  @override
  State<AboutStockSection> createState() => _AboutStockSectionState();
}

class _AboutStockSectionState extends State<AboutStockSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = widget.profile;

    if (profile == null && widget.description == null) {
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
            'About ${profile?.name ?? 'Company'}',
            style: ThryveTypography.titleSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Company info chips
          if (profile != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (profile.finnhubIndustry.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.business,
                    label: profile.finnhubIndustry,
                    isDark: isDark,
                  ),
                if (profile.exchange.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.show_chart,
                    label: profile.exchange,
                    isDark: isDark,
                  ),
                if (profile.country.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.flag_outlined,
                    label: profile.country,
                    isDark: isDark,
                  ),
              ],
            ),
          
          if (widget.description != null) ...[
            const SizedBox(height: 16),
            AnimatedCrossFade(
              firstChild: Text(
                widget.description!,
                style: ThryveTypography.bodyMedium.copyWith(
                  color: ThryveColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                widget.description!,
                style: ThryveTypography.bodyMedium.copyWith(
                  color: ThryveColors.textSecondary,
                  height: 1.5,
                ),
              ),
              crossFadeState: _isExpanded 
                  ? CrossFadeState.showSecond 
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? 'Show less' : 'Read more',
                style: ThryveTypography.labelMedium.copyWith(
                  color: ThryveColors.accent,
                ),
              ),
            ),
          ],
          
          // Website link
          if (profile?.weburl != null && profile!.weburl.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Open URL - would use url_launcher in production
              },
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 16,
                    color: ThryveColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile.weburl,
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.accent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ThryveColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: ThryveTypography.labelSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
