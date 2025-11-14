import 'package:equatable/equatable.dart';

class RouteDetailState extends Equatable {
  final bool loading;
  final Map<String, dynamic>? route;
  final String? error;

  const RouteDetailState({
    required this.loading,
    required this.route,
    this.error,
  });

  const RouteDetailState.initial()
      : loading = false,
        route = null,
        error = null;

  RouteDetailState copyWith({
    bool? loading,
    Map<String, dynamic>? route,
    String? error,
  }) {
    return RouteDetailState(
      loading: loading ?? this.loading,
      route: route ?? this.route,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, route, error];
}
