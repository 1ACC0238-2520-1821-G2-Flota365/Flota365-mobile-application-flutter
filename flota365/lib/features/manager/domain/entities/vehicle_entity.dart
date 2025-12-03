class VehicleEntity {
  final int id;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final int mileage;

  final String status;
  final DateTime? statusDate;

  final String driverName;

  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final int fleetId;
  final String fleetName;

  VehicleEntity({
    required this.id,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.status,
    required this.statusDate,
    required this.driverName,
    required this.lastServiceDate,
    required this.nextServiceDate,
    required this.createdAt,
    required this.updatedAt,
    required this.fleetId,
    required this.fleetName,
  });
}
