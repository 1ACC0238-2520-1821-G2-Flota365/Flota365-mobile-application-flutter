import 'package:flutter_bloc/flutter_bloc.dart';
import 'assignment_event.dart';
import 'assignment_state.dart';
import '../../../data/manager_repository.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final ManagerRepository repo;

  AssignmentBloc(this.repo) : super(const AssignmentState()) {
    
    // ============================
    // CARGAR LISTA DE RUTAS
    // ============================
    on<LoadAssignments>((event, emit) async {
      emit(state.copyWith(loading: true, error: null, success: false));

      try {
        final data = await repo.getAssignments();
        emit(state.copyWith(
          loading: false,
          assignments: data,
        ));
      } catch (e) {
        emit(state.copyWith(
          loading: false,
          error: e.toString(),
        ));
      }
    });

    // ============================
    // CREAR RUTA NUEVA
    // ============================
    on<CreateAssignmentRequested>((event, emit) async {
      emit(state.copyWith(loading: true, error: null, success: false));

      try {
        await repo.createAssignment(
          vehicleId: event.vehicleId,
          driverId: event.driverId,
          route: event.route,
        );

        final refreshed = await repo.getAssignments();

        emit(state.copyWith(
          loading: false,
          assignments: refreshed,
          success: true,
        ));
      } catch (e) {
        emit(state.copyWith(
          loading: false,
          error: e.toString(),
        ));
      }
    });

    // ============================
    // REFRESCAR LISTA (cuando driver cambia estado)
    // ============================
    on<RefreshAssignments>((event, emit) async {
      try {
        final refreshed = await repo.getAssignments();
        emit(state.copyWith(assignments: refreshed));
      } catch (_) {}
    });
  }
}
