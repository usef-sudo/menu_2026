import "package:flutter_secure_storage/flutter_secure_storage.dart";

class TokenStore {
  TokenStore(this._storage);

  static const String _accessTokenKey = "menu_access_token";
  static const String _refreshTokenKey = "menu_refresh_token";

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
