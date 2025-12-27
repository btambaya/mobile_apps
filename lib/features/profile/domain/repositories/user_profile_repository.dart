import '../entities/user_profile.dart';

/// User Profile repository interface
abstract class UserProfileRepository {
  /// Fetch user profile from backend API (DynamoDB)
  Future<UserProfile> getUserProfile();

  /// Update user profile
  Future<void> updateProfile({
    String? givenName,
    String? familyName,
    String? phoneNumber,
  });

  /// Mark phone as verified
  Future<void> markPhoneVerified();
}
