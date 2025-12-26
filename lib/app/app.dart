import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'router.dart';

/// Root application widget for Thryve
class ThryveApp extends StatelessWidget {
  const ThryveApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock to portrait mode for mobile
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp.router(
      title: 'Thryve',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: ThryveTheme.light,
      darkTheme: ThryveTheme.dark,
      themeMode: ThemeMode.system,
      
      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}
