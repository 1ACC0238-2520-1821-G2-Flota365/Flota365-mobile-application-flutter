import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/manager_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ManagerRepository repo;

  DashboardBloc(this.repo) : super(const DashboardState()) {
    on<LoadDashboard>(_onLoad);
  }

  Future<void> _onLoad(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final stats = await repo.getDashboardStats();
      final activeVehicles = await repo.getActiveVehiclesDashboard();
      final fleetSummary = await repo.getFleetSummary();

      emit(state.copyWith(
        loading: false,
        stats: stats,
        activeVehicles: activeVehicles,
        fleetSummary: fleetSummary,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
