import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flota365/core/enums/status.dart';
import '../../../data/driver_repository.dart';
import '../../../domain/entities/assignmentEntity.dart';
import '../../../domain/entities/driver_info.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DriverRepository repo;

  DashboardBloc(this.repo) : super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
  }

  Future<void> _onStarted(
    DashboardStarted e,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, driverId: e.driverId));

    try {
      // PERFIL
      final profileMap = await repo.getDriverProfile(e.driverId);
      if (profileMap == null) throw Exception("Perfil no encontrado");

      final profile = DriverInfo.fromJson(profileMap);

      // ASSIGNMENTS
      final list = await repo.getAssignmentsForDriver(e.driverId);
      final assignments =
          list.map((item) => AssignmentEntity.fromJson(item)).toList();

      // ACTIVE = IN_PROGRESS
      AssignmentEntity? active;
      try {
        active = assignments.firstWhere(
            (a) => (a.status ?? "").toUpperCase() == "IN_PROGRESS");
      } catch (_) {
        active = null;
      }

      emit(
        state.copyWith(
          status: Status.success,
          profile: profile,

          assignments: assignments,

          current: active,
          clearError: true,
        ),
      );
    } catch (err) {
      emit(state.copyWith(
        status: Status.failure,
        error: err.toString(),
      ));
    }
  }
}
