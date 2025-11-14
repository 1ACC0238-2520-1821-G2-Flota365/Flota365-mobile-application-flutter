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

  // ✅ Perfil por id (Auth/profile/{id}) con fallback a catálogo
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


  // ✅ Si no existe el driver, lo crea automáticamente en /api/Driver
    Future<Map<String, dynamic>> ensureDriverForEmail({
      required String email,
      String? fullName,
    }) async {
      final existing = await findDriverByEmail(email);
      if (existing != null) return existing;

      final parts = (fullName ?? '').trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : 'Conductor';
      final lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final payload = {
        "code": "DRV-${DateTime.now().millisecondsSinceEpoch}",
        "firstName": firstName,
        "lastName": lastName,
        "licenseNumber": "N/A",
        "licenseExpiryDate": DateTime.now()
            .add(const Duration(days: 365))
            .toUtc()
            .toIso8601String(),
        "phone": "",
        "email": email,
        "experienceYears": 0
      };

      final r = await _service.createDriver(payload);
      final data = r.data;
      if (data is Map) return Map<String, dynamic>.from(data as Map);
      throw Exception('No se pudo crear el driver para $email');
    }



  Future<Map<String, dynamic>?> getFirstVehicle() async {
    final list = await getVehicles();
    return list.isNotEmpty ? list.first : null;
  }

  Future<Map<String, dynamic>?> createAssignment({
    required String driverId,
    required String vehicleId,
    required String route,
  }) async {
    if (!_looksLikeGuid(driverId)) {
      throw Exception('driverId no es un GUID (usa el id de /api/Driver, no el numérico de Auth). Valor: $driverId');
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
