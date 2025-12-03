import 'package:flota365/features/manager/domain/entities/fleet_entity.dart';

class FleetDto {
  final int id;
  final String name;
  final String description;
  final int type;
  final bool isActive;
  final int vehicleCount;

  final String? createdAt;
  final String? updatedAt;

  FleetDto({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isActive,
    required this.vehicleCount,
    this.createdAt,
    this.updatedAt,
  });

  factory FleetDto.fromJson(Map<String, dynamic> json) {
    return FleetDto(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      isActive: json['isActive'] ?? true,
      vehicleCount: json['vehicleCount'] ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  FleetEntity toEntity() {
    return FleetEntity(
      id: id,
      name: name,
      description: description,
      type: type,
      isActive: isActive,
      vehicleCount: vehicleCount,
      createdAt: DateTime.tryParse(createdAt ?? ''),
      updatedAt: DateTime.tryParse(updatedAt ?? ''),
    );
  }
}
