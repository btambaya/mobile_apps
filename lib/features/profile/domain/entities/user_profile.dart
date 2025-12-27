/// User Profile entity from DynamoDB
/// Contains extended profile data beyond Cognito auth attributes
class UserProfile {
  final String userId;
  final String email;
  final String? givenName;
  final String? familyName;
  final String? phoneNumber;
  final String? country;
  final String kycStatus;
  final bool phoneVerified;
  final DateTime createdAt;

  const UserProfile({
    required this.userId,
    required this.email,
    this.givenName,
    this.familyName,
    this.phoneNumber,
    this.country,
    this.kycStatus = 'not_started',
    this.phoneVerified = false,
    required this.createdAt,
  });

  /// Create from API JSON response
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      givenName: json['given_name'] as String?,
      familyName: json['family_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      country: json['country'] as String?,
      kycStatus: json['kyc_status'] as String? ?? 'not_started',
      phoneVerified: json['phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Get display name
  String get displayName {
    if (givenName != null && familyName != null) {
      return '$givenName $familyName';
    }
    return givenName ?? email.split('@').first;
  }

  /// Get initials for avatar
  String get initials {
    if (givenName != null && familyName != null) {
      return '${givenName![0]}${familyName![0]}'.toUpperCase();
    }
    if (givenName != null) {
      return givenName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// Check if KYC is complete
  bool get isKycComplete => kycStatus == 'approved';

  /// Check if KYC is pending
  bool get isKycPending => kycStatus == 'pending';

  /// Check if KYC needs to be started
  bool get needsKyc => kycStatus == 'not_started' || kycStatus == 'rejected';

  @override
  String toString() => 'UserProfile(userId: $userId, email: $email, kycStatus: $kycStatus)';
}
