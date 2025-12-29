import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/pin_service.dart';
import '../../../../core/services/session_service.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Splash screen with animated logo and auth check
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final _authRepository = AuthRepositoryImpl();
  final _pinService = PinService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Check auth FIRST before starting animation
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    try {
      final sessionService = SessionService();
      final hasPasscode = await _pinService.isPinEnabled();
      
      // Check if user has passcode AND is logged in
      if (hasPasscode && sessionService.isLoggedIn) {
        // RETURNING LOGGED-IN USER - show brief splash then lock screen
        _controller.forward();
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) context.go(AppRoutes.home);
        return;
      }
      
      // Check auth session
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        // Has auth session - mark as logged in
        await sessionService.setLoggedIn(true);
        
        // SYNC passcode from Cognito (for cross-device login)
        await _pinService.syncFromCloud();
        final hasPasscodeNow = await _pinService.isPinEnabled();
        
        if (!hasPasscodeNow) {
          // Has session but no passcode anywhere - go to passcode setup
          _controller.forward();
          await Future.delayed(const Duration(milliseconds: 2500));
          if (mounted) context.go(AppRoutes.passcodeSetup);
        } else {
          // Has session and passcode - go to home (lock screen will show)
          _controller.forward();
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) context.go(AppRoutes.home);
        }
      } else {
        // No session - check if returning user (has passcode = has logged in before)
        _controller.forward();
        await Future.delayed(const Duration(milliseconds: 2500));
        
        if (hasPasscode) {
          // Returning user who logged out - go directly to login (skip onboarding)
          if (mounted) context.go(AppRoutes.login);
        } else {
          // First-time user - go to onboarding
          if (mounted) context.go(AppRoutes.onboarding);
        }
      }
    } catch (e) {
      // Error checking - show splash then go to onboarding
      _controller.forward();
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThryveColors.accent,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo - Thryve leaf icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/thryve_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App name
                    Text(
                      'Thryve',
                      style: ThryveTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      'Invest in your future',
                      style: ThryveTypography.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
