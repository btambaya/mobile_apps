/// Authenticated user entity
class AuthUser {
  final String id;
  final String email;
  final String? givenName;
  final String? familyName;
  final String? phoneNumber;
  final String? country;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    this.givenName,
    this.familyName,
    this.phoneNumber,
    this.country,
    this.isEmailVerified = false,
  });

  String get displayName {
    if (givenName != null && familyName != null) {
      return '$givenName $familyName';
    }
    return givenName ?? email.split('@').first;
  }

  String get initials {
    if (givenName != null && familyName != null) {
      return '${givenName![0]}${familyName![0]}'.toUpperCase();
    }
    if (givenName != null) {
      return givenName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  String toString() => 'AuthUser(id: $id, email: $email)';
}
