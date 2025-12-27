import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

/// Country model for registration
class Country {
  final String code;
  final String name;
  final String dialCode;
  final String flag;
  final String currencyCode;
  final String currencySymbol;

  const Country({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.currencyCode,
    required this.currencySymbol,
  });
}

/// Supported countries for Thryve
const List<Country> supportedCountries = [
  Country(
    code: 'NG',
    name: 'Nigeria',
    dialCode: '+234',
    flag: '🇳🇬',
    currencyCode: 'NGN',
    currencySymbol: '₦',
  ),
  // More countries to be added later
  // Country(
  //   code: 'US',
  //   name: 'United States',
  //   dialCode: '+1',
  //   flag: '🇺🇸',
  //   currencyCode: 'USD',
  //   currencySymbol: '\$',
  // ),
  // Country(
  //   code: 'GB',
  //   name: 'United Kingdom',
  //   dialCode: '+44',
  //   flag: '🇬🇧',
  //   currencyCode: 'GBP',
  //   currencySymbol: '£',
  // ),
];

/// Registration page with Cognito signup
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  
  // Default to Nigeria
  Country _selectedCountry = supportedCountries.first;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'^0+'), '');
    return '${_selectedCountry.dialCode}$phone';
  }

  void _handleRegister(BuildContext blocContext) {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the Terms & Conditions'),
            backgroundColor: ThryveColors.error,
          ),
        );
        return;
      }
      
      blocContext.read<AuthBloc>().add(
        AuthSignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          givenName: _firstNameController.text.trim(),
          familyName: _lastNameController.text.trim(),
          phoneNumber: _fullPhoneNumber,
          countryCode: _selectedCountry.code,
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
          if (state is AuthSignUpSuccess) {
            // Navigate to verification page with email and phone
            context.push(
              AppRoutes.verifyOtp,
              extra: {
                'email': state.email,
                'phone': _fullPhoneNumber,
                'isNewUser': true,
              },
            );
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // Header
                      _buildHeader(isDark),

                      const SizedBox(height: 32),

                      // Country selector (disabled for now - Nigeria only)
                      _buildCountrySelector(isDark, isLoading),

                      const SizedBox(height: 16),

                      // First Name field
                      AuthTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        hint: 'Enter your first name',
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Last Name field
                      AuthTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        hint: 'Enter your last name',
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

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

                      // Phone number field
                      _buildPhoneField(isDark, isLoading),

                      const SizedBox(height: 16),

                      // Password field
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Create a strong password',
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
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
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

                      // Password requirements
                      _buildPasswordRequirements(),

                      const SizedBox(height: 16),

                      // Confirm password field
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outline,
                        enabled: !isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: ThryveColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Terms checkbox
                      _buildTermsCheckbox(isDark, isLoading),

                      const SizedBox(height: 24),

                      // Register button
                      _buildRegisterButton(context, isLoading),

                      const SizedBox(height: 32),

                      // Divider
                      _buildDivider(),

                      const SizedBox(height: 32),

                      // Social signup buttons
                      _buildSocialSignups(isLoading),

                      const SizedBox(height: 32),

                      // Sign in link
                      _buildSignInLink(isLoading),

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

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: ThryveTypography.headlineLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start your investment journey today',
          style: ThryveTypography.bodyLarge.copyWith(
            color: ThryveColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelector(bool isDark, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: ThryveTypography.labelLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                _selectedCountry.flag,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedCountry.name,
                  style: ThryveTypography.bodyLarge.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
              ),
              // Disabled icon - will enable country selection later
              Icon(
                Icons.lock_outline,
                color: ThryveColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Currency: ${_selectedCountry.currencyCode} (${_selectedCountry.currencySymbol})',
          style: ThryveTypography.bodySmall.copyWith(
            color: ThryveColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(bool isDark, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: ThryveTypography.labelLarge.copyWith(
            color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code prefix
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCountry.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedCountry.dialCode,
                    style: ThryveTypography.bodyLarge.copyWith(
                      color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Phone number input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                enabled: !isLoading,
                keyboardType: TextInputType.phone,
                style: ThryveTypography.bodyLarge.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '801 234 5678',
                  hintStyle: ThryveTypography.bodyLarge.copyWith(
                    color: ThryveColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: isDark ? ThryveColors.surfaceDark : ThryveColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ThryveColors.accent,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ThryveColors.error,
                      width: 1,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (cleaned.length < 10 || cleaned.length > 11) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
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
          _buildRequirement('One special character (!@#\$%^&*)', hasSpecial),
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

  Widget _buildTermsCheckbox(bool isDark, bool isLoading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: isLoading
                ? null
                : (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
            activeColor: ThryveColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: ThryveTypography.bodySmall.copyWith(
                color: ThryveColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: ThryveTypography.labelMedium.copyWith(
                    color: ThryveColors.accent,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: ThryveTypography.labelMedium.copyWith(
                    color: ThryveColors.accent,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext blocContext, bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleRegister(blocContext),
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
                'Create Account',
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
        Expanded(child: Container(height: 1, color: ThryveColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or sign up with',
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: ThryveColors.divider)),
      ],
    );
  }

  Widget _buildSocialSignups(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: SocialLoginButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
            onPressed: isLoading
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google sign-up coming soon!')),
                    );
                  },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SocialLoginButton(
            icon: Icons.apple,
            label: 'Apple',
            onPressed: isLoading
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Apple sign-up coming soon!')),
                    );
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink(bool isLoading) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: ThryveTypography.bodyMedium.copyWith(
            color: ThryveColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: 'Sign In',
              style: ThryveTypography.labelLarge.copyWith(
                color: ThryveColors.accent,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = isLoading ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
