import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/auth_config.dart';
import '../../domain/entities/auth_user.dart';

/// Cognito authentication data source
/// Handles all direct interactions with AWS Cognito
/// SINGLETON: All parts of the app share the same session state
class CognitoAuthDatasource {
  // Singleton instance
  static final CognitoAuthDatasource _instance = CognitoAuthDatasource._internal();
  
  // Factory constructor returns the singleton
  factory CognitoAuthDatasource({FlutterSecureStorage? secureStorage}) => _instance;
  
  // Private constructor
  CognitoAuthDatasource._internal() : _secureStorage = const FlutterSecureStorage() {
    _userPool = CognitoUserPool(
      AuthConfig.userPoolId,
      AuthConfig.clientId,
    );
  }
  
  late final CognitoUserPool _userPool;
  final FlutterSecureStorage _secureStorage;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;

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
    
    // Build and cache user data locally for offline access
    final user = _buildAuthUser(attributes, email);
    await _cacheUserAttributes(user);
    
    return user;
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
  /// Uses locally cached attributes to avoid API calls
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

      // READ FROM LOCAL CACHE - no network call!
      return await _getCachedUser(email);
    } catch (e) {
      // Session error - clear and force re-login
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

  /// Save passcode hash to Cognito user attributes
  Future<void> savePasscodeHash(String passcodeHash) async {
    final email = await _secureStorage.read(key: AuthConfig.emailKey);
    
    if (email == null || _cognitoUser == null) {
      // Try to restore session
      await getCurrentUser();
      if (_cognitoUser == null) {
        throw Exception('No user session found');
      }
    }

    final attributes = [
      CognitoUserAttribute(name: 'custom:passcode_hash', value: passcodeHash),
    ];
    
    await _cognitoUser!.updateAttributes(attributes);
  }

  /// Get passcode hash from Cognito user attributes
  Future<String?> getPasscodeHash() async {
    if (_cognitoUser == null) {
      await getCurrentUser();
      if (_cognitoUser == null) {
        return null;
      }
    }

    try {
      final attributes = await _cognitoUser!.getUserAttributes();
      if (attributes != null) {
        for (final attr in attributes) {
          if (attr.name == 'custom:passcode_hash') {
            return attr.value;
          }
        }
      }
    } catch (e) {
      // Attribute may not exist yet
      return null;
    }
    return null;
  }


  /// Change password for authenticated user
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final email = await _secureStorage.read(key: AuthConfig.emailKey);
    
    if (email == null) {
      throw Exception('No user session found');
    }

    _cognitoUser = CognitoUser(email, _userPool);
    
    // First authenticate with old password
    final authDetails = AuthenticationDetails(
      username: email,
      password: oldPassword,
    );
    
    try {
      _session = await _cognitoUser!.authenticateUser(authDetails);
      
      if (_session != null && _session!.isValid()) {
        // Now change password
        await _cognitoUser!.changePassword(oldPassword, newPassword);
      } else {
        throw Exception('Invalid session');
      }
    } catch (e) {
      rethrow;
    }
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
    // Also clear cached user attributes
    await _secureStorage.delete(key: AuthConfig.givenNameKey);
    await _secureStorage.delete(key: AuthConfig.familyNameKey);
    await _secureStorage.delete(key: AuthConfig.phoneNumberKey);
    await _secureStorage.delete(key: AuthConfig.countryKey);
  }

  /// Cache user attributes locally for offline access
  Future<void> _cacheUserAttributes(AuthUser user) async {
    await _secureStorage.write(
      key: AuthConfig.userIdKey,
      value: user.id,
    );
    if (user.givenName != null) {
      await _secureStorage.write(
        key: AuthConfig.givenNameKey,
        value: user.givenName!,
      );
    }
    if (user.familyName != null) {
      await _secureStorage.write(
        key: AuthConfig.familyNameKey,
        value: user.familyName!,
      );
    }
    if (user.phoneNumber != null) {
      await _secureStorage.write(
        key: AuthConfig.phoneNumberKey,
        value: user.phoneNumber!,
      );
    }
    if (user.country != null) {
      await _secureStorage.write(
        key: AuthConfig.countryKey,
        value: user.country!,
      );
    }
  }

  /// Get user from locally cached attributes (no network call)
  Future<AuthUser?> _getCachedUser(String email) async {
    final userId = await _secureStorage.read(key: AuthConfig.userIdKey);
    final givenName = await _secureStorage.read(key: AuthConfig.givenNameKey);
    final familyName = await _secureStorage.read(key: AuthConfig.familyNameKey);
    final phoneNumber = await _secureStorage.read(key: AuthConfig.phoneNumberKey);
    final country = await _secureStorage.read(key: AuthConfig.countryKey);

    return AuthUser(
      id: userId ?? '',
      email: email,
      givenName: givenName,
      familyName: familyName,
      phoneNumber: phoneNumber,
      country: country,
      isEmailVerified: true, // Assume verified if logged in
    );
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
