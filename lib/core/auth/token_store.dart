import "package:flutter_secure_storage/flutter_secure_storage.dart";

class TokenStore {
  TokenStore(this._storage);

  static const String _accessTokenKey = "menu_access_token";
  static const String _refreshTokenKey = "menu_refresh_token";
  static const String _userRoleKey = "menu_user_role";

  final FlutterSecureStorage _storage;

  /// Android Keystore can fail on some devices; encrypted prefs is more reliable.
  static FlutterSecureStorage createDefault() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (_) {}
  }

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (_) {}
  }

  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserRole(String? role) async {
    try {
      if (role == null || role.isEmpty) {
        await _storage.delete(key: _userRoleKey);
        return;
      }
      await _storage.write(key: _userRoleKey, value: role);
    } catch (_) {}
  }

  Future<String?> readUserRole() async {
    try {
      return await _storage.read(key: _userRoleKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userRoleKey);
    } catch (_) {}
  }
}
