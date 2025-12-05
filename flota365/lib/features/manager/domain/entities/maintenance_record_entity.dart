class MaintenanceRecordEntity {
  final int id;
  final int vehicleId;
  final String title;        // ejemplo: “Cambio de aceite”
  final String description;  // notas
  final String status;       // “Open/Closed/Overdue” o lo que venga
  final DateTime? date;      // fecha del registro
  final double? cost;

  const MaintenanceRecordEntity({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.status,
    this.date,
    this.cost,
  });
}
