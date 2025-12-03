import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsDto {
  final int totalVehicles;
  final int activeDrivers;
  final int vehiclesInMaintenance;
  final double fleetEfficiency;
  final int totalFleets;
  final int alertsCount;

  DashboardStatsDto({
    required this.totalVehicles,
    required this.activeDrivers,
    required this.vehiclesInMaintenance,
    required this.fleetEfficiency,
    required this.totalFleets,
    required this.alertsCount,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    double asDouble(dynamic v) =>
        v is double ? v : double.tryParse(v?.toString() ?? '') ?? 0.0;

    return DashboardStatsDto(
      totalVehicles: asInt(json['totalVehicles']),
      activeDrivers: asInt(json['activeDrivers']),
      vehiclesInMaintenance: asInt(json['vehiclesInMaintenance']),
      fleetEfficiency: asDouble(json['fleetEfficiency']),
      totalFleets: asInt(json['totalFleets']),
      alertsCount: asInt(json['alertsCount']),
    );
  }

  DashboardStats toEntity() => DashboardStats(
        totalVehicles: totalVehicles,
        activeDrivers: activeDrivers,
        vehiclesInMaintenance: vehiclesInMaintenance,
        fleetEfficiency: fleetEfficiency,
        totalFleets: totalFleets,
        alertsCount: alertsCount,
      );
}
