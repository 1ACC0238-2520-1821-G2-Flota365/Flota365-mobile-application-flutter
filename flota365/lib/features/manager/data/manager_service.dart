import 'package:dio/dio.dart';
import '../../../core/constants/api_paths.dart';
import '../../../core/network/dio_client.dart';

class ManagerService {
  final Dio _dio = DioClient.build();

  //  DASHBOARD

  Future<Response> getDashboardStats() {
    return _dio.get(ApiPaths.dashboardStats);
  }

  Future<Response> getActiveVehicles() {
    return _dio.get(ApiPaths.dashboardActiveVehicles);
  }

  Future<Response> getFleetSummary() {
    return _dio.get(ApiPaths.dashboardFleetSummary);
  }

  //  VEHICLES CRUD

  Future<Response> getVehicles() {
    return _dio.get(ApiPaths.vehicles);
  }

  Future<Response> createVehicle(Map<String, dynamic> body) {
    return _dio.post(
      ApiPaths.vehicles,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> updateVehicle(int id, Map<String, dynamic> body) {
    return _dio.put(
      ApiPaths.vehicleById(id),
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> deleteVehicle(int id) {
    return _dio.delete(ApiPaths.vehicleById(id));
  }

  // FLEETS
  Future<Response> getFleets() => _dio.get(ApiPaths.fleets);

  Future<Response> createFleet(Map<String, dynamic> body) {
    return _dio.post(ApiPaths.fleets, data: body);
  }

  Future<Response> updateFleet(int id, Map<String, dynamic> body) {
    return _dio.put(ApiPaths.fleetById(id), data: body);
  }

  Future<Response> deleteFleet(int id) {
    return _dio.delete(ApiPaths.fleetById(id));
  }


  //  REPORTS

  Future<Response> getReports() {
    return _dio.get(ApiPaths.reports);
  }

  Future<Response> createReport(Map<String, dynamic> body) {
    return _dio.post(
      ApiPaths.reports,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  //  MANAGER

  Future<Response> getManagers() {
    return _dio.get(ApiPaths.manager);
  }

  Future<Response> createManager(Map<String, dynamic> body) {
    return _dio.post(
      ApiPaths.manager,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  //  ASSIGNMENTS (RUTAS)

  Future<Response> getAssignments() {
    return _dio.get(ApiPaths.assignment);
  }

  Future<Response> getAssignmentById(int id) {
    return _dio.get(ApiPaths.assignmentById(id));
  }

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

  Future<Response> startAssignment(int id) {
    return _dio.put(ApiPaths.assignmentStart(id));
  }

  Future<Response> completeAssignment(int id) {
    return _dio.put(ApiPaths.assignmentComplete(id));
  }

  Future<Response> getDrivers() {
  return _dio.get("/api/Driver");
}

Future<Response> getDriverById(int id) {
  return _dio.get('/api/Driver/$id'); // o ApiPaths.driverById(id)
}


}
