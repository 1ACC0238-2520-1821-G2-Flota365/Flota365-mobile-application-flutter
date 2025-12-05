import '../../domain/entities/report_entity.dart';

class ReportDto {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime? createdAt;

  ReportDto({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.createdAt,
  });

  factory ReportDto.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    DateTime? _dt(dynamic v) => (v == null || '$v'.isEmpty) ? null : DateTime.tryParse('$v');

    return ReportDto(
      id: _int(json['id']),
      title: (json['title'] ?? json['subject'] ?? 'Reporte').toString(),
      description: (json['description'] ?? json['details'] ?? '').toString(),
      status: (json['statusName'] ?? json['status'] ?? 'N/A').toString(),
      createdAt: _dt(json['createdAt'] ?? json['date']),
    );
  }

  ReportEntity toEntity() => ReportEntity(
        id: id,
        title: title,
        description: description,
        status: status,
        createdAt: createdAt,
      );
}
