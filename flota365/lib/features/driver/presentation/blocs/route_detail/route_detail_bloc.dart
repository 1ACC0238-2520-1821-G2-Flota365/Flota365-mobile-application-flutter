import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/driver_repository.dart';
import '../../../domain/entities/assignmentEntity.dart';
import 'route_detail_event.dart';
import 'route_detail_state.dart';

class RouteDetailBloc extends Bloc<RouteDetailEvent, RouteDetailState> {
  final DriverRepository repo;

  RouteDetailBloc(this.repo) : super(const RouteDetailState()) {
    on<RouteDetailRequested>(_load);
  }

  Future<void> _load(
      RouteDetailRequested event, Emitter<RouteDetailState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final data = await repo.getAssignmentDetail(event.routeId);
      final assignment = AssignmentEntity.fromJson(data!);

      emit(state.copyWith(
        loading: false,
        assignment: assignment,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }
}
