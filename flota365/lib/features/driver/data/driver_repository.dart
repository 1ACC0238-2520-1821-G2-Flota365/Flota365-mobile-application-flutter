import 'driver_service.dart';

class DriverRepository {
  final DriverService _service;
  DriverRepository(this._service);

  Map<String, dynamic> _normalizeDriver(Map raw) {
    final fullName = (raw['fullName'] ??
            '${raw['firstName'] ?? ''} ${raw['lastName'] ?? ''}')
        .toString()
        .trim();

    return {
      'id': raw['id'] is int ? raw['id'] : int.tryParse(raw['id'].toString()) ?? 0,
      'fullName': fullName.isEmpty ? 'Conductor' : fullName,
      'email': raw['email'],
    };
  }

  // ---------------------- DRIVERS ----------------------

  Future<List<Map<String, dynamic>>> getDrivers() async {
    final r = await _service.getDrivers();
    final data = r.data;

    if (data is List) {
      return data
          .where((e) => e is Map)
          .map((e) => _normalizeDriver(e as Map))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>?> getDriverProfile(int driverId) async {
    final json = await _service.getDriverProfile(driverId);
    if (json != null) return _normalizeDriver(json);
    return await findDriverById(driverId);
  }

  Future<Map<String, dynamic>?> findDriverById(int id) async {
    final list = await getDrivers();
    try {
      return list.firstWhere((e) => e['id'] == id);
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

  // Crear driver si no existe
  Future<Map<String, dynamic>> ensureDriverForEmail({
    required String email,
    String? fullName,
  }) async {
    final existing = await findDriverByEmail(email);
    if (existing != null) return existing;

    final parts = (fullName ?? '').trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : 'Conductor';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final payload = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
    };

    final r = await _service.createDriver(payload);
    final data = r.data;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('No se pudo crear el driver');
  }

  // ---------------------- VEHICLES ----------------------

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

  Future<Map<String, dynamic>?> getFirstVehicle() async {
    final list = await getVehicles();
    return list.isNotEmpty ? list.first : null;
  }

  // ---------------------- ASSIGNMENTS ----------------------

  Future<List<Map<String, dynamic>>> getAssignmentsForDriver(int driverId) async {
    final r = await _service.getAssignments();
    final data = r.data;

    if (data is List) {
      final list = data
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      return list.where((e) => e['driverId'] == driverId).toList();
    }

    return [];
  }

  Future<Map<String, dynamic>?> getAssignmentDetail(int id) async {
  final r = await _service.getAssignments();
  final data = r.data;

  if (data is List) {
    final list = data
        .where((e) => e is Map)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    try {
      return list.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  return null;
}


  Future<Map<String, dynamic>?> createAssignment({
    required int driverId,
    required int vehicleId,
    required String route,
  }) async {
    final r = await _service.createAssignment(
      driverId: driverId,
      vehicleId: vehicleId,
      route: route,
    );
    final data = r.data;
    return (data is Map) ? Map<String, dynamic>.from(data) : null;
  }

  // CHECK-IN / CHECK-OUT

  Future<void> doCheckIn({
    required int assignmentId,
    required Map<String, dynamic> payload,
  }) {
    return _service.putCheckIn(assignmentId, payload);
  }

  Future<void> doCheckOut({
    required int assignmentId,
    required Map<String, dynamic> payload,
  }) {
    return _service.putCheckOut(assignmentId, payload);
  }
}
