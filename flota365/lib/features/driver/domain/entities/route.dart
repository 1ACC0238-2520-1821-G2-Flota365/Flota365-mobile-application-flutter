// Archivo: lib/features/driver/domain/entities/route.dart

class RouteEntity {
  final String id;
  final String name;
  final String status;
  final double weight;
  final double height;
  final int restrictedRoads;

  const RouteEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.weight,
    required this.height,
    required this.restrictedRoads,
  });

  // Constructor de ejemplo para simular datos
  factory RouteEntity.example() {
    return const RouteEntity(
      id: 'RT-045',
      name: 'Ruta Sur 045',
      status: 'En curso',
      weight: 18.5,
      height: 3.8,
      restrictedRoads: 1,
    );
  }
}

class RouteDetailEntity extends RouteEntity {
  final double progress;
  final String timeElapsed;
  final double distance;
  final int remainingStops;
  final String currentStop;

  const RouteDetailEntity({
    required super.id,
    required super.name,
    required super.status,
    required super.weight,
    required super.height,
    required super.restrictedRoads,
    required this.progress,
    required this.timeElapsed,
    required this.distance,
    required this.remainingStops,
    required this.currentStop,
  });

  // Constructor de ejemplo para simular datos de detalle
  factory RouteDetailEntity.example() {
    return RouteDetailEntity(
      id: 'RT-045',
      name: 'Ruta Sur 045',
      status: 'En curso',
      weight: 18.5,
      height: 3.8,
      restrictedRoads: 1,
      progress: 0.5, // 50% de progreso
      timeElapsed: '1h 2min',
      distance: 114.8,
      remainingStops: 5,
      currentStop: 'Punto C (visualizado en el mapa)',
    );
  }
}