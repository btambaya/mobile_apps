import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/utils/auth_error_helper.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';

/// Settings page - App preferences and configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  final ThemeService _themeService = ThemeService();
  
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  String _biometricTypeName = 'Biometric';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final available = await _biometricService.canAuthenticate();
    final enabled = await _biometricService.isBiometricEnabled();
    final typeName = await _biometricService.getBiometricTypeName();
    
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled && available;
        _biometricTypeName = typeName;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Authenticate first before enabling
      final success = await _biometricService.authenticate(
        reason: 'Verify your identity to enable $_biometricTypeName login',
      );
      if (success) {
        await _biometricService.setBiometricEnabled(true);
        setState(() => _biometricEnabled = true);
      }
    } else {
      await _biometricService.setBiometricEnabled(false);
      setState(() => _biometricEnabled = false);
    }
  }

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
                title: '$_biometricTypeName Login',
                subtitle: _biometricAvailable 
                    ? 'Use $_biometricTypeName to log in'
                    : 'Biometric not available on this device',
                icon: Icons.fingerprint,
                value: _biometricEnabled,
                onChanged: _biometricAvailable ? _toggleBiometric : null,
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
                value: _themeService.isDarkMode,
                onChanged: (value) async {
                  await _themeService.setDarkMode(value);
                  setState(() {}); // Refresh UI to reflect new switch value
                },
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

            // Sign Out
            _buildSignOutButton(isDark),
            const SizedBox(height: 24),

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
    ValueChanged<bool>? onChanged,
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
        activeTrackColor: ThryveColors.accent.withValues(alpha: 0.5),
        activeThumbColor: ThryveColors.accent,
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
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThryveColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMessage!,
                      style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    filled: true,
                    fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    filled: true,
                    fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    filled: true,
                    fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    // Validate
                    if (currentPasswordController.text.isEmpty ||
                        newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      setSheetState(() => errorMessage = 'Please fill in all fields');
                      return;
                    }
                    
                    if (newPasswordController.text != confirmPasswordController.text) {
                      setSheetState(() => errorMessage = 'New passwords do not match');
                      return;
                    }
                    
                    if (newPasswordController.text.length < 8) {
                      setSheetState(() => errorMessage = 'Password must be at least 8 characters');
                      return;
                    }
                    
                    setSheetState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    
                    try {
                      final authRepo = AuthRepositoryImpl();
                      await authRepo.changePassword(
                        oldPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                      );
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password changed successfully'),
                            backgroundColor: ThryveColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      setSheetState(() {
                        isLoading = false;
                        errorMessage = AuthErrorHelper.getErrorMessage(e);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThryveColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Update Password',
                          style: ThryveTypography.button.copyWith(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
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

  Widget _buildSignOutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => _showSignOutDialog(),
        icon: const Icon(Icons.logout, color: ThryveColors.error),
        label: Text(
          'Sign Out',
          style: ThryveTypography.button.copyWith(
            color: ThryveColors.error,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: ThryveColors.error, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThryveColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Sign out - clear session but keep passcode
              final authRepo = AuthRepositoryImpl();
              await authRepo.signOut();
              await SessionService().logout();
              // Navigate to login (not onboarding - they're a returning user)
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: ThryveColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
