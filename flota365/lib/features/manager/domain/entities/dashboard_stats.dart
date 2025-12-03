class DashboardStats {
  final int totalVehicles;
  final int activeDrivers;
  final int vehiclesInMaintenance;
  final double fleetEfficiency;
  final int totalFleets;
  final int alertsCount;

  const DashboardStats({
    required this.totalVehicles,
    required this.activeDrivers,
    required this.vehiclesInMaintenance,
    required this.fleetEfficiency,
    required this.totalFleets,
    required this.alertsCount,
  });
}
