import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // ======================================================
  // ADMIN
  // ======================================================

  static const String adminAccessTokenKey = "admin_access_token";

  static Future<void> saveAdminToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(adminAccessTokenKey, token);
  }

  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(adminAccessTokenKey);
  }

  static Future<void> removeAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(adminAccessTokenKey);
  }

  static Future<bool> hasAdminToken() async {
    final token = await getAdminToken();
    return token != null && token.isNotEmpty;
  }

  // ======================================================
  // USER
  // ======================================================

  static const String userAccessTokenKey = "user_access_token";
  static const String userRefreshTokenKey = "user_refresh_token";

  static Future<void> saveUserTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userAccessTokenKey, accessToken);
    await prefs.setString(userRefreshTokenKey, refreshToken);
  }

  static Future<String?> getUserAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userAccessTokenKey);
  }

  static Future<String?> getUserRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userRefreshTokenKey);
  }

  static Future<void> removeUserTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userAccessTokenKey);
    await prefs.remove(userRefreshTokenKey);
  }

  static Future<bool> hasUserToken() async {
    final token = await getUserAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ======================================================
  // NOTIFICATIONS — LAST SEEN
  // ======================================================

  static const String _notificationsSeenPrefix = "notifications_seen_";

  /// Save the current timestamp as the moment the user
  /// last opened the notifications screen.
  static Future<void> markNotificationsSeen(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "$_notificationsSeenPrefix$userId",
      DateTime.now().toIso8601String(),
    );
  }

  /// Read the timestamp of the last time the user opened
  /// the notifications screen. Returns `null` if never opened.
  static Future<DateTime?> getLastSeenNotifications(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("$_notificationsSeenPrefix$userId");
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}