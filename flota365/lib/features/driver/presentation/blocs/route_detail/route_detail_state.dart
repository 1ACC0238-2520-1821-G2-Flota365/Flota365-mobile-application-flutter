import 'package:equatable/equatable.dart';
import '../../../domain/entities/assignmentEntity.dart';

class RouteDetailState extends Equatable {
  final bool loading;
  final AssignmentEntity? assignment;
  final String? error;

  const RouteDetailState({
    this.loading = false,
    this.assignment,
    this.error,
  });

  RouteDetailState copyWith({
    bool? loading,
    AssignmentEntity? assignment,
    String? error,
  }) {
    return RouteDetailState(
      loading: loading ?? this.loading,
      assignment: assignment ?? this.assignment,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, assignment, error];
}
