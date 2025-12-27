import '../services/api_service.dart';
import '../../features/profile/domain/entities/user_profile.dart';

/// Singleton service for user profile with permanent caching
/// Profile is fetched once and cached until logout or explicit refresh
class UserProfileService {
  // Singleton instance
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  // Dependencies
  final ApiService _apiService = ApiService();

  // Cached profile
  UserProfile? _cachedProfile;
  bool _isFetching = false;

  /// Get the current cached profile (may be null if not yet fetched)
  UserProfile? get cachedProfile => _cachedProfile;

  /// Check if profile is cached
  bool get hasCache => _cachedProfile != null;

  /// Get profile - returns cache if available, otherwise fetches from API
  /// This is the main method all pages should use
  Future<UserProfile> getProfile({bool forceRefresh = false}) async {
    // Return cache if available and not forcing refresh
    if (_cachedProfile != null && !forceRefresh) {
      return _cachedProfile!;
    }

    // Prevent multiple simultaneous fetches
    if (_isFetching) {
      // Wait for the current fetch to complete
      while (_isFetching) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (_cachedProfile != null) {
        return _cachedProfile!;
      }
    }

    // Fetch from API
    return await _fetchAndCache();
  }

  /// Force refresh profile from API
  /// Use after profile photo change or other updates
  Future<UserProfile> refreshProfile() async {
    return await getProfile(forceRefresh: true);
  }

  /// Clear cache - call on logout
  void clearCache() {
    _cachedProfile = null;
    _isFetching = false;
  }

  /// Update cached profile locally (for optimistic updates)
  void updateCache(UserProfile profile) {
    _cachedProfile = profile;
  }

  /// Private method to fetch from API and cache
  Future<UserProfile> _fetchAndCache() async {
    _isFetching = true;
    try {
      final response = await _apiService.get('/user/profile');
      final profile = UserProfile.fromJson(response);
      _cachedProfile = profile;
      return profile;
    } finally {
      _isFetching = false;
    }
  }
}
