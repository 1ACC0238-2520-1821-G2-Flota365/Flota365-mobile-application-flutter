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


  // ==============================
// MAINTENANCE
// ==============================
Future<Response> getMaintenanceRecords() {
  return _dio.get('/api/Maintenance/records');
}

Future<Response> createMaintenanceRecord(Map<String, dynamic> data) {
  return _dio.post(
    '/api/Maintenance/records',
    data: data,
    options: Options(contentType: Headers.jsonContentType),
  );
}

Future<Response> getMaintenanceRecordById(int id) {
  return _dio.get('/api/Maintenance/records/$id');
}

Future<Response> updateMaintenanceRecord(int id, Map<String, dynamic> data) {
  return _dio.put(
    '/api/Maintenance/records/$id',
    data: data,
    options: Options(contentType: Headers.jsonContentType),
  );
}

Future<Response> deleteMaintenanceRecord(int id) {
  return _dio.delete('/api/Maintenance/records/$id');
}

Future<Response> getMaintenanceRecordsByVehicle(int vehicleId) {
  return _dio.get('/api/Maintenance/records/vehicle/$vehicleId');
}

Future<Response> getMaintenanceOverdue() {
  return _dio.get('/api/Maintenance/records/overdue');
}

// ---- Services (catálogo) ----
Future<Response> getMaintenanceServices() {
  return _dio.get('/api/Maintenance/services');
}

Future<Response> createMaintenanceService(Map<String, dynamic> data) {
  return _dio.post(
    '/api/Maintenance/services',
    data: data,
    options: Options(contentType: Headers.jsonContentType),
  );
}

Future<Response> getMaintenanceServiceById(int id) {
  return _dio.get('/api/Maintenance/services/$id');
}

Future<Response> deleteMaintenanceService(int id) {
  return _dio.delete('/api/Maintenance/services/$id');
}

Future<Response> getMaintenanceServicesByVehicle(int vehicleId) {
  return _dio.get('/api/Maintenance/services/vehicle/$vehicleId');
}

// ==============================
// REPORT
// ==============================
Future<Response> getReports() {
  return _dio.get('/api/Report');
}

Future<Response> createReport(Map<String, dynamic> data) {
  return _dio.post(
    '/api/Report',
    data: data,
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
// ==============================
// USER (en módulo MANAGER, pero endpoints Auth)
// ==============================

Future<Response> getAuthProfileById(int id) {
  return _dio.get(ApiPaths.authProfileId(id));
}

Future<Response> updateAuthProfileById(int id, Map<String, dynamic> body) {
  return _dio.put(
    ApiPaths.authProfileId(id),
    data: body,
    options: Options(contentType: Headers.jsonContentType),
  );
}

Future<Response> changeAuthPasswordById(int id, Map<String, dynamic> body) {
  return _dio.post(
    ApiPaths.authChangePassword(id),
    data: body,
    options: Options(contentType: Headers.jsonContentType),
  );
}



}
