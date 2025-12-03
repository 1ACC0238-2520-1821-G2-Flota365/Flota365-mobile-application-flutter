import 'package:flota365/features/manager/domain/entities/fleet_entity.dart';

class FleetState {
  final bool loading;
  final List<FleetEntity> fleets;
  final String? error;
  final bool actionSuccess;

  FleetState({
    this.loading = false,
    this.fleets = const [],
    this.error,
    this.actionSuccess = false,
  });

  FleetState copyWith({
    bool? loading,
    List<FleetEntity>? fleets,
    String? error,
    bool? actionSuccess,
  }) {
    return FleetState(
      loading: loading ?? this.loading,
      fleets: fleets ?? this.fleets,
      error: error,
      actionSuccess: actionSuccess ?? false,
    );
  }
}
