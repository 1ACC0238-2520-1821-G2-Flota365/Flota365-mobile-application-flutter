import 'package:flutter_bloc/flutter_bloc.dart';
import 'history_event.dart';
import 'history_state.dart';
import '../../../data/driver_repository.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final DriverRepository repo;

  HistoryBloc(this.repo) : super(HistoryState.initial()) {
    on<LoadHistory>(_onLoad);
  }

  Future<void> _onLoad(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final list = await repo.getAssignmentsForDriver(event.driverId);

      emit(
        state.copyWith(
          status: HistoryStatus.success,
          items: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}
