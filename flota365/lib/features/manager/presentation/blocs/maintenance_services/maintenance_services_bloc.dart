import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/manager_repository.dart';
import 'maintenance_services_event.dart';
import 'maintenance_services_state.dart';

class MaintenanceServicesBloc extends Bloc<MaintenanceServicesEvent, MaintenanceServicesState> {
  final ManagerRepository repo;

  MaintenanceServicesBloc(this.repo) : super(const MaintenanceServicesState()) {
    on<LoadMaintenanceServices>(_onLoad);
    on<CreateMaintenanceServiceRequested>(_onCreate);
    on<DeleteMaintenanceServiceRequested>(_onDelete);
  }

  Future<void> _onLoad(LoadMaintenanceServices event, Emitter<MaintenanceServicesState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      final list = await repo.getMaintenanceServices();
      emit(state.copyWith(loading: false, services: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onCreate(CreateMaintenanceServiceRequested event, Emitter<MaintenanceServicesState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      await repo.createMaintenanceService(event.body);
      final list = await repo.getMaintenanceServices();
      emit(state.copyWith(loading: false, services: list, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteMaintenanceServiceRequested event, Emitter<MaintenanceServicesState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      await repo.deleteMaintenanceService(event.id);
      final list = await repo.getMaintenanceServices();
      emit(state.copyWith(loading: false, services: list, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
