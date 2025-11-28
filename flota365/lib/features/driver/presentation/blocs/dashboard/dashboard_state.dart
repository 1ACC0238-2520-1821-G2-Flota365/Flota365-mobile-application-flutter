import 'package:equatable/equatable.dart';
import 'package:flota365/core/enums/status.dart';
import '../../../domain/entities/assignmentEntity.dart';
import '../../../domain/entities/driver_info.dart';

class DashboardState extends Equatable {
  final Status status;
  final int driverId;
  final DriverInfo? profile;

  /// LISTA COMPLETA DE ASSIGNMENTS
  final List<AssignmentEntity> assignments;

  /// ASSIGNMENT ACTIVO
  final AssignmentEntity? current;

  final String? error;

  const DashboardState({
    this.status = Status.initial,
    this.driverId = 0,
    this.profile,
    this.assignments = const [],
    this.current,
    this.error,
  });

  DashboardState copyWith({
    Status? status,
    int? driverId,
    DriverInfo? profile,
    List<AssignmentEntity>? assignments,
    AssignmentEntity? current,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      profile: profile ?? this.profile,

      assignments: assignments ?? this.assignments,

      current: current ?? this.current,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        status,
        driverId,
        profile,
        assignments,
        current,
        error,
      ];
}
