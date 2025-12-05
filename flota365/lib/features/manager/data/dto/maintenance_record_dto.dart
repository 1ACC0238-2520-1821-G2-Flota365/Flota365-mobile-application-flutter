import '../../domain/entities/maintenance_record_entity.dart';

class MaintenanceRecordDto {
  final int id;
  final int vehicleId;
  final String title;
  final String description;
  final String status;
  final DateTime? date;
  final double? cost;

  MaintenanceRecordDto({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.status,
    this.date,
    this.cost,
  });

  factory MaintenanceRecordDto.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    double? _dbl(dynamic v) => (v == null) ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    DateTime? _dt(dynamic v) => (v == null || '$v'.isEmpty) ? null : DateTime.tryParse('$v');

    return MaintenanceRecordDto(
      id: _int(json['id']),
      vehicleId: _int(json['vehicleId'] ?? json['vehicleID']),
      title: (json['title'] ?? json['serviceName'] ?? json['name'] ?? 'Mantenimiento').toString(),
      description: (json['description'] ?? json['notes'] ?? '').toString(),
      status: (json['statusName'] ?? json['status'] ?? 'N/A').toString(),
      date: _dt(json['date'] ?? json['createdAt'] ?? json['performedAt']),
      cost: _dbl(json['cost'] ?? json['amount']),
    );
  }

  MaintenanceRecordEntity toEntity() => MaintenanceRecordEntity(
        id: id,
        vehicleId: vehicleId,
        title: title,
        description: description,
        status: status,
        date: date,
        cost: cost,
      );
}
