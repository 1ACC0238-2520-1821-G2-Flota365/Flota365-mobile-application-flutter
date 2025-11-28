class RouteStop {
  final double lat;
  final double lng;
  final String? name;

  const RouteStop({
    required this.lat,
    required this.lng,
    this.name,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'name': name,
      };
}

class RoutePoint {
  final double lat;
  final double lng;

  const RoutePoint({
    required this.lat,
    required this.lng,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}

class AssignmentEntity {
  final int id;
  final String route;
  final String? status;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final int? vehicleId;

  // Coordenadas de inicio/fin para el mapa
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

  // Paradas intermedias
  final List<RouteStop> stops;

  // Puntos del trayecto (para polilínea)
  final List<RoutePoint> pathPoints;

  // Tracking
  final double? distanceKm; // Distancia total estimada
  final int? estimatedMinutes; // Tiempo total estimado en minutos
  final int completedStops; // Paradas completadas (definidas desde backend)

  const AssignmentEntity({
    required this.id,
    required this.route,
    this.status,
    this.assignedAt,
    this.completedAt,
    this.vehicleId,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.stops = const [],
    this.pathPoints = const [],
    this.distanceKm,
    this.estimatedMinutes,
    this.completedStops = 0,
  });

  // -------- GETTERS DE TRACKING --------

  int get totalStops => stops.length;

  int get remainingStops {
    if (totalStops == 0) return 0;
    final c = completedStops.clamp(0, totalStops);
    return totalStops - c;
  }


  double? get progressFraction {
    if (totalStops == 0) return null;
    return completedStops.clamp(0, totalStops) / totalStops;
  }


  RouteStop? get currentStop {
    if (totalStops == 0) return null;
    final idx = completedStops.clamp(0, totalStops - 1);
    return stops[idx];
  }

  // -------- JSON --------

  factory AssignmentEntity.fromJson(Map<String, dynamic> json) {
    final stopsJson = (json['stops'] as List?) ?? const [];
    final pathJson = (json['pathPoints'] as List?) ?? const [];

    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    double? _d(dynamic v) => (v is num) ? v.toDouble() : null;

    return AssignmentEntity(
      id: json['id'] as int,
      route: json['route']?.toString() ?? 'Ruta',
      status: json['status'] as String?,
      assignedAt: _parseDate(json['assignedAt']),
      completedAt: _parseDate(json['completedAt']),
      vehicleId: json['vehicleId'] as int?,
      startLat: _d(json['startLat']),
      startLng: _d(json['startLng']),
      endLat: _d(json['endLat']),
      endLng: _d(json['endLng']),
      distanceKm: _d(json['distanceKm'] ?? json['distance_km']),
      estimatedMinutes:
          (json['estimatedMinutes'] ?? json['estimated_minutes']) as int?,
      completedStops: (json['completedStops'] ?? json['completed_stops'] ?? 0)
          as int,
      stops: stopsJson
          .whereType<Map<String, dynamic>>()
          .map(RouteStop.fromJson)
          .toList(),
      pathPoints: pathJson
          .whereType<Map<String, dynamic>>()
          .map(RoutePoint.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'route': route,
        'status': status,
        'assignedAt': assignedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'vehicleId': vehicleId,
        'startLat': startLat,
        'startLng': startLng,
        'endLat': endLat,
        'endLng': endLng,
        'distanceKm': distanceKm,
        'estimatedMinutes': estimatedMinutes,
        'completedStops': completedStops,
        'stops': stops.map((s) => s.toJson()).toList(),
        'pathPoints': pathPoints.map((p) => p.toJson()).toList(),
      };
}
