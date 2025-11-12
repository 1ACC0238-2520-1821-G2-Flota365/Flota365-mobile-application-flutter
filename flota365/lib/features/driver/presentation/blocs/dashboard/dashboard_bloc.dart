// lib/features/driver/presentation/blocs/dashboard/dashboard_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flota365/core/enums/status.dart';

import '../../../data/driver_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DriverRepository repo;

  DashboardBloc(this.repo) : super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardCreateAssignment>(_onCreate);
  }

  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
    DashboardStarted e,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final driverId = e.driverId.toString();
      emit(state.copyWith(status: Status.loading, driverId: driverId));

      // 1) Perfil por id (Auth/profile/{id}), con fallback al catálogo
      Map<String, dynamic>? profile = await repo.getDriverProfile(driverId);
      profile ??= await repo.findDriverById(driverId);

      // 2) Assignment activo (si aún no hay endpoint real, quedará null)
      final assignments = await repo.getAssignmentsForDriver(driverId);
      Map<String, dynamic>? current;
      for (final a in assignments) {
        final s = (a['status']?.toString() ?? '').toLowerCase();
        if (s == 'pending' || s == 'inprogress' || s == 'in_progress') {
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

  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _onCreate(
    DashboardCreateAssignment e,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(state.copyWith(status: Status.loading));

      // 1) Usar el driverId ya guardado en el estado
      final driverId = state.driverId;
      if (driverId.isEmpty) {
        throw Exception('DriverId no disponible');
      }

      // Evita duplicados si ya hay jornada activa
      if (state.current != null) {
        emit(state.copyWith(status: Status.success));
        return;
      }

      // 2) Tomar un vehículo (por ahora el primero del catálogo)
      final vehicle = await repo.getFirstVehicle();
      if (vehicle == null) throw Exception('No hay vehículos disponibles');

      final vehicleId =
          vehicle['id']?.toString() ?? vehicle['code']?.toString() ?? '';
      if (vehicleId.isEmpty) throw Exception('El vehículo no tiene un id válido');

      // 3) Crear assignment (según Swagger: driverId, vehicleId, route)
      final created = await repo.createAssignment(
        driverId: driverId,
        vehicleId: vehicleId,
        route: 'Ruta-Automática',
      );
      if (created == null) {
        throw Exception('El backend no devolvió el assignment creado');
      }

      // 4) Actualizar UI y refrescar
      emit(state.copyWith(status: Status.success, current: created));
      add(DashboardStarted(state.driverId));
    } catch (err) {
      emit(state.copyWith(status: Status.failure, error: err.toString()));
    }
  }
}
