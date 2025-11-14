import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_paths.dart';

class AuthService {
  final Dio _dio = DioClient.build();

  Future<Response> loginRaw({
    required String email,
    required String password,
  }) {
    return _dio.post(
      ApiPaths.authLogin,
      data: {'email': email, 'password': password},
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> registerRaw(Map<String, dynamic> payload) {
    return _dio.post(
      ApiPaths.authRegister,
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );
  }
    Future<Response> register(Map<String, dynamic> body) {
    return _dio.post(
      ApiPaths.authRegister,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

}
