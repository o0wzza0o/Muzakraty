import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages user session securely with encrypted storage and expiry
class SecureSessionManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Keys
  static const _keyPhone = 'session_phone';
  static const _keyUserId = 'session_user_id';
  static const _keyExpiry = 'session_expiry';
  static const _keyCachedUser = 'session_cached_user';

  // Session duration: 90 days
  static const int _sessionDays = 90;

  /// Save session after successful login
  static Future<void> saveSession({
    required String phone,
    required String userId,
    Map<String, dynamic>? userData,
  }) async {
    final expiry = DateTime.now().add(const Duration(days: _sessionDays));

    await Future.wait([
      _storage.write(key: _keyPhone, value: phone),
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyExpiry, value: expiry.toIso8601String()),
      if (userData != null)
        _storage.write(key: _keyCachedUser, value: jsonEncode(userData)),
    ]);
  }

  /// Cache user profile data locally for instant loading
  static Future<void> cacheUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _keyCachedUser, value: jsonEncode(userData));
  }

  /// Get cached user data (instant, no network)
  static Future<Map<String, dynamic>?> getCachedUserData() async {
    final cached = await _storage.read(key: _keyCachedUser);
    if (cached == null) return null;
    try {
      return jsonDecode(cached) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Check if a valid (non-expired) session exists
  static Future<bool> hasValidSession() async {
    final expiry = await _storage.read(key: _keyExpiry);
    if (expiry == null) return false;

    try {
      final expiryDate = DateTime.parse(expiry);
      return DateTime.now().isBefore(expiryDate);
    } catch (_) {
      return false;
    }
  }

  /// Get saved phone number
  static Future<String?> getPhone() async {
    return _storage.read(key: _keyPhone);
  }

  /// Get saved user ID
  static Future<String?> getUserId() async {
    return _storage.read(key: _keyUserId);
  }

  /// Get session data (phone + userId) if valid
  static Future<({String phone, String userId})?> getSession() async {
    if (!await hasValidSession()) return null;

    final phone = await _storage.read(key: _keyPhone);
    final userId = await _storage.read(key: _keyUserId);

    if (phone == null || userId == null) return null;
    return (phone: phone, userId: userId);
  }

  /// Clear session (logout)
  static Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyPhone),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyExpiry),
      _storage.delete(key: _keyCachedUser),
    ]);
  }

  /// Refresh session expiry (extend 90 days from now)
  static Future<void> refreshExpiry() async {
    final expiry = DateTime.now().add(const Duration(days: _sessionDays));
    await _storage.write(key: _keyExpiry, value: expiry.toIso8601String());
  }
}
