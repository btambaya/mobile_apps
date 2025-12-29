import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/device_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

/// Login page with email/password authentication via AWS Cognito
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final BiometricAuthService _biometricService = BiometricAuthService();
  
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  String _biometricTypeName = 'Biometric';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final canAuth = await _biometricService.canAuthenticate();
    final isEnabled = await _biometricService.isBiometricEnabled();
    final typeName = await _biometricService.getBiometricTypeName();
    
    // Also check if there's a stored session (for biometric login to work)
    bool hasStoredSession = false;
    try {
      final authRepo = AuthRepositoryImpl();
      final user = await authRepo.getCurrentUser();
      hasStoredSession = user != null;
    } catch (_) {
      hasStoredSession = false;
    }
    
    if (mounted) {
      setState(() {
        // Only show biometric if: device supports it AND user enabled it AND has stored session
        _biometricAvailable = canAuth && isEnabled && hasStoredSession;
        _biometricTypeName = typeName;
      });
    }
  }

  Future<void> _handleBiometricLogin(BuildContext blocContext) async {
    final success = await _biometricService.authenticate(
      reason: 'Authenticate to login to Thryve',
    );
    
    if (success && mounted) {
      // Biometric succeeded - trigger biometric login event
      blocContext.read<AuthBloc>().add(const AuthBiometricLoginRequested());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext blocContext) {
    if (_formKey.currentState?.validate() ?? false) {
      blocContext.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _showDevicePickerDialog(BuildContext context, AuthUser user, List<dynamic> devices) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isRemoving = false;
        String? selectedDeviceId;
        
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.devices, color: ThryveColors.warning),
                  const SizedBox(width: 12),
                  const Text('Max Devices'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You have 3 devices. Remove one to continue.',
                      style: ThryveTypography.bodyMedium.copyWith(
                        color: ThryveColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...devices.map((device) {
                      final deviceId = device is DeviceInfo 
                          ? device.deviceId 
                          : (device['device_id'] ?? '');
                      final deviceName = device is DeviceInfo 
                          ? device.deviceName 
                          : (device['device_name'] ?? 'Unknown Device');
                      final isSelected = selectedDeviceId == deviceId;
                      
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => selectedDeviceId = deviceId);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? ThryveColors.error.withValues(alpha: 0.1) 
                                : (isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.surface),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? ThryveColors.error : ThryveColors.divider,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_android,
                                color: isSelected ? ThryveColors.error : ThryveColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  deviceName,
                                  style: ThryveTypography.bodyMedium.copyWith(
                                    color: isSelected ? ThryveColors.error : null,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: ThryveColors.error),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedDeviceId == null || isRemoving 
                      ? null 
                      : () async {
                          setDialogState(() => isRemoving = true);
                          
                          try {
                            await DeviceService().removeDevice(selectedDeviceId!);
                            
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              
                              // Retry login
                              if (context.mounted) {
                                context.read<AuthBloc>().add(
                                  AuthSignInRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            setDialogState(() => isRemoving = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to remove device: $e'),
                                  backgroundColor: ThryveColors.error,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThryveColors.error,
                  ),
                  child: isRemoving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Remove & Continue'),
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
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            // Mark as logged in and go to home
            await SessionService().setLoggedIn(true);
            if (context.mounted) context.go(AppRoutes.home);
          } else if (state is AuthNeedsPasscodeSetup) {
            // First login - mark as logged in, need to set up passcode
            await SessionService().setLoggedIn(true);
            if (context.mounted) context.go(AppRoutes.passcodeSetup);
          } else if (state is AuthNeedsFacialVerification) {
            // New device - require facial verification
            if (context.mounted) {
              context.go(AppRoutes.facialVerification, extra: state.user);
            }
          } else if (state is AuthMaxDevicesReached) {
            // Show device picker dialog
            if (context.mounted) {
              _showDevicePickerDialog(context, state.user, state.devices);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ThryveColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.08),

                      // Logo and welcome text
                      _buildHeader(isDark),

                      const SizedBox(height: 48),

                      // Email field
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        enabled: !isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: ThryveColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push(AppRoutes.forgotPassword),
                          child: Text(
                            'Forgot Password?',
                            style: ThryveTypography.labelLarge.copyWith(
                              color: ThryveColors.accent,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login button
                      _buildLoginButton(context, isLoading),

                      // Biometric login button
                      if (_biometricAvailable) ...[
                        const SizedBox(height: 16),
                        _buildBiometricButton(context, isLoading),
                      ],

                      const SizedBox(height: 32),

                      // Divider
                      _buildDivider(),

                      const SizedBox(height: 32),

                      // Social login buttons (placeholder for future)
                      _buildSocialLogins(isLoading),

                      const SizedBox(height: 32),

                      // Sign up link
                      _buildSignUpLink(isLoading),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBiometricButton(BuildContext blocContext, bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : () => _handleBiometricLogin(blocContext),
        icon: Icon(
          _biometricTypeName.contains('Face') ? Icons.face : Icons.fingerprint,
          color: ThryveColors.accent,
        ),
        label: Text(
          'Login with $_biometricTypeName',
          style: ThryveTypography.button.copyWith(
            color: ThryveColors.accent,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? ThryveColors.accent : ThryveColors.accent,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Thryve logo - orange background with white leaf
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: ThryveColors.accentGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ThryveColors.accent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/thryve_icon.png',
              color: Colors.white,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: ThryveTypography.headlineLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue investing',
          style: ThryveTypography.bodyLarge.copyWith(
            color: ThryveColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext blocContext, bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleLogin(blocContext),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThryveColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Sign In',
                style: ThryveTypography.button.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: ThryveColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: ThryveColors.divider)),
      ],
    );
  }

  Widget _buildSocialLogins(bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SocialLoginButton(
          icon: Icons.g_mobiledata,
          label: 'Continue with Google',
          onPressed: isLoading
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google sign-in coming soon!'),
                    ),
                  );
                },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        SocialLoginButton(
          icon: Icons.apple,
          label: 'Continue with Apple',
          onPressed: isLoading
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apple sign-in coming soon!'),
                    ),
                  );
                },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSignUpLink(bool isLoading) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: ThryveTypography.bodyMedium.copyWith(
            color: ThryveColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: ThryveTypography.bodyMedium.copyWith(
                color: ThryveColors.accent,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = isLoading ? null : () => context.push(AppRoutes.register),
            ),
          ],
        ),
      ),
    );
  }
}
