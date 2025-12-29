import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import '../core/services/theme_service.dart';
import '../core/services/session_service.dart';
import '../core/services/pin_service.dart';
import '../core/services/biometric_auth_service.dart';
import '../core/utils/auth_error_helper.dart';
import '../features/auth/presentation/pages/lock_screen.dart';
import '../features/auth/presentation/pages/passcode_setup_page.dart';
import '../features/auth/data/datasources/cognito_auth_datasource.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';

/// Root application widget for Thryve
class ThryveApp extends StatefulWidget {
  const ThryveApp({super.key});

  @override
  State<ThryveApp> createState() => _ThryveAppState();
}

class _ThryveAppState extends State<ThryveApp> {
  final SessionService _sessionService = SessionService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  bool _showLockScreen = false;
  bool _showPasscodeSetup = false;

  @override
  void initState() {
    super.initState();
    _sessionService.initialize(
      onLockRequired: () {
        if (mounted && !_showPasscodeSetup) {
          setState(() => _showLockScreen = true);
        }
      },
    );
  }

  void _handleUnlock() {
    setState(() => _showLockScreen = false);
  }

  void _handlePasscodeSet() {
    setState(() => _showPasscodeSetup = false);
  }

  void _handleForgotPasscode() {
    // Use the navigator key to show dialog with proper context
    final navContext = _navigatorKey.currentContext;
    if (navContext == null) return;
    
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    
    showDialog(
      context: navContext,
      barrierDismissible: true,
      builder: (dialogContext) {
        bool isVerifying = false;
        String? verifyError;
        
        return StatefulBuilder(
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
                  child: const Text('Cancel'),
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
                      final cognitoDatasource = CognitoAuthDatasource();
                      await cognitoDatasource.signIn(
                        email: email,
                        password: password,
                      );
                      
                      await PinService().removePin();
                      await BiometricAuthService().setBiometricEnabled(false);
                      
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        // Show passcode setup
                        setState(() {
                          _showLockScreen = false;
                          _showPasscodeSetup = true;
                        });
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Thryve',
          debugShowCheckedModeBanner: false,
          theme: ThryveTheme.light,
          darkTheme: ThryveTheme.dark,
          themeMode: ThemeService().themeMode,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            // Store navigator key context for dialogs
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_navigatorKey.currentContext == null) {
                // Context will be available on next frame
              }
            });
            
            return Navigator(
              key: _navigatorKey,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => Stack(
                  children: [
                    child ?? const SizedBox.shrink(),
                    if (_showPasscodeSetup)
                      PasscodeSetupPage(onPasscodeSet: _handlePasscodeSet),
                    if (_showLockScreen && !_showPasscodeSetup)
                      LockScreen(
                        onUnlocked: _handleUnlock,
                        onForgotPasscode: _handleForgotPasscode,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
