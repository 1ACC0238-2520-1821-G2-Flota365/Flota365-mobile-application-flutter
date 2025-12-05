import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/manager_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ManagerRepository repo;

  ReportsBloc(this.repo) : super(const ReportsState()) {
    on<LoadReports>(_onLoad);
    on<CreateReportRequested>(_onCreate);
  }

  Future<void> _onLoad(LoadReports event, Emitter<ReportsState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      final list = await repo.getReports();
      emit(state.copyWith(loading: false, reports: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onCreate(CreateReportRequested event, Emitter<ReportsState> emit) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      await repo.createReport(event.body);
      final list = await repo.getReports();
      emit(state.copyWith(loading: false, reports: list, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
