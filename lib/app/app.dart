import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import '../core/services/theme_service.dart';
import '../core/services/session_service.dart';
import '../features/auth/presentation/pages/lock_screen.dart';
import '../features/auth/presentation/pages/passcode_setup_page.dart';

/// Root application widget for Thryve
class ThryveApp extends StatefulWidget {
  const ThryveApp({super.key});

  @override
  State<ThryveApp> createState() => _ThryveAppState();
}

class _ThryveAppState extends State<ThryveApp> {
  final SessionService _sessionService = SessionService();
  
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

  @override
  Widget build(BuildContext context) {
    // Lock to portrait mode for mobile
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Listen to theme changes
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Thryve',
          debugShowCheckedModeBanner: false,
          
          // Theme configuration
          theme: ThryveTheme.light,
          darkTheme: ThryveTheme.dark,
          themeMode: ThemeService().themeMode,
          
          // Router configuration
          routerConfig: AppRouter.router,
          
          // Overlays: passcode setup or lock screen
          builder: (context, child) {
            return Stack(
              children: [
                child ?? const SizedBox.shrink(),
                if (_showPasscodeSetup)
                  PasscodeSetupPage(onPasscodeSet: _handlePasscodeSet),
                if (_showLockScreen && !_showPasscodeSetup)
                  LockScreen(onUnlocked: _handleUnlock),
              ],
            );
          },
        );
      },
    );
  }
}

