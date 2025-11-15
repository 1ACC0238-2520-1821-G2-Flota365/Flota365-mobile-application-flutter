import 'package:dio/dio.dart';
import '../domain/user.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _service;
  AuthRepository(this._service);

 
  Future<(User, String?)> login(String email, String password) async {
    final Response res =
        await _service.loginRaw(email: email, password: password);

    if (res.data is! Map<String, dynamic>) {
      throw 'Respuesta inesperada del backend: ${res.data}';
    }

    final Map<String, dynamic> json = res.data as Map<String, dynamic>;
    final user = User.fromJson(json);

    // No hay token por ahora
    return (user, null);
  }

  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role, // 'driver' | 'manager'
  }) async {
    final res = await _service.registerRaw({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    });

    if (res.data is! Map<String, dynamic>) {
      throw 'Respuesta inesperada del backend: ${res.data}';
    }
    return User.fromJson(res.data as Map<String, dynamic>);
  }
    
  Future<Map<String, dynamic>?> registerRaw(Map<String, dynamic> payload) async {
    try {
      final res = await _service.register(payload);
      final data = res.data;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

}
