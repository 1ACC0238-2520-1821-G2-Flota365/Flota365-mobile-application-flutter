import 'driver_service.dart';

class DriverRepository {
  final DriverService _service;
  DriverRepository(this._service);

  Map<String, dynamic> _normalizeDriver(Map raw) {
    final fullName = (raw['fullName'] ?? '${raw['firstName'] ?? ''} ${raw['lastName'] ?? ''}')
        .toString()
        .trim();
    return {
      'id': (raw['id'] ?? raw['code'] ?? '').toString(),
      'fullName': fullName.isEmpty ? 'Conductor' : fullName,
      'email': raw['email'],
    };
  }

  bool _looksLikeGuid(String s) => RegExp(r'^[0-9a-fA-F-]{32,}$').hasMatch(s);

  Future<List<Map<String, dynamic>>> getDrivers() async {
    final r = await _service.getDrivers();
    final data = r.data;
    if (data is List) {
      return data.where((e) => e is Map).map((e) => _normalizeDriver(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }


  Future<List<Map<String, dynamic>>> getAssignmentsForDriver(String driverId) async {
      final r = await _service.getAssignments();
      final data = r.data;

      if (data is List) {
        final list = data
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        // Filtrar por driverId
        return list.where((e) => e['driverId']?.toString() == driverId).toList();
      }

      return [];
    }
    Future<Map<String, dynamic>?> getAssignmentDetail(String id) async {
      final r = await _service.getAssignmentById(id);
      final data = r.data;

      if (data is Map) return Map<String, dynamic>.from(data);

      return null;
    }



  Future<List<Map<String, dynamic>>> getVehicles() async {
    final r = await _service.getVehicles();
    final data = r.data;
    if (data is List) {
      return data.where((e) => e is Map)
                 .map((e) => Map<String, dynamic>.from(e as Map))
                 .toList();
    }
    return <Map<String, dynamic>>[];
  }

  
  Future<Map<String, dynamic>?> getDriverProfile(String driverId) async {
    final json = await _service.getDriverProfile(driverId);
    if (json != null) return _normalizeDriver(json);
    return await findDriverById(driverId);
  }

  Future<Map<String, dynamic>?> findDriverById(String id) async {
    final list = await getDrivers();
    try {
      return list.firstWhere((e) => (e['id'] ?? '').toString() == id);
    } catch (_) {
      return null;
    }
  }

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
    required String driverId,
    required String vehicleId,
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
    if (!_looksLikeGuid(vehicleId)) {
      throw Exception('vehicleId no es un GUID (usa el id de /api/Vehicle). Valor: $vehicleId');
    }
    final r = await _service.createAssignment(driverId: driverId, vehicleId: vehicleId, route: route);
    final data = r.data;
    return (data is Map) ? Map<String, dynamic>.from(data as Map) : null;
  }

  Future<void> doCheckIn({required String assignmentId, required Map<String, dynamic> payload}) {
    return _service.putCheckIn(assignmentId, payload);
  }

  Future<void> doCheckOut({required String assignmentId, required Map<String, dynamic> payload}) {
    return _service.putCheckOut(assignmentId, payload);
  }

  
}
