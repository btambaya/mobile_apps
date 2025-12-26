/// API endpoints configuration
class ApiEndpoints {
  ApiEndpoints._();

  // Base URLs
  static const String baseUrlDev = 'https://api-dev.thryve.io/v1';
  static const String baseUrlStaging = 'https://api-staging.thryve.io/v1';
  static const String baseUrlProd = 'https://api.thryve.io/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/me';
  static const String deleteAccount = '/users/me';

  // KYC endpoints
  static const String submitKyc = '/kyc/submit';
  static const String kycStatus = '/kyc/status';
  static const String uploadDocument = '/kyc/documents';

  // Portfolio endpoints
  static const String portfolio = '/portfolio';
  static const String portfolioHistory = '/portfolio/history';
  static const String holdings = '/portfolio/holdings';

  // Trading endpoints
  static const String instruments = '/instruments';
  static String instrumentDetail(String symbol) => '/instruments/$symbol';
  static String instrumentQuote(String symbol) => '/instruments/$symbol/quote';
  static String instrumentChart(String symbol) => '/instruments/$symbol/chart';
  static const String orders = '/orders';
  static String orderDetail(String orderId) => '/orders/$orderId';
  static const String orderHistory = '/orders/history';

  // Wallet endpoints
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String initiateDeposit = '/wallet/deposit';
  static const String initiateWithdraw = '/wallet/withdraw';
  static const String bankAccounts = '/wallet/bank-accounts';
  static const String addBankAccount = '/wallet/bank-accounts';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';
  static const String registerPushToken = '/notifications/push-token';
}

/// App-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Thryve';
  static const String appTagline = 'Invest in US Stocks from Africa';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration otpResendCooldown = Duration(seconds: 60);
  static const Duration sessionTimeout = Duration(hours: 24);

  // Validation
  static const int minPasswordLength = 8;
  static const int otpLength = 6;
  static const int bvnLength = 11;
  static const int phoneLength = 11; // Nigerian format

  // Trading
  static const double minInvestmentUsd = 1.0;
  static const double minWithdrawalUsd = 10.0;

  // Storage keys
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themePreferenceKey = 'theme_preference';
}
