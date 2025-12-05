import '../../../domain/entities/maintenance_record_entity.dart';

class MaintenanceRecordsState {
  final bool loading;
  final String? error;
  final bool success;
  final List<MaintenanceRecordEntity> records;

  const MaintenanceRecordsState({
    this.loading = false,
    this.error,
    this.success = false,
    this.records = const [],
  });

  MaintenanceRecordsState copyWith({
    bool? loading,
    String? error,
    bool? success,
    List<MaintenanceRecordEntity>? records,
  }) {
    return MaintenanceRecordsState(
      loading: loading ?? this.loading,
      error: error,
      success: success ?? false,
      records: records ?? this.records,
    );
  }
}
