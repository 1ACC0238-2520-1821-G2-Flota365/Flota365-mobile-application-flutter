import 'package:flutter_bloc/flutter_bloc.dart';
import 'history_event.dart';
import 'history_state.dart';
import '../../../data/driver_repository.dart';
import '../../../domain/entities/assignmentEntity.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final DriverRepository repo;

  HistoryBloc(this.repo) : super(HistoryState.initial()) {
    on<LoadHistory>(_onLoad);
  }

  Future<void> _onLoad(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final list = await repo.getAssignmentsForDriver(event.driverId);

      final items = list.map((e) => AssignmentEntity.fromJson(e)).toList();

      emit(state.copyWith(
        status: HistoryStatus.success,
        items: items,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
