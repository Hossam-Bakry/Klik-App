import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the access token in platform secure storage (Keychain / Keystore).
/// This is the one bit of local persistence we keep even in an online-only
/// app — tokens must survive restarts so the user stays logged in.
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  @override
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);
}
