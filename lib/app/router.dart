import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth feature imports
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/verify_otp_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';

// KYC feature imports
import '../features/kyc/presentation/pages/kyc_start_page.dart';
import '../features/kyc/presentation/pages/kyc_personal_info_page.dart';
import '../features/kyc/presentation/pages/kyc_investor_profile_page.dart';
import '../features/kyc/presentation/pages/kyc_documents_page.dart';
import '../features/kyc/presentation/pages/kyc_disclosures_page.dart';
import '../features/kyc/presentation/pages/kyc_pending_page.dart';

// Portfolio feature imports
import '../features/portfolio/presentation/pages/home_page.dart';
import '../features/portfolio/presentation/pages/portfolio_page.dart';
import '../features/portfolio/presentation/pages/auto_invest_page.dart';

// Trading feature imports
import '../features/trading/presentation/pages/trade_page.dart';
import '../features/trading/presentation/pages/stock_detail_page.dart';

// Wallet feature imports
import '../features/wallet/presentation/pages/wallet_page.dart';
import '../features/wallet/presentation/pages/deposit_page.dart';
import '../features/wallet/presentation/pages/withdraw_page.dart';
import '../features/wallet/presentation/pages/order_history_page.dart';
import '../features/wallet/presentation/pages/bank_accounts_page.dart';

// Profile feature imports
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/settings_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/profile/presentation/pages/notifications_page.dart';
import '../features/profile/presentation/pages/security_page.dart';
import '../features/profile/presentation/pages/help_support_page.dart';
import '../features/profile/presentation/pages/referrals_page.dart';
import '../features/profile/presentation/pages/legal_documents_page.dart';
import '../features/profile/presentation/pages/documents_page.dart';

import '../shared/widgets/placeholder_page.dart';

/// Route names for type-safe navigation
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';

  // KYC routes
  static const String kycStart = '/kyc';
  static const String kycPersonalInfo = '/kyc/personal-info';
  static const String kycInvestorProfile = '/kyc/investor-profile';
  static const String kycDocuments = '/kyc/documents';
  static const String kycDisclosures = '/kyc/disclosures';
  static const String kycPending = '/kyc/pending';

  // Main app routes
  static const String home = '/home';
  static const String portfolio = '/portfolio';
  static const String autoInvest = '/auto-invest';
  static const String trade = '/trade';
  static const String stockDetail = '/trade/:symbol';
  static const String wallet = '/wallet';
  static const String deposit = '/wallet/deposit';
  static const String withdraw = '/wallet/withdraw';
  static const String bankAccounts = '/wallet/bank-accounts';
  static const String orderHistory = '/wallet/orders';
  static const String documents = '/documents';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String editProfile = '/profile/edit';
  static const String notifications = '/notifications';
  static const String security = '/security';
  static const String helpSupport = '/help';
  static const String referrals = '/referrals';
  static const String legalDocuments = '/legal';
}

/// App router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ============ Auth Routes ============
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) => const VerifyOtpPage(),
      ),

      // ============ KYC Routes ============
      GoRoute(
        path: AppRoutes.kycStart,
        builder: (context, state) => const KycStartPage(),
        routes: [
          GoRoute(
            path: 'personal-info',
            builder: (context, state) => const KycPersonalInfoPage(),
          ),
          GoRoute(
            path: 'investor-profile',
            builder: (context, state) => const KycInvestorProfilePage(),
          ),
          GoRoute(
            path: 'documents',
            builder: (context, state) => const KycDocumentsPage(),
          ),
          GoRoute(
            path: 'disclosures',
            builder: (context, state) => const KycDisclosuresPage(),
          ),
          GoRoute(
            path: 'pending',
            builder: (context, state) => const KycPendingPage(),
          ),
        ],
      ),

      // ============ Main App Shell (with bottom nav) ============
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.portfolio,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PortfolioPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trade,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TradePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.wallet,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WalletPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),

      // ============ Full Screen Routes (no bottom nav) ============
      GoRoute(
        path: '/trade/:symbol',
        builder: (context, state) {
          final symbol = state.pathParameters['symbol'] ?? 'AAPL';
          return StockDetailPage(symbol: symbol);
        },
      ),
      GoRoute(
        path: AppRoutes.deposit,
        builder: (context, state) => const DepositPage(),
      ),
      GoRoute(
        path: AppRoutes.withdraw,
        builder: (context, state) => const WithdrawPage(),
      ),
      GoRoute(
        path: AppRoutes.bankAccounts,
        builder: (context, state) => const BankAccountsPage(),
      ),
      GoRoute(
        path: AppRoutes.autoInvest,
        builder: (context, state) => const AutoInvestPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.security,
        builder: (context, state) => const SecurityPage(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        builder: (context, state) => const HelpSupportPage(),
      ),
      GoRoute(
        path: AppRoutes.referrals,
        builder: (context, state) => const ReferralsPage(),
      ),
      GoRoute(
        path: AppRoutes.legalDocuments,
        builder: (context, state) => const LegalDocumentsPage(),
      ),
      GoRoute(
        path: AppRoutes.documents,
        builder: (context, state) => const DocumentsPage(),
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        builder: (context, state) => const OrderHistoryPage(),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => PlaceholderPage(
      title: 'Page Not Found',
      subtitle: state.uri.toString(),
    ),
  );
}

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Trade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.portfolio)) return 1;
    if (location.startsWith(AppRoutes.trade)) return 2;
    if (location.startsWith(AppRoutes.wallet)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.portfolio);
        break;
      case 2:
        context.go(AppRoutes.trade);
        break;
      case 3:
        context.go(AppRoutes.wallet);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }
}
