import 'package:dio/dio.dart';
import '../domain/user.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _service;
  AuthRepository(this._service);

  // LOGIN
  Future<User> login(String email, String password) async {
    final Response res = await _service.login(
      email: email,
      password: password,
    );

    if (res.data is! Map<String, dynamic>) {
      throw 'Respuesta inesperada del backend: ${res.data}';
    }

    return User.fromJson(res.data as Map<String, dynamic>);
  }

  // REGISTER
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role, // driver | manager
  }) async {
    final payload = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
    };

    final res = await _service.register(payload);

    if (res.data is! Map<String, dynamic>) {
      throw 'Respuesta inesperada del backend: ${res.data}';
    }

    return User.fromJson(res.data as Map<String, dynamic>);
  }

  // GET PROFILE
  Future<User> getProfile(int id) async {
    final Response res = await _service.getProfile(id);

    if (res.data is! Map<String, dynamic>) {
      throw 'Respuesta inesperada del backend: ${res.data}';
    }

    return User.fromJson(res.data as Map<String, dynamic>);
  }
}
