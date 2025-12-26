import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// Social login button (Google, Apple, etc.)
class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? ThryveColors.surfaceDark : Colors.white,
          side: BorderSide(
            color: isDark ? ThryveColors.surfaceElevatedDark : ThryveColors.divider,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: ThryveTypography.labelLarge.copyWith(
                color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
