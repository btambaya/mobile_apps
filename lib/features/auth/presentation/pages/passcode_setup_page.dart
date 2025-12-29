import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/pin_service.dart';

/// Passcode setup screen - shown after first login/signup
/// User MUST set up a passcode before using the app
class PasscodeSetupPage extends StatefulWidget {
  final VoidCallback onPasscodeSet;

  const PasscodeSetupPage({super.key, required this.onPasscodeSet});

  @override
  State<PasscodeSetupPage> createState() => _PasscodeSetupPageState();
}

class _PasscodeSetupPageState extends State<PasscodeSetupPage> {
  final PinService _pinService = PinService();
  
  String _passcode = '';
  String _confirmPasscode = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    
    setState(() {
      _errorMessage = null;
      
      if (key == 'delete') {
        if (_isConfirming && _confirmPasscode.isNotEmpty) {
          _confirmPasscode = _confirmPasscode.substring(0, _confirmPasscode.length - 1);
        } else if (!_isConfirming && _passcode.isNotEmpty) {
          _passcode = _passcode.substring(0, _passcode.length - 1);
        }
      } else {
        if (_isConfirming) {
          if (_confirmPasscode.length < 4) {
            _confirmPasscode += key;
            if (_confirmPasscode.length == 4) {
              _verifyAndSave();
            }
          }
        } else {
          if (_passcode.length < 4) {
            _passcode += key;
            if (_passcode.length == 4) {
              _isConfirming = true;
            }
          }
        }
      }
    });
  }

  Future<void> _verifyAndSave() async {
    if (_passcode == _confirmPasscode) {
      await _pinService.setPin(_passcode);
      // Show biometric enrollment prompt
      if (mounted) {
        await _showBiometricPrompt();
      }
      widget.onPasscodeSet();
    } else {
      setState(() {
        _errorMessage = 'Passcodes don\'t match. Try again.';
        _confirmPasscode = '';
      });
    }
  }
  
  Future<void> _showBiometricPrompt() async {
    final BiometricAuthService biometricService = BiometricAuthService();
    final canAuth = await biometricService.canAuthenticate();
    
    if (!canAuth || !mounted) return;
    
    final typeName = await biometricService.getBiometricTypeName();
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: ThryveColors.accent, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text('Enable $typeName?')),
          ],
        ),
        content: Text(
          'Use $typeName for quick unlock instead of entering your passcode every time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThryveColors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text('Enable $typeName'),
          ),
        ],
      ),
    );
    
    if (result == true && mounted) {
      // Trigger actual biometric auth to verify it works
      final authenticated = await biometricService.authenticate(
        reason: 'Verify $typeName to enable it',
      );
      
      if (authenticated) {
        await biometricService.setBiometricEnabled(true);
        
        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$typeName enabled successfully!'),
              backgroundColor: ThryveColors.success,
            ),
          );
        }
      } else {
        // Auth failed or cancelled
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$typeName not enabled'),
              backgroundColor: ThryveColors.textSecondary,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPin = _isConfirming ? _confirmPasscode : _passcode;

    return Scaffold(
      backgroundColor: isDark ? ThryveColors.backgroundDark : ThryveColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: ThryveColors.accentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                _isConfirming ? 'Confirm Passcode' : 'Create Passcode',
                style: ThryveTypography.headlineMedium.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _isConfirming 
                    ? 'Enter the same passcode again'
                    : 'Set up a 4-digit passcode to secure your app',
                style: ThryveTypography.bodyMedium.copyWith(
                  color: ThryveColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Passcode dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < currentPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? ThryveColors.accent : Colors.transparent,
                      border: Border.all(
                        color: filled ? ThryveColors.accent : ThryveColors.divider,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.error),
                ),
              ],
              
              const Spacer(),
              
              // Keypad
              _buildKeypad(isDark),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(bool isDark) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'delete'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 80, height: 60);
              }
              return _buildKey(key, isDark);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String key, bool isDark) {
    final isDelete = key == 'delete';
    
    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      child: Container(
        width: 80,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDelete 
              ? Colors.transparent 
              : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isDelete
              ? Icon(
                  Icons.backspace_outlined,
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  size: 24,
                )
              : Text(
                  key,
                  style: ThryveTypography.headlineMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
