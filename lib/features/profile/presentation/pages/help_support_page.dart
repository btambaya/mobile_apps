import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Help & Support page - FAQ and contact options
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help & Support',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search, color: ThryveColors.textSecondary),
                filled: true,
                fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            Text(
              'Contact Us',
              style: ThryveTypography.labelLarge.copyWith(color: ThryveColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Live Chat',
                    subtitle: 'Available 24/7',
                    color: ThryveColors.accent,
                    isDark: isDark,
                    onTap: () => _showComingSoon(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: 'Get reply in 24h',
                    color: ThryveColors.info,
                    isDark: isDark,
                    onTap: () => _showComingSoon(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.phone_outlined,
                    title: 'Call Us',
                    subtitle: '+234 800 123 4567',
                    color: ThryveColors.success,
                    isDark: isDark,
                    onTap: () => _showComingSoon(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.article_outlined,
                    title: 'Help Center',
                    subtitle: 'Browse articles',
                    color: ThryveColors.warning,
                    isDark: isDark,
                    onTap: () => _showComingSoon(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // FAQ
            Text(
              'Frequently Asked Questions',
              style: ThryveTypography.labelLarge.copyWith(color: ThryveColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              question: 'How do I deposit money?',
              answer: 'You can deposit money using your debit card or bank transfer. Go to Wallet > Deposit and follow the instructions. Deposits are usually credited within 5 minutes.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'How long do withdrawals take?',
              answer: 'Withdrawals are typically processed within 1-3 business days. The exact time depends on your bank. You can track your withdrawal status in the Wallet section.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'What is fractional investing?',
              answer: 'Fractional investing allows you to buy a portion of a stock instead of a whole share. This means you can invest in expensive stocks like Apple or Amazon with as little as ₦1,000.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'Are my investments safe?',
              answer: 'Yes! Your investments are held with our partner broker, DriveWealth, which is regulated by FINRA and the SEC. Your account is also protected by SIPC insurance up to \$500,000.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'What are the trading hours?',
              answer: 'US stock market is open Monday to Friday, 2:30 PM - 9:00 PM Nigerian time. You can place orders anytime, and they will be executed when the market opens.',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ThryveColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: ThryveTypography.titleSmall.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: ThryveTypography.titleSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          iconColor: ThryveColors.accent,
          collapsedIconColor: ThryveColors.textSecondary,
          children: [
            Text(
              answer,
              style: ThryveTypography.bodyMedium.copyWith(
                color: ThryveColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature will be available soon!'),
        backgroundColor: ThryveColors.info,
      ),
    );
  }
}
