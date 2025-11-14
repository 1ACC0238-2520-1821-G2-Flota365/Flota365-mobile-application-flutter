import 'package:equatable/equatable.dart';

class RoutesState extends Equatable {
  final bool loading;
  final List<Map<String, dynamic>> routes;
  final String? error;

  const RoutesState({
    required this.loading,
    required this.routes,
    this.error,
  });

  // Estado inicial
  const RoutesState.initial()
      : loading = false,
        routes = const [],
        error = null;

  // CopyWith
  RoutesState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? routes,
    String? error,
  }) {
    return RoutesState(
      loading: loading ?? this.loading,
      routes: routes ?? this.routes,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, routes, error];
}
