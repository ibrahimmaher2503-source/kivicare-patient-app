import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../screens/auth/model/login_response.dart';

/// Stores authentication material outside GetStorage.
///
/// Passwords are intentionally never persisted. The API token is kept in the
/// platform keychain/keystore alongside the PII-bearing user profile.
class SecureSessionStorage {
  SecureSessionStorage._();

  static const _apiTokenKey = 'session_api_token';
  static const _userProfileKey = 'session_user_profile';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> writeApiToken(String token) async {
    if (token.trim().isEmpty) {
      await deleteApiToken();
      return;
    }
    await _storage.write(key: _apiTokenKey, value: token);
  }

  static Future<String?> readApiToken() => _storage.read(key: _apiTokenKey);

  static Future<void> deleteApiToken() => _storage.delete(key: _apiTokenKey);

  static Future<void> writeUser(UserData user) async {
    await writeApiToken(user.apiToken);
    final profile = Map<String, dynamic>.from(user.toJson());
    profile.remove('api_token');
    await _storage.write(key: _userProfileKey, value: jsonEncode(profile));
  }

  static Future<UserData?> readUser() async {
    final profileJson = await _storage.read(key: _userProfileKey);
    final token = await readApiToken();
    if (profileJson == null || token == null || token.trim().isEmpty) {
      return null;
    }
    final decoded = jsonDecode(profileJson);
    if (decoded is! Map) return null;
    final user = UserData.fromJson(decoded.cast<String, dynamic>());
    user.apiToken = token;
    return user;
  }

  static Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _apiTokenKey),
      _storage.delete(key: _userProfileKey),
    ]);
  }
}
