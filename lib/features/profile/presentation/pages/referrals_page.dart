import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Referrals page - Invite friends and earn rewards
class ReferralsPage extends StatelessWidget {
  const ReferralsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const referralCode = 'THRYVE-JOHN25';
    const referralLink = 'https://thryve.app/invite/JOHN25';

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
          'Referrals',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: ThryveColors.accentGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Earn \$10 for Every Friend',
                    style: ThryveTypography.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Invite friends to Thryve and you both get \$10 when they complete their first trade.',
                    style: ThryveTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Referral code
            Container(
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
                  Text(
                    'Your Referral Code',
                    style: ThryveTypography.labelLarge.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: ThryveColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ThryveColors.accent.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          referralCode,
                          style: ThryveTypography.headlineSmall.copyWith(
                            color: ThryveColors.accent,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.copy, color: ThryveColors.accent),
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Referral code copied!'),
                                backgroundColor: ThryveColors.success,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: referralLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Link copied!'),
                                backgroundColor: ThryveColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.link),
                          label: const Text('Copy Link'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Copy message with link for sharing
                            const shareText = 'Join Thryve and invest in US stocks from Nigeria! Use my referral link and we both get \$10: $referralLink';
                            Clipboard.setData(const ClipboardData(text: shareText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share message copied! Paste it in your messaging app.'),
                                backgroundColor: ThryveColors.success,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThryveColors.accent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Friends Invited',
                    value: '5',
                    icon: Icons.people_outline,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Rewards Earned',
                    value: '\$30',
                    icon: Icons.attach_money,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // How it works
            _buildSectionTitle('How It Works', isDark),
            const SizedBox(height: 12),
            _buildStep(
              number: '1',
              title: 'Share Your Code',
              description: 'Send your unique referral code to friends',
              isDark: isDark,
            ),
            _buildStep(
              number: '2',
              title: 'Friend Signs Up',
              description: 'They create an account using your code',
              isDark: isDark,
            ),
            _buildStep(
              number: '3',
              title: 'They Complete a Trade',
              description: 'After their first trade, you both earn \$10',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Referral history
            _buildSectionTitle('Recent Referrals', isDark),
            const SizedBox(height: 12),
            _buildReferralItem(
              name: 'Sarah M.',
              status: 'Completed',
              reward: '+\$10',
              date: 'Dec 20, 2024',
              isDark: isDark,
            ),
            _buildReferralItem(
              name: 'Michael O.',
              status: 'Completed',
              reward: '+\$10',
              date: 'Dec 15, 2024',
              isDark: isDark,
            ),
            _buildReferralItem(
              name: 'Amaka C.',
              status: 'Pending First Trade',
              reward: '\$10 pending',
              date: 'Dec 24, 2024',
              isPending: true,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
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
          Icon(icon, color: ThryveColors.accent, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: ThryveTypography.headlineSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: ThryveTypography.titleMedium.copyWith(
          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: ThryveColors.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: ThryveTypography.titleSmall.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralItem({
    required String name,
    required String status,
    required String reward,
    required String date,
    required bool isDark,
    bool isPending = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThryveColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0],
                style: ThryveTypography.titleSmall.copyWith(color: ThryveColors.accent),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: ThryveTypography.titleSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPending
                            ? ThryveColors.warning.withValues(alpha: 0.1)
                            : ThryveColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: ThryveTypography.labelSmall.copyWith(
                          color: isPending ? ThryveColors.warning : ThryveColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            reward,
            style: ThryveTypography.titleSmall.copyWith(
              color: isPending ? ThryveColors.warning : ThryveColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
