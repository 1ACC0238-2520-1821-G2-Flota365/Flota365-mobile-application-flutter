import '../../domain/entities/vehicle_entity.dart';

class VehicleDto {
  final int id;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final int mileage;

  final String status;
  final String? statusDate;

  final String driverName;

  final String? lastServiceDate;
  final String? nextServiceDate;

  final String? createdAt;
  final String? updatedAt;

  final int fleetId;
  final String fleetName;

  VehicleDto({
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

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      id: json['id'],
      licensePlate: json['licensePlate'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      mileage: json['mileage'],
      status: json['status']?.toString() ?? '',
      statusDate: json['statusDate'],
      driverName: json['driverName'] ?? '',
      lastServiceDate: json['lastServiceDate'],
      nextServiceDate: json['nextServiceDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      fleetId: json['fleetId'],
      fleetName: json['fleetName'],
    );
  }

  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      licensePlate: licensePlate,
      brand: brand,
      model: model,
      year: year,
      mileage: mileage,
      status: status,
      statusDate: _parse(statusDate),
      driverName: driverName,
      lastServiceDate: _parse(lastServiceDate),
      nextServiceDate: _parse(nextServiceDate),
      createdAt: _parse(createdAt),
      updatedAt: _parse(updatedAt),
      fleetId: fleetId,
      fleetName: fleetName,
    );
  }

  DateTime? _parse(String? date) {
    if (date == null) return null;
    return DateTime.tryParse(date);
  }
}
