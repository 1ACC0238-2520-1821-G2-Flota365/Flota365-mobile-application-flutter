import '../../../domain/entities/maintenance_service_entity.dart';

class MaintenanceServicesState {
  final bool loading;
  final String? error;
  final bool success;
  final List<MaintenanceServiceEntity> services;

  const MaintenanceServicesState({
    this.loading = false,
    this.error,
    this.success = false,
    this.services = const [],
  });

  MaintenanceServicesState copyWith({
    bool? loading,
    String? error,
    bool? success,
    List<MaintenanceServiceEntity>? services,
  }) {
    return MaintenanceServicesState(
      loading: loading ?? this.loading,
      error: error,
      success: success ?? false,
      services: services ?? this.services,
    );
  }
}
