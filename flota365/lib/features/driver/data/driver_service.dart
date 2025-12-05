import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/network/dio_client.dart';

class DriverService {
  final Dio _dio = DioClient.build();

  // --- Auth/Profile ---
  Future<Map<String, dynamic>?> getDriverProfile(int id) async {
    try {
      final r = await _dio.get(ApiPaths.authProfileId(id));
      final data = r.data;
      return (data is Map) ? Map<String, dynamic>.from(data) : null;
    } catch (_) {
      return null;
    }
  }

  // --- Drivers ---
  Future<Response> getDrivers() => _dio.get(ApiPaths.drivers);

  // --- Vehicles ---
  Future<Response> getVehicles() => _dio.get(ApiPaths.vehicles);

  // --- Crear Driver ---
  Future<Response> createDriver(Map<String, dynamic> body) {
    return _dio.post(
      ApiPaths.drivers,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  // --- Assignment ---
  Future<Response> createAssignment({
    required int driverId,
    required int vehicleId,
    required String route,
  }) {
    final payload = {
      'driverId': driverId,
      'vehicleId': vehicleId,
      'route': route,
    };

    return _dio.post(
      ApiPaths.assignment,
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  // GET ALL ASSIGNMENTS
  Future<Response> getAssignments() async {
  try {
    final res = await _dio.get(ApiPaths.assignment);
    debugPrint("GET ${ApiPaths.assignment} => ${res.statusCode}");
    debugPrint("Assignments data type => ${res.data.runtimeType}");
    if (res.data is List) {
      debugPrint("Assignments count => ${(res.data as List).length}");
      if ((res.data as List).isNotEmpty) {
        debugPrint("Assignment[0] => ${(res.data as List).first}");
      }
    } else {
      debugPrint("Assignments body => ${res.data}");
    }
    return res;
  } catch (e) {
    debugPrint("GET ${ApiPaths.assignment} ERROR => $e");
    rethrow;
  }
}


  // GET ASSIGNMENT DETAIL
  Future<Response> getAssignmentById(int id) {
    return _dio.get(ApiPaths.assignmentById(id));
  }

  // CHECK-IN
  Future<Response> putCheckIn(int assignmentId, Map<String, dynamic> body) {
    return _dio.put(
      ApiPaths.assignmentStart(assignmentId),
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  // CHECK-OUT
  Future<Response> putCheckOut(int assignmentId, Map<String, dynamic> body) {
    return _dio.put(
      ApiPaths.assignmentComplete(assignmentId),
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }
}
