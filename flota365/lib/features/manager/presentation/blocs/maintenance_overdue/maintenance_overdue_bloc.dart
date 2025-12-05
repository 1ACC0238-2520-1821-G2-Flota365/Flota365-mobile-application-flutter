import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/manager_repository.dart';
import 'maintenance_overdue_event.dart';
import 'maintenance_overdue_state.dart';

class MaintenanceOverdueBloc extends Bloc<MaintenanceOverdueEvent, MaintenanceOverdueState> {
  final ManagerRepository repo;

  MaintenanceOverdueBloc(this.repo) : super(const MaintenanceOverdueState()) {
    on<LoadMaintenanceOverdue>(_onLoad);
  }

  Future<void> _onLoad(LoadMaintenanceOverdue event, Emitter<MaintenanceOverdueState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.getMaintenanceOverdue();
      emit(state.copyWith(loading: false, records: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
