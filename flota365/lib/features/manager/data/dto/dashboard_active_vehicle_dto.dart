import '../../domain/entities/dashboard_active_vehicle.dart';

class DashboardActiveVehicleDto {
  final int id;
  final String licensePlate;
  final String model;
  final String driverName;
  final int status;
  final String statusName;
  final String fleetName;
  final String? lastUpdate;
  final String statusColor;

  DashboardActiveVehicleDto({
    required this.id,
    required this.licensePlate,
    required this.model,
    required this.driverName,
    required this.status,
    required this.statusName,
    required this.fleetName,
    required this.lastUpdate,
    required this.statusColor,
  });

  factory DashboardActiveVehicleDto.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return DashboardActiveVehicleDto(
      id: asInt(json['id']),
      licensePlate: (json['licensePlate'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      driverName: (json['driverName'] ?? '').toString(),
      status: asInt(json['status']),
      statusName: (json['statusName'] ?? '').toString(),
      fleetName: (json['fleetName'] ?? '').toString(),
      lastUpdate: json['lastUpdate']?.toString(),
      statusColor: (json['statusColor'] ?? '').toString(),
    );
  }

  DashboardActiveVehicle toEntity() => DashboardActiveVehicle(
        id: id,
        licensePlate: licensePlate,
        model: model,
        driverName: driverName,
        status: status,
        statusName: statusName,
        fleetName: fleetName,
        lastUpdate: lastUpdate == null ? null : DateTime.tryParse(lastUpdate!),
        statusColor: statusColor,
      );
}
