import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// KYC Pending page - Shown while verification is in progress
class KycPendingPage extends StatelessWidget {
  const KycPendingPage({super.key});

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

              // Animated illustration
              _buildIllustration(),

              const SizedBox(height: 48),

              // Title
              Text(
                'Verification in Progress',
                style: ThryveTypography.headlineLarge.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'We\'re reviewing your documents. This usually takes a few minutes, but can take up to 24 hours.',
                style: ThryveTypography.bodyLarge.copyWith(
                  color: ThryveColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Status card
              _buildStatusCard(isDark),

              const SizedBox(height: 24),

              // What happens next
              _buildNextSteps(isDark),

              const Spacer(),

              // Continue to app button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThryveColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Explore the App',
                    style: ThryveTypography.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Note
              Text(
                'You can browse stocks while waiting for verification',
                style: ThryveTypography.bodySmall.copyWith(
                  color: ThryveColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ThryveColors.accent.withValues(alpha: 0.2),
              width: 3,
            ),
          ),
        ),
        // Inner ring
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThryveColors.accent.withValues(alpha: 0.1),
          ),
          child: const Icon(
            Icons.hourglass_top,
            size: 48,
            color: ThryveColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThryveColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusItem(
            icon: Icons.article_outlined,
            title: 'Documents Submitted',
            status: 'Complete',
            isComplete: true,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Divider(height: 24),
          ),
          _buildStatusItem(
            icon: Icons.search,
            title: 'Under Review',
            status: 'In Progress',
            isComplete: false,
            isInProgress: true,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Divider(height: 24),
          ),
          _buildStatusItem(
            icon: Icons.verified_outlined,
            title: 'Verification Complete',
            status: 'Pending',
            isComplete: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String status,
    required bool isComplete,
    bool isInProgress = false,
  }) {
    Color statusColor;
    if (isComplete) {
      statusColor = ThryveColors.success;
    } else if (isInProgress) {
      statusColor = ThryveColors.accent;
    } else {
      statusColor = ThryveColors.textTertiary;
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isComplete ? Icons.check : icon,
            color: statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ThryveTypography.titleSmall,
              ),
              Text(
                status,
                style: ThryveTypography.bodySmall.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        if (isInProgress)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(ThryveColors.accent),
            ),
          ),
      ],
    );
  }

  Widget _buildNextSteps(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThryveColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: ThryveColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'What happens next?',
                style: ThryveTypography.labelLarge.copyWith(
                  color: ThryveColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll send you a notification and email once your verification is complete. You\'ll then be able to deposit funds and start investing!',
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
