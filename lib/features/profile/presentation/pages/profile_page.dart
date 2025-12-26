import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Profile page - User account management
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: ThryveTypography.titleLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(isDark),

            // KYC status
            _buildKycStatus(context, isDark),

            // Account stats
            _buildAccountStats(isDark),

            // Menu items
            _buildMenuSection(context, isDark),

            const SizedBox(height: 24),

            // Logout button
            _buildLogoutButton(context, isDark),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: ThryveColors.accentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'JD',
                    style: ThryveTypography.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? ThryveColors.surfaceDark : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? ThryveColors.backgroundDark : Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: ThryveColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            'John Doe',
            style: ThryveTypography.headlineSmall.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'john.doe@email.com',
            style: ThryveTypography.bodyMedium.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+234 801 234 5678',
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycStatus(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThryveColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThryveColors.success.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ThryveColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.verified_user,
                color: ThryveColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verified Account',
                    style: ThryveTypography.titleSmall.copyWith(
                      color: ThryveColors.success,
                    ),
                  ),
                  Text(
                    'Your identity has been verified',
                    style: ThryveTypography.bodySmall.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.check_circle,
              color: ThryveColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              isDark: isDark,
              title: 'Member Since',
              value: 'Dec 2023',
              icon: Icons.calendar_today,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              isDark: isDark,
              title: 'Total Investments',
              value: '\$4,532',
              icon: Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: ThryveColors.accent,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: ThryveTypography.titleLarge.copyWith(
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isDark) {
    final menuItems = [
      {'icon': Icons.person_outline, 'title': 'Edit Profile', 'route': AppRoutes.editProfile},
      {'icon': Icons.security, 'title': 'Security', 'route': AppRoutes.security},
      {'icon': Icons.account_balance, 'title': 'Bank Accounts', 'route': AppRoutes.bankAccounts},
      {'icon': Icons.history, 'title': 'Transaction History', 'route': AppRoutes.wallet},
      {'icon': Icons.card_giftcard, 'title': 'Referrals', 'route': AppRoutes.referrals},
      {'icon': Icons.help_outline, 'title': 'Help & Support', 'route': AppRoutes.helpSupport},
      {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'route': AppRoutes.notifications},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? ThryveColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
          ),
        ),
        child: Column(
          children: menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ThryveColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: ThryveColors.accent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: ThryveTypography.titleSmall.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: ThryveColors.textSecondary,
                  ),
                  onTap: () {
                    context.push(item['route'] as String);
                  },
                ),
                if (index < menuItems.length - 1)
                  Divider(
                    height: 1,
                    indent: 72,
                    color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout, color: ThryveColors.error),
          label: Text(
            'Log Out',
            style: ThryveTypography.button.copyWith(
              color: ThryveColors.error,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: ThryveColors.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            child: Text(
              'Log Out',
              style: TextStyle(color: ThryveColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
