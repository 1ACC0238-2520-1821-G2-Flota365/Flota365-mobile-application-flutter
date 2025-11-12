import 'driver_service.dart';

class DriverRepository {
  final DriverService _service;
  DriverRepository(this._service);

  Future<List<Map<String, dynamic>>> getDrivers() async {
    final r = await _service.getDrivers();
    final data = r.data;
    if (data is List) {
      return data
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getVehicles() async {
    final r = await _service.getVehicles();
    final data = r.data;
    if (data is List) {
      return data
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  // ✅ Perfil por id (Auth/profile/{id})
  Future<Map<String, dynamic>?> getDriverProfile(String driverId) async {
    final json = await _service.getDriverProfile(driverId);
    if (json == null) return null;

    final fullName = (json['fullName'] ??
            '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}')
        .toString()
        .trim();

    return {
      'id': json['id']?.toString(),
      'fullName': fullName.isEmpty ? 'Conductor' : fullName,
      'email': json['email'],
    };
  }

  Future<Map<String, dynamic>?> findDriverById(String id) async {
    final p = await getDriverProfile(id);
    if (p != null) return p;

    final list = await getDrivers();
    try {
      final d = list.firstWhere(
        (e) => (e['id']?.toString() ?? e['code']?.toString() ?? '') == id,
      );
      final fullName = (d['fullName'] ??
              '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}')
          .toString()
          .trim();
      return {
        'id': d['id']?.toString() ?? d['code']?.toString(),
        'fullName': fullName.isEmpty ? 'Conductor' : fullName,
        'email': d['email'],
      };
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

  Future<Map<String, dynamic>?> getFirstVehicle() async {
    final list = await getVehicles();
    return list.isNotEmpty ? list.first : null;
    // si tu API devuelve ids como 'code', ajusta aquí
  }

  // ✅ route como string (según Swagger)
  Future<Map<String, dynamic>?> createAssignment({
    required String driverId,
    required String vehicleId,
    required String route,
  }) async {
    final r = await _service.createAssignment(
      driverId: driverId,
      vehicleId: vehicleId,
      route: route,
    );
    final data = r.data;
    return (data is Map) ? Map<String, dynamic>.from(data as Map) : null;
  }

  Future<List<Map<String, dynamic>>> getAssignmentsForDriver(String driverId) async {
    // TODO: implementar GET real cuando el backend exponga filtro por driverId
    final list = <Map<String, dynamic>>[];
    return list.where((a) => (a['driverId']?.toString() ?? '') == driverId).toList();
  }

  Future<void> doCheckIn({required String assignmentId, required Map<String, dynamic> payload}) {
    return _service.putCheckIn(assignmentId, payload);
  }

  Future<void> doCheckOut({required String assignmentId, required Map<String, dynamic> payload}) {
    return _service.putCheckOut(assignmentId, payload);
  }
}
