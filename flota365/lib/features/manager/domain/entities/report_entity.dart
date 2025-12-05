class ReportEntity {
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime? createdAt;

  const ReportEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.createdAt,
  });
}
