class FleetEntity {
  final int id;
  final String name;
  final String description;
  final int type;
  final bool isActive;

  int vehicleCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FleetEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isActive,
    required this.vehicleCount,
    this.createdAt,
    this.updatedAt,
  });
}
