import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/driver_repository.dart';
import '../../../domain/entities/assignmentEntity.dart';
import 'routes_event.dart';
import 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final DriverRepository repo;

  RoutesBloc(this.repo) : super(const RoutesState()) {
    on<RoutesLoadRequested>(_onLoad);
    on<RoutesCreateRequested>(_onCreateRoute);
  }

  Future<void> _onLoad(
      RoutesLoadRequested event, Emitter<RoutesState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final list = await repo.getAssignmentsForDriver(event.driverId);
      final routes =
          list.map<AssignmentEntity>((e) => AssignmentEntity.fromJson(e)).toList();

      emit(state.copyWith(loading: false, routes: routes));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCreateRoute(
      RoutesCreateRequested event, Emitter<RoutesState> emit) async {
    emit(state.copyWith(creating: true, error: null));

    try {
      // Buscar vehículo disponible
      final vehicle = await repo.getFirstVehicle();
      if (vehicle == null) {
        throw Exception('No hay vehículos disponibles');
      }
      final int vehicleId = vehicle['id'] as int;

      // Crear assignment en backend
      final created = await repo.createAssignment(
        driverId: event.driverId,
        vehicleId: vehicleId,
        route: 'Ruta automática',
      );

      if (created == null) {
        throw Exception('El backend no devolvió el assignment creado');
      }

      final newAssignment = AssignmentEntity.fromJson(created);

      final updated = List<AssignmentEntity>.from(state.routes)..add(newAssignment);

      emit(state.copyWith(
        creating: false,
        routes: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        creating: false,
        error: e.toString(),
      ));
    }
  }
}
