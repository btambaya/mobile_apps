import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/auth_config.dart';
import '../../domain/entities/auth_user.dart';

/// Cognito authentication data source
/// Handles all direct interactions with AWS Cognito
class CognitoAuthDatasource {
  late final CognitoUserPool _userPool;
  final FlutterSecureStorage _secureStorage;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;

  CognitoAuthDatasource({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _userPool = CognitoUserPool(
      AuthConfig.userPoolId,
      AuthConfig.clientId,
    );
  }

  /// Sign up a new user
  Future<void> signUp({
    required String email,
    required String password,
    required String givenName,
    required String familyName,
    String? phoneNumber,
    String? countryCode,
  }) async {
    final userAttributes = [
      AttributeArg(name: 'email', value: email),
      AttributeArg(name: 'given_name', value: givenName),
      AttributeArg(name: 'family_name', value: familyName),
    ];

    // Add phone number if provided (E.164 format required by Cognito)
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      userAttributes.add(AttributeArg(name: 'phone_number', value: phoneNumber));
    }

    // Store country code as custom attribute
    if (countryCode != null && countryCode.isNotEmpty) {
      userAttributes.add(AttributeArg(name: 'custom:country', value: countryCode));
    }

    await _userPool.signUp(
      email,
      password,
      userAttributes: userAttributes,
    );
  }

  /// Confirm sign up with verification code
  Future<bool> confirmSignUp({
    required String email,
    required String code,
  }) async {
    _cognitoUser = CognitoUser(email, _userPool);
    return await _cognitoUser!.confirmRegistration(code);
  }

  /// Resend confirmation code
  Future<void> resendConfirmationCode(String email) async {
    _cognitoUser = CognitoUser(email, _userPool);
    await _cognitoUser!.resendConfirmationCode();
  }

  /// Sign in with email and password
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    _cognitoUser = CognitoUser(email, _userPool);
    
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    _session = await _cognitoUser!.authenticateUser(authDetails);
    
    if (_session == null || !_session!.isValid()) {
      throw Exception('Authentication failed: Invalid session');
    }

    // Store tokens securely
    await _storeSession(_session!, email);

    // Get user attributes
    final attributes = await _cognitoUser!.getUserAttributes();
    
    return _buildAuthUser(attributes, email);
  }

  /// Sign out current user
  Future<void> signOut() async {
    if (_cognitoUser != null) {
      await _cognitoUser!.signOut();
    }
    await _clearStoredSession();
    _cognitoUser = null;
    _session = null;
  }

  /// Get current user from stored session
  Future<AuthUser?> getCurrentUser() async {
    final email = await _secureStorage.read(key: AuthConfig.emailKey);
    final accessToken = await _secureStorage.read(key: AuthConfig.accessTokenKey);
    
    if (email == null || accessToken == null) {
      return null;
    }

    try {
      // Try to restore session
      _cognitoUser = CognitoUser(email, _userPool);
      
      final idToken = await _secureStorage.read(key: AuthConfig.idTokenKey);
      final refreshToken = await _secureStorage.read(key: AuthConfig.refreshTokenKey);
      
      if (idToken == null || refreshToken == null) {
        return null;
      }

      _session = CognitoUserSession(
        CognitoIdToken(idToken),
        CognitoAccessToken(accessToken),
        refreshToken: CognitoRefreshToken(refreshToken),
      );

      // Check if session is valid
      if (!_session!.isValid()) {
        // Try to refresh
        _session = await _cognitoUser!.refreshSession(
          CognitoRefreshToken(refreshToken),
        );
        
        if (_session != null && _session!.isValid()) {
          await _storeSession(_session!, email);
        } else {
          await _clearStoredSession();
          return null;
        }
      }

      // Get user attributes
      final attributes = await _cognitoUser!.getUserAttributes();
      return _buildAuthUser(attributes, email);
    } catch (e) {
      await _clearStoredSession();
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Initiate forgot password flow
  Future<void> forgotPassword(String email) async {
    _cognitoUser = CognitoUser(email, _userPool);
    await _cognitoUser!.forgotPassword();
  }

  /// Confirm forgot password with code and new password
  Future<void> confirmForgotPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _cognitoUser = CognitoUser(email, _userPool);
    await _cognitoUser!.confirmPassword(code, newPassword);
  }

  /// Refresh the current session
  Future<void> refreshSession() async {
    final refreshToken = await _secureStorage.read(key: AuthConfig.refreshTokenKey);
    final email = await _secureStorage.read(key: AuthConfig.emailKey);
    
    if (refreshToken == null || email == null) {
      throw Exception('No refresh token available');
    }

    _cognitoUser = CognitoUser(email, _userPool);
    _session = await _cognitoUser!.refreshSession(
      CognitoRefreshToken(refreshToken),
    );

    if (_session != null && _session!.isValid()) {
      await _storeSession(_session!, email);
    } else {
      throw Exception('Failed to refresh session');
    }
  }

  /// Get current access token for API calls
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AuthConfig.accessTokenKey);
  }

  /// Get current ID token
  Future<String?> getIdToken() async {
    return await _secureStorage.read(key: AuthConfig.idTokenKey);
  }

  // Private helpers

  Future<void> _storeSession(CognitoUserSession session, String email) async {
    await _secureStorage.write(
      key: AuthConfig.accessTokenKey,
      value: session.getAccessToken().getJwtToken(),
    );
    await _secureStorage.write(
      key: AuthConfig.idTokenKey,
      value: session.getIdToken().getJwtToken(),
    );
    await _secureStorage.write(
      key: AuthConfig.refreshTokenKey,
      value: session.getRefreshToken()?.getToken(),
    );
    await _secureStorage.write(
      key: AuthConfig.emailKey,
      value: email,
    );
  }

  Future<void> _clearStoredSession() async {
    await _secureStorage.delete(key: AuthConfig.accessTokenKey);
    await _secureStorage.delete(key: AuthConfig.idTokenKey);
    await _secureStorage.delete(key: AuthConfig.refreshTokenKey);
    await _secureStorage.delete(key: AuthConfig.emailKey);
    await _secureStorage.delete(key: AuthConfig.userIdKey);
  }

  AuthUser _buildAuthUser(List<CognitoUserAttribute>? attributes, String email) {
    String? givenName;
    String? familyName;
    String? phoneNumber;
    String? country;
    String? sub;
    bool isEmailVerified = false;

    if (attributes != null) {
      for (final attr in attributes) {
        switch (attr.name) {
          case 'sub':
            sub = attr.value;
            break;
          case 'given_name':
            givenName = attr.value;
            break;
          case 'family_name':
            familyName = attr.value;
            break;
          case 'phone_number':
            phoneNumber = attr.value;
            break;
          case 'custom:country':
            country = attr.value;
            break;
          case 'email_verified':
            isEmailVerified = attr.value == 'true';
            break;
        }
      }
    }

    return AuthUser(
      id: sub ?? '',
      email: email,
      givenName: givenName,
      familyName: familyName,
      phoneNumber: phoneNumber,
      country: country,
      isEmailVerified: isEmailVerified,
    );
  }
}
