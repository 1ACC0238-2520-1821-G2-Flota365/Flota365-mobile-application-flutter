import '../../domain/entities/maintenance_service_entity.dart';

class MaintenanceServiceDto {
  final int id;
  final String name;
  final String? description;

  MaintenanceServiceDto({required this.id, required this.name, this.description});

  factory MaintenanceServiceDto.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    return MaintenanceServiceDto(
      id: _int(json['id']),
      name: (json['name'] ?? json['title'] ?? 'Servicio').toString(),
      description: (json['description'] ?? json['details'])?.toString(),
    );
  }

  MaintenanceServiceEntity toEntity() => MaintenanceServiceEntity(
        id: id,
        name: name,
        description: description,
      );
}
