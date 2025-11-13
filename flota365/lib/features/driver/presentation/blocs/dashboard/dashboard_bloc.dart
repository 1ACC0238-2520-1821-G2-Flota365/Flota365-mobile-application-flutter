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

      
      Map<String, dynamic>? profile = await repo.getDriverProfile(driverId);
      profile ??= await repo.findDriverById(driverId); 

     
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

      
      final vehicle = await repo.getFirstVehicle();
      if (vehicle == null) throw Exception('No hay vehículos disponibles');

      final vehicleId = vehicle['id']?.toString() ?? vehicle['code']?.toString() ?? '';
      if (vehicleId.isEmpty) throw Exception('El vehículo no tiene un id válido');

    
      final created = await repo.createAssignment(
        driverId: driverId,
        vehicleId: vehicleId,
        route: 'Ruta-Automática',
      );

      if (created == null) {
        throw Exception('El backend no devolvió el assignment creado');
      }

    
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
