// features/driver/presentation/blocs/dashboard/dashboard_bloc.dart
import 'package:flota365/core/enums/status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/driver_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DriverRepository repo;
  DashboardBloc(this.repo) : super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardCreateAssignment>(_onCreate);
  }

  Future<void> _onStarted(
    DashboardStarted e,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final driverId = e.driverId.toString(); // 🔒 forzamos String
      emit(state.copyWith(status: Status.loading, driverId: driverId));

      // 1) Perfil (por id). Si no hay endpoint directo, hacemos fallback por catálogo.
      Map<String, dynamic>? profile = await repo.getDriverProfile(driverId);
      profile ??= await repo.findDriverById(driverId); // <= asegúrate de tenerlo en el repo

      // 2) Buscar assignment activo del driver
      final list = await repo.getAssignmentsForDriver(driverId);
      Map<String, dynamic>? current;
      for (final a in list) {
        final status = (a['status']?.toString() ?? '').toLowerCase();
        if (status == 'pending' || status == 'inprogress' || status == 'in_progress') {
          current = a;
          break;
        }
      }

      emit(state.copyWith(
        status: Status.success,
        profile: profile,
        current: current,
      ));
    } catch (err) {
      emit(state.copyWith(status: Status.failure, error: err.toString()));
    }
  }

  Future<void> _onCreate(
    DashboardCreateAssignment e,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(state.copyWith(status: Status.loading));

      // 1) Tomar el perfil ya cargado en _onStarted
      final profile = state.profile;
      final email = (profile?['email'] ?? '').toString().trim();
      if (email.isEmpty) {
        throw Exception('Email de perfil no disponible');
      }

      // 2) Buscar driver por email
      final driver = await repo.findDriverByEmail(email);
      if (driver == null) {
        throw Exception('No se encontró un driver para el email $email');
      }

      final driverId = driver['id']?.toString() ?? driver['code']?.toString() ?? '';
      if (driverId.isEmpty) throw Exception('El driver no tiene un id válido');

      // 3) Seleccionar vehículo (ajusta si quieres lógica de “disponible”)
      final vehicle = await repo.getFirstVehicle();
      if (vehicle == null) throw Exception('No hay vehículos disponibles');

      final vehicleId = vehicle['id']?.toString() ?? vehicle['code']?.toString() ?? '';
      if (vehicleId.isEmpty) throw Exception('El vehículo no tiene un id válido');

      // 4) Crear assignment real (recuerda que en el service ya mandamos {"request": {...}})
      final created = await repo.createAssignment(
        driverId: driverId,
        vehicleId: vehicleId,
        route: 'Ruta-Automática',
      );

      if (created == null) {
        throw Exception('El backend no devolvió el assignment creado');
      }

      // 5) Actualizamos de inmediato la UI con lo creado,
      //    y de yapa disparamos un refresh para traer el estado real del backend.
      emit(state.copyWith(
        status: Status.success,
        current: created,
      ));

      add(DashboardStarted(state.driverId)); // refresh

    } catch (err) {
      emit(state.copyWith(status: Status.failure, error: err.toString()));
    }
  }
}
