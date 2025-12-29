import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/cognito_auth_datasource.dart';
import '../../../../core/services/user_profile_service.dart';

/// Implementation of AuthRepository using Cognito
class AuthRepositoryImpl implements AuthRepository {
  final CognitoAuthDatasource _datasource;

  AuthRepositoryImpl({CognitoAuthDatasource? datasource})
      : _datasource = datasource ?? CognitoAuthDatasource();

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String givenName,
    required String familyName,
    String? phoneNumber,
    String? countryCode,
  }) async {
    await _datasource.signUp(
      email: email,
      password: password,
      givenName: givenName,
      familyName: familyName,
      phoneNumber: phoneNumber,
      countryCode: countryCode,
    );
  }

  @override
  Future<void> confirmSignUp({
    required String email,
    required String code,
  }) async {
    await _datasource.confirmSignUp(email: email, code: code);
  }

  @override
  Future<void> resendConfirmationCode(String email) async {
    await _datasource.resendConfirmationCode(email);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    return await _datasource.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    // Clear profile cache on logout
    UserProfileService().clearCache();
    await _datasource.signOut();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return await _datasource.getCurrentUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _datasource.isAuthenticated();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _datasource.forgotPassword(email);
  }

  @override
  Future<void> confirmForgotPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _datasource.confirmForgotPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> refreshSession() async {
    await _datasource.refreshSession();
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _datasource.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

