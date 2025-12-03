import 'package:flota365/features/manager/domain/entities/assignment_entity.dart';

class AssignmentDto {
  final int id;
  final int vehicleId;
  final int driverId;
  final String route;
  final String status;
  final String? startedAt;
  final String? completedAt;

  AssignmentDto({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.route,
    required this.status,
    this.startedAt,
    this.completedAt,
  });

  factory AssignmentDto.fromJson(Map<String, dynamic> json) {
    return AssignmentDto(
      id: json['id'],
      vehicleId: json['vehicleId'],
      driverId: json['driverId'],
      route: json['route'],
      status: json['status'],
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
    );
  }

  AssignmentEntity toEntity() {
    return AssignmentEntity(
      id: id,
      vehicleId: vehicleId,
      driverId: driverId,
      route: route,
      status: status,
      startedAt: startedAt != null ? DateTime.parse(startedAt!) : null,
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
    );
  }
}
