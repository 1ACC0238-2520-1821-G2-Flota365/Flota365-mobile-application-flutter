class DashboardActiveVehicle {
  final int id;
  final String licensePlate;
  final String model; // viene ya combinado
  final String driverName;
  final int status;
  final String statusName;
  final String fleetName;
  final DateTime? lastUpdate;
  final String statusColor;

  const DashboardActiveVehicle({
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
}
