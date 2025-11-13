import 'driver_service.dart';

class DriverRepository {
  final DriverService _service;
  DriverRepository(this._service);

  // Catálogos
  Future<List<Map<String, dynamic>>> getDrivers() async {
    final r = await _service.getDrivers();
    final data = r.data;
    return (data is List) ? data.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getVehicles() async {
    final r = await _service.getVehicles();
    final data = r.data;
    return (data is List) ? data.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
  }

  // Buscar driver por email (para armar la jornada)
  Future<Map<String, dynamic>?> findDriverByEmail(String email) async {
    final list = await getDrivers();
    try {
      return list.firstWhere(
        (d) => (d['email'] ?? '').toString().toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // Primer vehículo 
  Future<Map<String, dynamic>?> getFirstVehicle() async {
    final list = await getVehicles();
    return list.isNotEmpty ? list.first : null;
  }

  // Crear assignment 
  Future<Map<String, dynamic>?> createAssignment({
    required dynamic driverId,
    required dynamic vehicleId,
    required String route,
  }) async {
    final r = await _service.createAssignment(
      driverId: driverId?.toString() ?? '',
      vehicleId: vehicleId?.toString() ?? '',
      route: route,
    );
    final data = r.data;
    return (data is Map) ? (data as Map).cast<String, dynamic>() : null;
  }

  
  Future<List<Map<String, dynamic>>> getAssignmentsForDriver(String driverId) async {
    
    final list = <Map<String, dynamic>>[];
    
    return list.where((a) => (a['driverId']?.toString() ?? '') == driverId).toList();
  }

  // “Perfil” simple: lo obtiene del catálogo de drivers por id
  Future<Map<String, dynamic>?> getDriverProfile(String driverId) async {
    final drivers = await getDrivers();
    try {
      return drivers.firstWhere((d) => (d['id']?.toString() ?? d['code']?.toString() ?? '') == driverId);
    } catch (_) {
      return null;
    }
  }

  Future<void> doCheckIn({required String assignmentId, required Map<String, dynamic> payload}) {
    return _service.putCheckIn(assignmentId, payload);
  }

  Future<void> doCheckOut({required String assignmentId, required Map<String, dynamic> payload}) {
    return _service.putCheckOut(assignmentId, payload);
  }

  Future<Map<String, dynamic>?> findDriverById(String id) async {
  final list = await getDrivers();
  try {
    return list.firstWhere(
      (d) => (d['id']?.toString() ?? d['code']?.toString() ?? '') == id,
    );
  } catch (_) {
    return null;
  }
}

}
