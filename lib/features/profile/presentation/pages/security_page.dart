import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Security page - Manage password and 2FA
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;

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
          'Security',
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
            // Password section
            _buildSectionTitle('Password', isDark),
            _buildCard(isDark, [
              _buildListTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Last changed 30 days ago',
                trailing: const Icon(Icons.chevron_right, color: ThryveColors.textSecondary),
                onTap: () => _showChangePasswordSheet(),
              ),
            ]),
            const SizedBox(height: 24),

            // Biometric section
            _buildSectionTitle('Biometric Authentication', isDark),
            _buildCard(isDark, [
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Face ID / Touch ID',
                subtitle: 'Use biometrics to log in quickly',
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() => _biometricEnabled = value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Biometric login enabled' : 'Biometric login disabled'),
                      backgroundColor: ThryveColors.success,
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Two-factor authentication
            _buildSectionTitle('Two-Factor Authentication', isDark),
            _buildCard(isDark, [
              _buildSwitchTile(
                icon: Icons.security,
                title: '2FA via SMS',
                subtitle: 'Receive codes on +234 •••• 5678',
                value: _twoFactorEnabled,
                onChanged: (value) {
                  setState(() => _twoFactorEnabled = value);
                  if (value) {
                    _show2FASetupSheet();
                  }
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Login activity
            _buildSectionTitle('Login Activity', isDark),
            _buildCard(isDark, [
              _buildActivityItem(
                device: 'iPhone 15 Pro',
                location: 'Lagos, Nigeria',
                time: 'Now • Current session',
                isCurrentDevice: true,
                isDark: isDark,
              ),
              Divider(height: 1, color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider),
              _buildActivityItem(
                device: 'Chrome on MacBook',
                location: 'Lagos, Nigeria',
                time: 'Yesterday at 2:30 PM',
                isCurrentDevice: false,
                isDark: isDark,
              ),
              Divider(height: 1, color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider),
              _buildActivityItem(
                device: 'Safari on iPhone',
                location: 'Abuja, Nigeria',
                time: 'Dec 23, 2024',
                isCurrentDevice: false,
                isDark: isDark,
              ),
            ]),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All other devices have been logged out'),
                    backgroundColor: ThryveColors.warning,
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: ThryveColors.error, size: 20),
              label: Text(
                'Log out all other devices',
                style: ThryveTypography.labelLarge.copyWith(color: ThryveColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: ThryveTypography.labelLarge.copyWith(
          color: ThryveColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ThryveColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ThryveColors.accent, size: 20),
      ),
      title: Text(
        title,
        style: ThryveTypography.titleSmall.copyWith(
          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ThryveColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ThryveColors.accent, size: 20),
      ),
      title: Text(
        title,
        style: ThryveTypography.titleSmall.copyWith(
          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: ThryveColors.accent,
      ),
    );
  }

  Widget _buildActivityItem({
    required String device,
    required String location,
    required String time,
    required bool isCurrentDevice,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCurrentDevice ? ThryveColors.success : ThryveColors.textSecondary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              device.contains('iPhone') ? Icons.phone_iphone : Icons.laptop_mac,
              color: isCurrentDevice ? ThryveColors.success : ThryveColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device,
                      style: ThryveTypography.titleSmall.copyWith(
                        color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                      ),
                    ),
                    if (isCurrentDevice) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThryveColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Current',
                          style: ThryveTypography.labelSmall.copyWith(color: ThryveColors.success),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$location • $time',
                  style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? ThryveColors.backgroundDark
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThryveColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Change Password', style: ThryveTypography.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: ThryveColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThryveColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _show2FASetupSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('2FA setup will be available soon'),
        backgroundColor: ThryveColors.info,
      ),
    );
  }
}
