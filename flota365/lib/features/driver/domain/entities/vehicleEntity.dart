class VehicleEntity {
  final int id;
  final String licensePlate;
  final String brand;
  final String model;
  final String year;
  final double weight;
  final String fuel;
  final String fleetName;
  final int? driverId;
  final int? fleetId;
  final String status;

  const VehicleEntity({
    required this.id,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.weight,
    required this.fuel,
    required this.fleetName,
    this.driverId,
    this.fleetId,
    required this.status,
  });

  factory VehicleEntity.fromJson(Map<String, dynamic> j) {
    return VehicleEntity(
      id: j['id'] as int,
      licensePlate: j['licensePlate'] ?? '',
      brand: j['brand'] ?? '',
      model: j['model'] ?? '',
      year: j['year'] ?? '',
      weight: (j['weight'] ?? 0).toDouble(),
      fuel: j['fuel'] ?? '',
      fleetName: j['fleetName'] ?? '',
      driverId: j['driverId'],
      fleetId: j['fleetId'],
      status: j['status'] ?? '',
    );
  }
}
