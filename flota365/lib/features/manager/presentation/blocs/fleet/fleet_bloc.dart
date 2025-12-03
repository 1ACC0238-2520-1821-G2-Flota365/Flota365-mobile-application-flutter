import 'package:flota365/features/manager/data/manager_repository.dart';
import 'package:flota365/features/manager/presentation/blocs/fleet/fleet_event.dart';
import 'package:flota365/features/manager/presentation/blocs/fleet/fleet_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FleetBloc extends Bloc<FleetEvent, FleetState> {
  final ManagerRepository repo;

  FleetBloc(this.repo) : super(FleetState()) {
    
    // =============================
    //   CARGAR TODAS LAS FLOTAS
    // =============================
    on<LoadFleets>((event, emit) async {
      emit(state.copyWith(loading: true, error: null, actionSuccess: false));

      try {
        // 1️⃣ obtener flotas
        final fleets = await repo.getFleets();

        // 2️⃣ obtener vehículos (para contar los que pertenecen a cada flota)
        final vehicles = await repo.getVehicles();

        // 3️⃣ actualizar contador vehicleCount de cada flota
        for (final f in fleets) {
          f.vehicleCount = vehicles.where((v) => v.fleetId == f.id).length;
        }

        emit(state.copyWith(
          loading: false,
          fleets: fleets,
        ));
      } catch (e) {
        emit(state.copyWith(
          loading: false,
          error: e.toString(),
        ));
      }
    });

    // ==========================
    //   CREAR FLETA
    // ==========================
    on<CreateFleetRequested>((event, emit) async {
      try {
        await repo.createFleet(event.fleet);
        emit(state.copyWith(actionSuccess: true));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    // ==========================
    //   EDITAR FLETA
    // ==========================
    on<UpdateFleetRequested>((event, emit) async {
      try {
        await repo.updateFleet(event.fleet);
        emit(state.copyWith(actionSuccess: true));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });

    // ==========================
    //   ELIMINAR FLETA
    // ==========================
    on<DeleteFleetRequested>((event, emit) async {
      try {
        await repo.deleteFleet(event.id);
        emit(state.copyWith(actionSuccess: true));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
