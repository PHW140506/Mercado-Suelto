import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSource({required this.storage});

  Future<void> saveSession({
    required String token,
    required int userId,
    required String role,
  }) async {
    await storage.write(key: 'auth_token', value: token);
    await storage.write(key: 'user_id', value: userId.toString());
    await storage.write(key: 'user_role', value: role);
  }

  Future<Map<String, String?>?> getSession() async {
    final token = await storage.read(key: 'auth_token');
    final userId = await storage.read(key: 'user_id');
    final role = await storage.read(key: 'user_role');

    if (token != null && userId != null && role != null) {
      return {'token': token, 'userId': userId, 'role': role};
    }
    return null;
  }

  Future<void> clearSession() async {
    await storage.deleteAll();
  }
}