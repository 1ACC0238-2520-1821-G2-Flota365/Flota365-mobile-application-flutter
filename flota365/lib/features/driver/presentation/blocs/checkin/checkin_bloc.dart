import 'package:flota365/core/enums/status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../data/driver_repository.dart';
import 'checkin_event.dart';
import 'checkin_state.dart';

class CheckInBloc extends Bloc<CheckInEvent, CheckInState> {
  final DriverRepository repo;

  CheckInBloc(this.repo)
      : super(CheckInState(time: DateTime.now())) {
    on<CheckInInit>((e, emit) {
      emit(state.copyWith(
        assignmentId: e.assignmentId,
        time: DateTime.now(),
      ));
    });

    on<CheckInTimeChanged>((e, emit) => emit(state.copyWith(time: e.time)));
    on<CheckInLocationChanged>((e, emit) => emit(state.copyWith(location: e.location)));
    on<CheckInFuelChanged>((e, emit) => emit(state.copyWith(fuel: e.fuel)));
    on<CheckInCargoChanged>((e, emit) => emit(state.copyWith(cargoKg: e.cargoKg)));
    on<CheckInChecklistToggled>((e, emit) {
      final map = Map<String, bool>.from(state.checklist)..[e.key] = e.value;
      emit(state.copyWith(checklist: map));
    });
    on<CheckInNotesChanged>((e, emit) => emit(state.copyWith(notes: e.notes)));

    on<CheckInSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
      CheckInSubmitted e, Emitter<CheckInState> emit) async {
    if (state.assignmentId == 0) {
      emit(state.copyWith(error: 'Assignment ID inválido'));
      return;
    }

    emit(state.copyWith(status: Status.loading, enabled: false, error: null));

    final payload = {
      'time': state.time.toIso8601String(),
      'location': state.location,
      'fuel': state.fuel,
      'cargoKg': state.cargoKg,
      'checklist': state.checklist,
      'notes': state.notes,
    };

    try {
      await repo.doCheckIn(
        assignmentId: state.assignmentId,
        payload: payload,
      );

      emit(state.copyWith(status: Status.success, enabled: true));
    } on DioException catch (err) {
      emit(state.copyWith(
        status: Status.failure,
        enabled: true,
        error: err.message,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: Status.failure,
        enabled: true,
        error: err.toString(),
      ));
    }
  }
}
