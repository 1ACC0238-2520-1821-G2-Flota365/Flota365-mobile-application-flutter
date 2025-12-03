class AssignmentEntity {
  final int id;
  final int vehicleId;
  final int driverId;
  final String route;          // "Origen -> Destino"
  final String status;         // Created / Started / Completed
  final DateTime? startedAt;
  final DateTime? completedAt;

  AssignmentEntity({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.route,
    required this.status,
    this.startedAt,
    this.completedAt,
  });
}
