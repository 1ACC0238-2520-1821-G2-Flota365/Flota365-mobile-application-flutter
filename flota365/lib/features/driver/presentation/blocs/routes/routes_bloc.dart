import 'package:flota365/features/driver/data/dtos/local/local_route_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes_event.dart';
import 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final LocalRouteService _service = LocalRouteService();

  RoutesBloc() : super(const RoutesState.initial()) {
    on<RoutesLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    RoutesLoadRequested event,
    Emitter<RoutesState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    try {
      final data = await _service.getRoutes();
      emit(state.copyWith(
        loading: false,
        routes: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Error cargando rutas: $e',
      ));
    }
  }
}
