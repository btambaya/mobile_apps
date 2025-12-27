import '../../../../core/services/api_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

/// Implementation of UserProfileRepository using API service
class UserProfileRepositoryImpl implements UserProfileRepository {
  final ApiService _apiService;

  UserProfileRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<UserProfile> getUserProfile() async {
    final response = await _apiService.get('/user/profile');
    return UserProfile.fromJson(response);
  }

  @override
  Future<void> updateProfile({
    String? givenName,
    String? familyName,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (givenName != null) body['given_name'] = givenName;
    if (familyName != null) body['family_name'] = familyName;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;

    await _apiService.put('/user/profile', body);
  }

  @override
  Future<void> markPhoneVerified() async {
    await _apiService.post('/user/phone/verify', {});
  }
}
