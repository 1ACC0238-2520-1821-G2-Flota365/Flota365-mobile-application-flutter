class Assignment {
  final String id;
  final String driverId;
  final String vehicleId;
  final String route;
  final String? status;
  final String? assignedAt;
  final String? completedAt;

  const Assignment({
    required this.id,
    required this.driverId,
    required this.vehicleId,
    required this.route,
    this.status,
    this.assignedAt,
    this.completedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> j) => Assignment(
    id: j['id']?.toString() ?? '',
    driverId: j['driverId']?.toString() ?? '',
    vehicleId: j['vehicleId']?.toString() ?? '',
    route: j['route']?.toString() ?? '',
    status: j['status']?.toString(),
    assignedAt: j['assignedAt']?.toString(),
    completedAt: j['completedAt']?.toString(),
  );

  bool get isCompleted => completedAt != null || (status ?? '').toLowerCase() == 'completed';
}
