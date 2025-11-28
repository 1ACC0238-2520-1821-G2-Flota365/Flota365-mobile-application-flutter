import 'package:equatable/equatable.dart';
import '../../../domain/entities/assignmentEntity.dart';

class RoutesState extends Equatable {
  final bool loading;
  final bool creating;
  final List<AssignmentEntity> routes;
  final String? error;

  const RoutesState({
    this.loading = false,
    this.creating = false,
    this.routes = const [],
    this.error,
  });

  RoutesState copyWith({
    bool? loading,
    bool? creating,
    List<AssignmentEntity>? routes,
    String? error,
  }) {
    return RoutesState(
      loading: loading ?? this.loading,
      creating: creating ?? this.creating,
      routes: routes ?? this.routes,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, creating, routes, error];
}
