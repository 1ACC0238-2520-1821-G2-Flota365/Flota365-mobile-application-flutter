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

  Future<void> _onStarted(
    DashboardStarted e,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final driverId = e.driverId.toString();
      emit(state.copyWith(status: Status.loading, driverId: driverId));

    
      Map<String, dynamic>? profile = await repo.getDriverProfile(driverId);
      profile ??= await repo.findDriverById(driverId);

      emit(state.copyWith(status: Status.success, profile: profile, current: null));
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

      // 1) Tomar email del perfil (Auth/profile)
      final email = (state.profile?['email'] ?? '').toString().trim();
      if (email.isEmpty) {
        throw Exception('Email de perfil no disponible');
      }

    
      final ensuredDriver = await repo.ensureDriverForEmail(
        email: email,
        fullName: state.profile?['fullName'],
      );
      final driverGuid = (ensuredDriver['id'] ?? '').toString();
      if (driverGuid.isEmpty) {
        throw Exception('El driver resuelto no tiene un id válido (GUID)');
      }

      // 3) Obtener un vehículo
      final vehicle = await repo.getFirstVehicle();
      if (vehicle == null) throw Exception('No hay vehículos disponibles');
      final vehicleGuid = (vehicle['id'] ?? vehicle['code'] ?? '').toString();
      if (vehicleGuid.isEmpty) {
        throw Exception('El vehículo no tiene un id válido (GUID/code)');
      }

      // 4) Crear assignment (cuerpo plano según Swagger)
      final created = await repo.createAssignment(
        driverId: driverGuid,
        vehicleId: vehicleGuid,
        route: 'Ruta-Automática',
      );
      if (created == null) {
        throw Exception('El backend no devolvió el assignment creado');
      }

      emit(state.copyWith(status: Status.success, current: created));
    } catch (err) {
      emit(state.copyWith(status: Status.failure, error: err.toString()));
    }
  }
}
