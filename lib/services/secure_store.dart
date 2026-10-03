import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Encrypted storage for session secrets (auth token, user id, expiry).
/// Backed by Android Keystore / iOS Keychain instead of plain
/// SharedPreferences. Old plain-text values are migrated automatically
/// on first read and then deleted.
class SecureStore {
  SecureStore._();

  static const String tokenKey = 'authToken';
  static const String userIdKey = 'authUserId';
  static const String expiresKey = 'authTokenExpiresAt';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) return value;
    } catch (_) {
      // Keystore unavailable/corrupt -- fall through to legacy check.
    }
    return _migrateLegacy(key);
  }

  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
    // Also make sure no legacy plain-text copy survives.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clearSession() async {
    await delete(tokenKey);
    await delete(userIdKey);
    await delete(expiresKey);
  }

  /// Expiry as epoch millis, or null if none stored.
  static Future<int?> readExpiryMillis() async {
    final raw = await read(expiresKey);
    return raw == null ? null : int.tryParse(raw);
  }

  /// Moves a value saved by older app versions from SharedPreferences
  /// into secure storage, then removes the plain-text copy.
  static Future<String?> _migrateLegacy(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = key == expiresKey
        ? prefs.getInt(key)?.toString()
        : prefs.getString(key);
    if (legacy == null) return null;
    await write(key, legacy);
    await prefs.remove(key);
    return legacy;
  }
}
