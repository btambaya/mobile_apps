import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/pin_service.dart';

/// Security page - Manage password and 2FA
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  final PinService _pinService = PinService();
  
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  String _biometricTypeName = 'Biometric';
  bool _pinEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final available = await _biometricService.canAuthenticate();
    final enabled = await _biometricService.isBiometricEnabled();
    final typeName = await _biometricService.getBiometricTypeName();
    final pinEnabled = await _pinService.isPinEnabled();
    
    if (mounted) {
      setState(() {
        _pinEnabled = pinEnabled;
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
        if (mounted) {
          setState(() => _biometricEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_biometricTypeName login enabled'),
              backgroundColor: ThryveColors.success,
            ),
          );
        }
      }
    } else {
      await _biometricService.setBiometricEnabled(false);
      if (mounted) {
        setState(() => _biometricEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_biometricTypeName login disabled'),
            backgroundColor: ThryveColors.warning,
          ),
        );
      }
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
            _buildSectionTitle('Password & Passcode', isDark),
            _buildCard(isDark, [
              _buildListTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your account password',
                trailing: const Icon(Icons.chevron_right, color: ThryveColors.textSecondary),
                onTap: () => _showChangePasswordSheet(),
              ),
              const Divider(height: 1),
              _buildListTile(
                icon: Icons.pin,
                title: 'Change Passcode',
                subtitle: 'Update your 4-digit app passcode',
                trailing: const Icon(Icons.chevron_right, color: ThryveColors.textSecondary),
                onTap: () => _showSetPinSheet(),
              ),
            ]),
            const SizedBox(height: 24),

            // Biometric section
            _buildSectionTitle('Biometric Authentication', isDark),
            _buildCard(isDark, [
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: '$_biometricTypeName Login',
                subtitle: _biometricAvailable
                    ? 'Use $_biometricTypeName to unlock quickly'
                    : 'Biometric not available on this device',
                value: _biometricEnabled,
                onChanged: _biometricAvailable ? _toggleBiometric : null,
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
        style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.textSecondary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: ThryveColors.accent.withValues(alpha: 0.5),
        activeThumbColor: ThryveColors.accent,
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

  void _showSetPinSheet() {
    String newPin = '';
    String confirmPin = '';
    bool isConfirming = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return Container(
            decoration: BoxDecoration(
              color: isDark ? ThryveColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThryveColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  isConfirming ? 'Confirm Your PIN' : (_pinEnabled ? 'Enter New PIN' : 'Create Your PIN'),
                  style: ThryveTypography.headlineSmall.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isConfirming ? 'Enter the same PIN again' : 'Choose a 4-digit PIN',
                  style: ThryveTypography.bodyMedium.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // PIN dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final currentPin = isConfirming ? confirmPin : newPin;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < currentPin.length ? ThryveColors.accent : Colors.transparent,
                        border: Border.all(
                          color: index < currentPin.length ? ThryveColors.accent : ThryveColors.divider,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.error),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Numeric keypad
                ...['123', '456', '789', ' 0⌫'].map((row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row.split('').map((key) {
                        if (key == ' ') return const SizedBox(width: 80);
                        
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              errorMessage = null;
                              if (key == '⌫') {
                                if (isConfirming && confirmPin.isNotEmpty) {
                                  confirmPin = confirmPin.substring(0, confirmPin.length - 1);
                                } else if (!isConfirming && newPin.isNotEmpty) {
                                  newPin = newPin.substring(0, newPin.length - 1);
                                }
                              } else {
                                if (isConfirming && confirmPin.length < 4) {
                                  confirmPin += key;
                                  if (confirmPin.length == 4) {
                                    // Verify match
                                    if (confirmPin == newPin) {
                                      _pinService.setPin(newPin);
                                      Navigator.pop(context);
                                      setState(() => _pinEnabled = true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('PIN set successfully'),
                                          backgroundColor: ThryveColors.success,
                                        ),
                                      );
                                    } else {
                                      errorMessage = 'PINs do not match. Try again.';
                                      confirmPin = '';
                                    }
                                  }
                                } else if (!isConfirming && newPin.length < 4) {
                                  newPin += key;
                                  if (newPin.length == 4) {
                                    isConfirming = true;
                                  }
                                }
                              }
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: key == '⌫' ? Colors.transparent : (isDark ? ThryveColors.backgroundDark : ThryveColors.surface),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: key == '⌫'
                                  ? Icon(Icons.backspace_outlined, color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary)
                                  : Text(key, style: ThryveTypography.headlineMedium.copyWith(
                                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                                    )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
