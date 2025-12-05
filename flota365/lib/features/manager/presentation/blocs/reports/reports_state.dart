import '../../../domain/entities/report_entity.dart';

class ReportsState {
  final bool loading;
  final String? error;
  final bool success;
  final List<ReportEntity> reports;

  const ReportsState({
    this.loading = false,
    this.error,
    this.success = false,
    this.reports = const [],
  });

  ReportsState copyWith({
    bool? loading,
    String? error,
    bool? success,
    List<ReportEntity>? reports,
  }) {
    return ReportsState(
      loading: loading ?? this.loading,
      error: error,
      success: success ?? false,
      reports: reports ?? this.reports,
    );
  }
}
