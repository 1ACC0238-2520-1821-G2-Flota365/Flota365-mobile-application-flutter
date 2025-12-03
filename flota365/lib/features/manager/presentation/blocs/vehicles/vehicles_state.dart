import 'package:equatable/equatable.dart';
import '../../../domain/entities/vehicle_entity.dart';

class VehiclesState extends Equatable {
  final bool loading;
  final List<VehicleEntity> vehicles;
  final String? error;
  final bool actionSuccess; // para saber si alguna acción terminó bien

  const VehiclesState({
    this.loading = false,
    this.vehicles = const [],
    this.error,
    this.actionSuccess = false,
  });

  VehiclesState copyWith({
    bool? loading,
    List<VehicleEntity>? vehicles,
    String? error,
    bool? actionSuccess,
  }) {
    return VehiclesState(
      loading: loading ?? this.loading,
      vehicles: vehicles ?? this.vehicles,
      error: error,
      actionSuccess: actionSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [loading, vehicles, error, actionSuccess];
}
