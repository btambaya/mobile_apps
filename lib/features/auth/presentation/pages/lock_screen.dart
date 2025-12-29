import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/pin_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/utils/auth_error_helper.dart';
import '../../data/datasources/cognito_auth_datasource.dart';

/// Lock screen - requires passcode or biometric to unlock
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback? onForgotPasscode;
  
  const LockScreen({
    super.key,
    required this.onUnlocked,
    this.onForgotPasscode,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final PinService _pinService = PinService();
  final BiometricAuthService _biometricService = BiometricAuthService();
  
  String _enteredPin = '';
  String? _errorMessage;
  bool _biometricAvailable = false;
  String _biometricTypeName = 'Biometric';
  bool _isAuthenticating = false;
  
  // CRITICAL: Session-level guard for Android
  // Prevents re-triggering after Activity resume when biometric dialog dismisses
  bool _biometricAttemptedThisSession = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  /// Check if biometric is available and auto-trigger if enabled
  Future<void> _checkBiometricAvailability() async {
    final canAuth = await _biometricService.canAuthenticate();
    final enabled = await _biometricService.isBiometricEnabled();
    final typeName = await _biometricService.getBiometricTypeName();
    
    if (mounted) {
      setState(() {
        _biometricAvailable = canAuth && enabled;
        _biometricTypeName = typeName;
      });
      
      // Auto-trigger biometric if available and enabled
      // Safe because _biometricAttemptedThisSession prevents retriggers
      // and SessionService flags prevent lock() during auth
      if (_biometricAvailable) {
        _authenticateWithBiometric();
      }
    }
  }

  /// Authenticate with biometric - ONLY call from explicit button tap
  Future<void> _authenticateWithBiometric() async {
    // Prevent concurrent calls
    if (_isAuthenticating) return;
    
    // CRITICAL: Prevent Android resume retrigger
    // One biometric attempt per screen session
    if (_biometricAttemptedThisSession) return;
    
    _isAuthenticating = true;
    _biometricAttemptedThisSession = true;
    
    try {
      final success = await _biometricService.authenticate(
        reason: 'Unlock Thryve',
      );
      
      if (success && mounted) {
        _unlock();
      }
      // If failed/cancelled, user can tap button again (resets session flag)
    } finally {
      if (mounted) {
        _isAuthenticating = false;
      }
    }
  }
  
  /// Manual biometric button tap - resets session flag for retry
  void _onBiometricButtonTap() {
    _biometricAttemptedThisSession = false;  // Reset for manual retry
    _authenticateWithBiometric();
  }
  
  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    
    setState(() {
      _errorMessage = null;
      
      if (key == 'delete') {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else if (_enteredPin.length < 4) {
        _enteredPin += key;
        if (_enteredPin.length == 4) {
          _verifyPin();
        }
      }
    });
  }

  Future<void> _verifyPin() async {
    final isValid = await _pinService.verifyPin(_enteredPin);
    
    if (isValid) {
      _unlock();
    } else {
      setState(() {
        _errorMessage = 'Incorrect passcode';
        _enteredPin = '';
      });
    }
  }

  void _unlock() {
    SessionService().unlock();
    widget.onUnlocked();
  }

  /// Show biometric enrollment prompt after passcode reset
  Future<void> _showBiometricEnrollmentPrompt() async {
    final canAuth = await _biometricService.canAuthenticate();
    
    if (!canAuth || !mounted) return;
    
    final typeName = await _biometricService.getBiometricTypeName();
    
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
      final authenticated = await _biometricService.authenticate(
        reason: 'Verify $typeName to enable it',
      );
      
      if (authenticated) {
        await _biometricService.setBiometricEnabled(true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$typeName enabled successfully!'),
              backgroundColor: ThryveColors.success,
            ),
          );
        }
      }
    }
  }

  void _showForgotPasscodeSheet() {
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    bool isVerifying = false;
    String? verifyError;

    // Use showDialog instead of showModalBottomSheet since LockScreen
    // is rendered in a Stack overlay without Navigator context
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: isDark ? ThryveColors.surfaceDark : Colors.white,
            title: Text(
              'Reset Passcode',
              style: ThryveTypography.headlineSmall.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your account credentials to verify your identity.',
                    style: ThryveTypography.bodyMedium.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Email field
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      errorText: verifyError,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isVerifying ? null : () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text;
                  
                  if (email.isEmpty || password.isEmpty) {
                    setDialogState(() {
                      verifyError = 'Please enter both email and password';
                    });
                    return;
                  }
                  
                  setDialogState(() {
                    isVerifying = true;
                    verifyError = null;
                  });
                  
                  try {
                    // Verify password by attempting to sign in with Cognito
                    final cognitoDatasource = CognitoAuthDatasource();
                    await cognitoDatasource.signIn(
                      email: email,
                      password: password,
                    );
                    
                    // Password verified! Remove the passcode
                    await _pinService.removePin();
                    
                    // Also disable biometric since passcode is removed
                    await BiometricAuthService().setBiometricEnabled(false);
                    
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      _showNewPasscodeSetup();
                    }
                  } catch (e) {
                    setDialogState(() {
                      isVerifying = false;
                      verifyError = AuthErrorHelper.getErrorMessage(e);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThryveColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Verify & Reset',
                        style: ThryveTypography.button.copyWith(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNewPasscodeSetup() {
    String newPin = '';
    String confirmPin = '';
    bool isConfirming = false;
    String? error;

    // Use showDialog instead of showModalBottomSheet since LockScreen
    // is rendered in a Stack overlay without Navigator context
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          final currentPin = isConfirming ? confirmPin : newPin;
          
          return Dialog(
            backgroundColor: isDark ? ThryveColors.surfaceDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(dialogContext).size.height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  
                  Text(
                    isConfirming ? 'Confirm Passcode' : 'Create New Passcode',
                    style: ThryveTypography.headlineMedium.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isConfirming ? 'Enter the same passcode' : 'Choose a 4-digit passcode',
                    style: ThryveTypography.bodyMedium.copyWith(
                      color: ThryveColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < currentPin.length ? ThryveColors.accent : Colors.transparent,
                        border: Border.all(
                          color: i < currentPin.length ? ThryveColors.accent : ThryveColors.divider,
                          width: 2,
                        ),
                      ),
                    )),
                  ),
                  
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(error!, style: ThryveTypography.bodySmall.copyWith(color: ThryveColors.error)),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Keypad
                  ...['123', '456', '789', ' 0⌫'].map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row.split('').map((key) {
                        if (key == ' ') return const SizedBox(width: 64);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setDialogState(() {
                              error = null;
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
                                    if (confirmPin == newPin) {
                                      _pinService.setPin(newPin).then((_) async {
                                        Navigator.pop(dialogContext);
                                        // Show biometric prompt before unlocking
                                        await _showBiometricEnrollmentPrompt();
                                        _unlock();
                                      });
                                    } else {
                                      error = 'Passcodes don\'t match';
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
                            width: 64,
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: key == '⌫' ? Colors.transparent : (isDark ? ThryveColors.backgroundDark : ThryveColors.surface),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: key == '⌫'
                                  ? Icon(Icons.backspace_outlined, color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary)
                                  : Text(key, style: ThryveTypography.headlineSmall.copyWith(
                                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                                    )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )),
                  
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThryveColors.backgroundDark : ThryveColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Lock icon
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
              
              const SizedBox(height: 24),
              
              Text(
                'Enter Passcode',
                style: ThryveTypography.headlineMedium.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Passcode dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _enteredPin.length;
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
              
              const SizedBox(height: 16),
              
              // Biometric button
              if (_biometricAvailable)
                TextButton.icon(
                  // FIX 3: Do NOT reset session on button press
                  // Session should only reset when lock screen is dismissed
                  onPressed: _onBiometricButtonTap,
                  icon: Icon(
                    _biometricTypeName.contains('Face') ? Icons.face : Icons.fingerprint,
                    color: ThryveColors.accent,
                  ),
                  label: Text(
                    'Use $_biometricTypeName',
                    style: ThryveTypography.labelLarge.copyWith(color: ThryveColors.accent),
                  ),
                ),
              
              // Forgot passcode
              TextButton(
                onPressed: widget.onForgotPasscode ?? _showForgotPasscodeSheet,
                child: Text(
                  'Forgot Passcode?',
                  style: ThryveTypography.labelLarge.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
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


