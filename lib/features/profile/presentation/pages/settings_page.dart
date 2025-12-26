import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Settings page - App preferences and configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _darkMode = false;

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
          'Settings',
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
            // Security section
            _buildSectionTitle('Security', isDark),
            _buildSettingsCard(isDark, [
              _buildSwitchTile(
                title: 'Biometric Login',
                subtitle: 'Use Face ID or fingerprint to log in',
                icon: Icons.fingerprint,
                value: _biometricEnabled,
                onChanged: (value) => setState(() => _biometricEnabled = value),
              ),
              _buildTileDivider(isDark),
              _buildNavigationTile(
                title: 'Change Password',
                icon: Icons.lock_outline,
                onTap: () => _showChangePasswordSheet(),
              ),
              _buildTileDivider(isDark),
              _buildNavigationTile(
                title: 'Two-Factor Authentication',
                icon: Icons.security,
                onTap: () => context.push(AppRoutes.security),
              ),
            ]),
            const SizedBox(height: 24),

            // Notifications section
            _buildSectionTitle('Notifications', isDark),
            _buildSettingsCard(isDark, [
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive push notifications on your device',
                icon: Icons.notifications_outlined,
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
              _buildTileDivider(isDark),
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Get updates via email',
                icon: Icons.email_outlined,
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
              ),
              _buildTileDivider(isDark),
              _buildSwitchTile(
                title: 'SMS Notifications',
                subtitle: 'Receive SMS alerts',
                icon: Icons.sms_outlined,
                value: _smsNotifications,
                onChanged: (value) => setState(() => _smsNotifications = value),
              ),
            ]),
            const SizedBox(height: 24),

            // Appearance section
            _buildSectionTitle('Appearance', isDark),
            _buildSettingsCard(isDark, [
              _buildSwitchTile(
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                icon: Icons.dark_mode_outlined,
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ]),
            const SizedBox(height: 24),

            // About section
            _buildSectionTitle('About', isDark),
            _buildSettingsCard(isDark, [
              _buildInfoTile(
                title: 'App Version',
                value: '1.0.0',
                icon: Icons.info_outline,
              ),
              _buildTileDivider(isDark),
              _buildNavigationTile(
                title: 'Legal Documents',
                icon: Icons.description_outlined,
                onTap: () => context.push(AppRoutes.legalDocuments),
              ),
              _buildTileDivider(isDark),
              _buildNavigationTile(
                title: 'Contact Support',
                icon: Icons.support_agent,
                onTap: () => _openEmailSupport(),
              ),
            ]),
            const SizedBox(height: 32),

            // Danger zone
            _buildSectionTitle('Danger Zone', isDark),
            _buildSettingsCard(isDark, [
              _buildDangerTile(
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                icon: Icons.delete_forever,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ]),
            const SizedBox(height: 24),
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

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
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

  Widget _buildTileDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 72,
      color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
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
        style: ThryveTypography.bodySmall.copyWith(
          color: ThryveColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: ThryveColors.accent,
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required IconData icon,
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
      trailing: const Icon(
        Icons.chevron_right,
        color: ThryveColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
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
      trailing: Text(
        value,
        style: ThryveTypography.bodyMedium.copyWith(
          color: ThryveColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDangerTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ThryveColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ThryveColors.error, size: 20),
      ),
      title: Text(
        title,
        style: ThryveTypography.titleSmall.copyWith(
          color: ThryveColors.error,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: ThryveTypography.bodySmall.copyWith(
          color: ThryveColors.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showChangePasswordSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? ThryveColors.backgroundDark : Colors.white,
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
              Text(
                'Change Password',
                style: ThryveTypography.headlineSmall.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  filled: true,
                  fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  filled: true,
                  fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  filled: true,
                  fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
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
                child: Text(
                  'Update Password',
                  style: ThryveTypography.button.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEmailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@thryve.app',
      query: 'subject=Support Request&body=Hello Thryve Support,',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email: support@thryve.app'),
            backgroundColor: ThryveColors.info,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
        ),
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
              'Delete',
              style: TextStyle(color: ThryveColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
