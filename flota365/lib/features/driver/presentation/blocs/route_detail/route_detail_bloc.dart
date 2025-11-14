import 'package:flota365/features/driver/data/dtos/local_route_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'route_detail_event.dart';
import 'route_detail_state.dart';

class RouteDetailBloc extends Bloc<RouteDetailEvent, RouteDetailState> {
  final LocalRouteService _service = LocalRouteService();

  RouteDetailBloc() : super(const RouteDetailState.initial()) {
    on<RouteDetailRequested>(_onLoad);
    on<RouteProgressUpdated>(_onProgress);
    on<RouteStopToggled>(_onToggleStop);
  }

  Future<void> _onLoad(
    RouteDetailRequested event,
    Emitter<RouteDetailState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    final route = await _service.getRouteById(event.routeId);

    emit(state.copyWith(
      loading: false,
      route: route,
    ));
  }

  Future<void> _onProgress(
    RouteProgressUpdated event,
    Emitter<RouteDetailState> emit,
  ) async {
    final updated = Map<String, dynamic>.from(state.route!);
    updated["progress"] = event.progress;

    emit(state.copyWith(route: updated));
  }

  Future<void> _onToggleStop(
    RouteStopToggled event,
    Emitter<RouteDetailState> emit,
  ) async {
    final updated = Map<String, dynamic>.from(state.route!);
    final stops = List<Map<String, dynamic>>.from(updated["stops"]);

    stops[event.index]["done"] = !stops[event.index]["done"];

    updated["stops"] = stops;

    emit(state.copyWith(route: updated));
  }
}
