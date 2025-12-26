import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// KYC start page - Introduction to the verification process
class KycStartPage extends StatelessWidget {
  const KycStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Illustration
              _buildIllustration(),

              const SizedBox(height: 48),

              // Title and description
              Text(
                'Verify Your Identity',
                style: ThryveTypography.headlineLarge.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'To start investing in US stocks, we need to verify your identity. This is required by financial regulations.',
                style: ThryveTypography.bodyLarge.copyWith(
                  color: ThryveColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Requirements list
              _buildRequirements(isDark),

              const Spacer(),

              // Time estimate
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThryveColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: ThryveColors.info,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This usually takes about 5 minutes',
                        style: ThryveTypography.bodyMedium.copyWith(
                          color: ThryveColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.kycPersonalInfo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThryveColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Start Verification',
                    style: ThryveTypography.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip for later
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(
                  'I\'ll do this later',
                  style: ThryveTypography.labelLarge.copyWith(
                    color: ThryveColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThryveColors.accent.withValues(alpha: 0.1),
            ThryveColors.accent.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.verified_user_outlined,
        size: 80,
        color: ThryveColors.accent,
      ),
    );
  }

  Widget _buildRequirements(bool isDark) {
    final requirements = [
      {'icon': Icons.person_outline, 'text': 'Personal Information'},
      {'icon': Icons.credit_card_outlined, 'text': 'BVN for verification'},
      {'icon': Icons.badge_outlined, 'text': 'Valid Government ID'},
      {'icon': Icons.camera_alt_outlined, 'text': 'A selfie for verification'},
    ];

    return Column(
      children: requirements.map((req) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ThryveColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  req['icon'] as IconData,
                  color: ThryveColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                req['text'] as String,
                style: ThryveTypography.bodyLarge.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
