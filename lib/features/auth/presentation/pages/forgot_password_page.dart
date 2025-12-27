import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

/// Forgot password page for password reset via Cognito
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Flow states: 0 = enter email, 1 = enter code + new password, 2 = success
  int _step = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSendCode(BuildContext blocContext) {
    if (_formKey.currentState?.validate() ?? false) {
      blocContext.read<AuthBloc>().add(
        AuthForgotPasswordRequested(_emailController.text.trim()),
      );
    }
  }

  void _handleResetPassword(BuildContext blocContext) {
    if (_formKey.currentState?.validate() ?? false) {
      blocContext.read<AuthBloc>().add(
        AuthConfirmForgotPasswordRequested(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthForgotPasswordCodeSent) {
            setState(() => _step = 1);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification code sent to your email'),
                backgroundColor: ThryveColors.success,
              ),
            );
          } else if (state is AuthPasswordResetSuccess) {
            setState(() => _step = 2);
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
                onPressed: isLoading ? null : () => context.pop(),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildContent(context, isDark, isLoading),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext blocContext, bool isDark, bool isLoading) {
    switch (_step) {
      case 0:
        return _buildEmailStep(blocContext, isDark, isLoading);
      case 1:
        return _buildResetStep(blocContext, isDark, isLoading);
      case 2:
        return _buildSuccessStep(isDark);
      default:
        return _buildEmailStep(blocContext, isDark, isLoading);
    }
  }

  Widget _buildEmailStep(BuildContext blocContext, bool isDark, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildHeader(
            isDark,
            icon: Icons.lock_reset,
            title: 'Forgot Password?',
            subtitle: 'No worries! Enter your email and we\'ll send you a code to reset your password.',
          ),
          const SizedBox(height: 48),
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _handleSendCode(blocContext),
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
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Send Code',
                      style: ThryveTypography.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: isLoading ? null : () => context.pop(),
              child: Text(
                'Back to Sign In',
                style: ThryveTypography.labelLarge.copyWith(
                  color: ThryveColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep(BuildContext blocContext, bool isDark, bool isLoading) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildHeader(
              isDark,
              icon: Icons.mark_email_read,
              title: 'Reset Password',
              subtitle: 'Enter the code sent to ${_emailController.text} and your new password.',
            ),
            const SizedBox(height: 32),
            // Verification code
            AuthTextField(
              controller: _codeController,
              label: 'Verification Code',
              hint: 'Enter 6-digit code',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.pin,
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the verification code';
                }
                if (value.length != 6) {
                  return 'Code must be 6 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // New password
            AuthTextField(
              controller: _newPasswordController,
              label: 'New Password',
              hint: 'Enter new password',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              enabled: !isLoading,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: ThryveColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain an uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must contain a lowercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must contain a number';
                }
                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'Password must contain a special character';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            _buildPasswordRequirements(),
            const SizedBox(height: 16),
            // Confirm password
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter new password',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outline,
              enabled: !isLoading,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: ThryveColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _handleResetPassword(blocContext),
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
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Reset Password',
                        style: ThryveTypography.button.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: isLoading ? null : () => setState(() => _step = 0),
                child: Text(
                  'Didn\'t receive the code? Go back',
                  style: ThryveTypography.labelMedium.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStep(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ThryveColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 60,
            color: ThryveColors.success,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Password Reset!',
          style: ThryveTypography.headlineLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Your password has been reset successfully. You can now sign in with your new password.',
            style: ThryveTypography.bodyLarge.copyWith(
              color: ThryveColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThryveColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Sign In',
              style: ThryveTypography.button.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, {required IconData icon, required String title, required String subtitle}) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ThryveColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 40,
            color: ThryveColors.accent,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: ThryveTypography.headlineLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            subtitle,
            style: ThryveTypography.bodyLarge.copyWith(
              color: ThryveColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _newPasswordController.text;
    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequirement('At least 8 characters', hasMinLength),
          _buildRequirement('One uppercase letter', hasUppercase),
          _buildRequirement('One lowercase letter', hasLowercase),
          _buildRequirement('One number', hasNumber),
          _buildRequirement('One special character', hasSpecial),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: met ? ThryveColors.success : ThryveColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: ThryveTypography.bodySmall.copyWith(
              color: met ? ThryveColors.success : ThryveColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
