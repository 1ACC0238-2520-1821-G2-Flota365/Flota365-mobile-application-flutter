import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/keys.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: Keys.accessToken, value: token);

  static Future<String?> readAccessToken() =>
      _storage.read(key: Keys.accessToken);

  static Future<void> clearTokens() async {
    await _storage.delete(key: Keys.accessToken);
    await _storage.delete(key: Keys.refreshToken);
  }
}
