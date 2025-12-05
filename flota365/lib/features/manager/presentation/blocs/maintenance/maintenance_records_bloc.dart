import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/manager_repository.dart';
import 'maintenance_records_event.dart';
import 'maintenance_records_state.dart';

class MaintenanceRecordsBloc extends Bloc<MaintenanceRecordsEvent, MaintenanceRecordsState> {
  final ManagerRepository repo;

  MaintenanceRecordsBloc(this.repo) : super(const MaintenanceRecordsState()) {
    on<LoadMaintenanceRecords>(_onLoad);
    on<CreateMaintenanceRecordRequested>(_onCreate);
    on<UpdateMaintenanceRecordRequested>(_onUpdate);
    on<DeleteMaintenanceRecordRequested>(_onDelete);
  }

  Future<void> _onLoad(LoadMaintenanceRecords event, Emitter<MaintenanceRecordsState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      final list = await repo.getMaintenanceRecords();
      emit(state.copyWith(loading: false, records: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onCreate(CreateMaintenanceRecordRequested event, Emitter<MaintenanceRecordsState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      await repo.createMaintenanceRecord(event.body);
      final list = await repo.getMaintenanceRecords();
      emit(state.copyWith(loading: false, records: list, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateMaintenanceRecordRequested event, Emitter<MaintenanceRecordsState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      await repo.updateMaintenanceRecord(event.id, event.body);
      final list = await repo.getMaintenanceRecords();
      emit(state.copyWith(loading: false, records: list, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteMaintenanceRecordRequested event, Emitter<MaintenanceRecordsState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      await repo.deleteMaintenanceRecord(event.id);
      final list = await repo.getMaintenanceRecords();
      emit(state.copyWith(loading: false, records: list, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
