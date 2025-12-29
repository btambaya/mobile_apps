import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/pin_service.dart';
import '../../domain/entities/auth_user.dart';

/// Facial verification page for new device registration
/// This is a placeholder - actual face verification will be implemented later
class FacialVerificationPage extends StatefulWidget {
  final AuthUser user;
  
  const FacialVerificationPage({super.key, required this.user});

  @override
  State<FacialVerificationPage> createState() => _FacialVerificationPageState();
}

class _FacialVerificationPageState extends State<FacialVerificationPage> {
  bool _isVerifying = false;

  Future<void> _startVerification() async {
    setState(() => _isVerifying = true);
    
    // TODO: Implement actual facial verification
    // This will integrate with camera and face detection later
    
    // For now, simulate verification delay
    await Future.delayed(const Duration(seconds: 2));
    
    await _proceedAfterVerification();
  }
  
  Future<void> _proceedAfterVerification() async {
    // Mark as logged in
    await SessionService().setLoggedIn(true);
    
    // Check if passcode exists (sync from cloud for cross-device)
    final pinService = PinService();
    var hasPasscode = await pinService.isPinEnabled();
    
    // If no local passcode, try to sync from Cognito
    if (!hasPasscode) {
      final synced = await pinService.syncFromCloud();
      hasPasscode = synced;
    }
    
    if (mounted) {
      if (hasPasscode) {
        // Already has passcode, go to home
        context.go(AppRoutes.home);
      } else {
        // No passcode, need to set one up
        context.go(AppRoutes.passcodeSetup);
      }
    }
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
              const Spacer(),
              
              // Face icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: ThryveColors.accentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.face,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Verify Your Identity',
                style: ThryveTypography.headlineMedium.copyWith(
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'For your security, we need to verify your identity on this new device.',
                style: ThryveTypography.bodyMedium.copyWith(
                  color: ThryveColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // New device info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThryveColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThryveColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.devices, color: ThryveColors.info, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New device detected. Facial verification required.',
                        style: ThryveTypography.bodySmall.copyWith(
                          color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isVerifying ? null : _startVerification,
                  icon: _isVerifying 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(_isVerifying ? 'Verifying...' : 'Start Verification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThryveColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
}
