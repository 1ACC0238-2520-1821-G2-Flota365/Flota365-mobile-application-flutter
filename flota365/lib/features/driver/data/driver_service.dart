import 'package:dio/dio.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/network/dio_client.dart';

class DriverService {
  final Dio _dio = DioClient.build();

  Future<Response> getDrivers() => _dio.get(ApiPaths.drivers);
  Future<Response> getVehicles() => _dio.get(ApiPaths.vehicles);

  // POST /api/Assignment  ► el backend espera {"request": {...}}
  Future<Response> createAssignment({
    required String driverId,
    required String vehicleId,
    required String route,
  }) {
    final payload = {
      'request': {
        'driverId': driverId,
        'vehicleId': vehicleId,
        'route': route,
      }
    };
    return _dio.post(
      ApiPaths.assignment,
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  // PUT /api/Assignment/{id}/start  ► también enviar como {"request": {...}} si tu backend lo pide
  Future<Response> putCheckIn(String assignmentId, Map<String, dynamic> body) {
    final payload = body.containsKey('request') ? body : {'request': body};
    return _dio.put(
      ApiPaths.assignmentStart(assignmentId),
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  // PUT /api/Assignment/{id}/complete
  Future<Response> putCheckOut(String assignmentId, Map<String, dynamic> body) {
    final payload = body.containsKey('request') ? body : {'request': body};
    return _dio.put(
      ApiPaths.assignmentComplete(assignmentId),
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );
  }
}
