import 'package:dio/dio.dart';
import 'package:flota365/core/enums/status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/driver_repository.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckOutBloc extends Bloc<CheckOutEvent, CheckOutState> {
  final DriverRepository repo;
  CheckOutBloc(this.repo) : super(CheckOutState()) {
    on<CheckOutInit>((e, emit) {
      emit(state.copyWith(assignmentId: e.assignmentId, time: DateTime.now()));
    });
    on<CheckOutTimeChanged>((e, emit) => emit(state.copyWith(time: e.time)));
    on<CheckOutLocationChanged>((e, emit) => emit(state.copyWith(location: e.location)));
    on<CheckOutFuelChanged>((e, emit) => emit(state.copyWith(fuel: e.fuel)));
    on<CheckOutNotesChanged>((e, emit) => emit(state.copyWith(notes: e.notes)));
    on<CheckOutIssuesToggled>((e, emit) {
      final m = Map<String, bool>.from(state.issues)..[e.key] = e.value;
      emit(state.copyWith(issues: m));
    });

    on<CheckOutSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(CheckOutSubmitted e, Emitter<CheckOutState> emit) async {
    if (state.assignmentId.isEmpty) {
      emit(state.copyWith(error: 'Falta Assignment ID'));
      return;
    }

    emit(state.copyWith(status: Status.loading, enabled: false, error: null));

    final payload = {
      'time': state.time.toIso8601String(),
      'location': state.location,
      'fuel': state.fuel,
      'issues': state.issues,
      'notes': state.notes,
    };

    try {
      await repo.doCheckOut(assignmentId: state.assignmentId, payload: payload);
      emit(state.copyWith(status: Status.success, enabled: true));
    } on DioException catch (err) {
      emit(state.copyWith(status: Status.failure, enabled: true, error: err.message));
    } catch (err) {
      emit(state.copyWith(status: Status.failure, enabled: true, error: err.toString()));
    }
  }
}
