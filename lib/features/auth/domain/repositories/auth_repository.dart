import '../entities/auth_user.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String givenName,
    required String familyName,
    String? phoneNumber,
    String? countryCode,
  });

  /// Confirm sign up with verification code
  Future<void> confirmSignUp({
    required String email,
    required String code,
  });

  /// Resend confirmation code
  Future<void> resendConfirmationCode(String email);

  /// Sign in with email and password
  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current authenticated user (from stored session)
  Future<AuthUser?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Initiate forgot password flow
  Future<void> forgotPassword(String email);

  /// Confirm forgot password with code and new password
  Future<void> confirmForgotPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Refresh session tokens
  Future<void> refreshSession();

  /// Change password for authenticated user
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

