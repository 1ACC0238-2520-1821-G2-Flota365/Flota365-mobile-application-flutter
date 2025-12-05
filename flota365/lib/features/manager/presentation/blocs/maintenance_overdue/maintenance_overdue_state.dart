import '../../../domain/entities/maintenance_record_entity.dart';

class MaintenanceOverdueState {
  final bool loading;
  final String? error;
  final List<MaintenanceRecordEntity> records;

  const MaintenanceOverdueState({
    this.loading = false,
    this.error,
    this.records = const [],
  });

  MaintenanceOverdueState copyWith({
    bool? loading,
    String? error,
    List<MaintenanceRecordEntity>? records,
  }) {
    return MaintenanceOverdueState(
      loading: loading ?? this.loading,
      error: error,
      records: records ?? this.records,
    );
  }
}
