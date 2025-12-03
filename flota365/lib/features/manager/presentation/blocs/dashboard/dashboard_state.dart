import 'package:flota365/features/manager/domain/entities/dashboard_active_vehicle.dart';
import '../../../domain/entities/dashboard_stats.dart';

class DashboardState {
  final bool loading;
  final String? error;

  final DashboardStats? stats;
  final List<DashboardActiveVehicle> activeVehicles;

  final dynamic fleetSummary;

  const DashboardState({
    this.loading = false,
    this.error,
    this.stats,
    this.activeVehicles = const [],
    this.fleetSummary,
  });

  DashboardState copyWith({
    bool? loading,
    String? error,
    DashboardStats? stats,
    List<DashboardActiveVehicle>? activeVehicles,
    dynamic fleetSummary,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      error: error,
      stats: stats ?? this.stats,
      activeVehicles: activeVehicles ?? this.activeVehicles,
      fleetSummary: fleetSummary ?? this.fleetSummary,
    );
  }
}
