/// AWS Cognito configuration for Thryve authentication
class AuthConfig {
  // Cognito User Pool
  static const String userPoolId = 'us-east-1_5eWwc0y7h';
  static const String clientId = '6sfchnp8u913osd1kagk7hquj3';
  static const String region = 'us-east-1';
  
  // Token storage keys
  static const String accessTokenKey = 'cognito_access_token';
  static const String idTokenKey = 'cognito_id_token';
  static const String refreshTokenKey = 'cognito_refresh_token';
  static const String userIdKey = 'cognito_user_id';
  static const String emailKey = 'cognito_email';
  
  // User attribute storage keys (cached locally for offline access)
  static const String givenNameKey = 'user_given_name';
  static const String familyNameKey = 'user_family_name';
  static const String phoneNumberKey = 'user_phone_number';
  static const String countryKey = 'user_country';
}
