import 'package:shared_preferences/shared_preferences.dart';

class ProfileCacheService {
  static const String _keyDisplayName = 'cached_display_name';
  static const String _keyEmail = 'cached_email';
  static const String _keyUserId = 'cached_user_id';

  // Cache user profile data
  Future<void> cacheProfile({
    required String? displayName,
    required String? email,
    required String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (displayName != null) {
      await prefs.setString(_keyDisplayName, displayName);
    }
    if (email != null) {
      await prefs.setString(_keyEmail, email);
    }
    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    }
  }

  // Get cached profile data
  Future<Map<String, String?>> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'displayName': prefs.getString(_keyDisplayName),
      'email': prefs.getString(_keyEmail),
      'userId': prefs.getString(_keyUserId),
    };
  }

  // Clear cached profile data (on logout)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyDisplayName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUserId);
  }
}
