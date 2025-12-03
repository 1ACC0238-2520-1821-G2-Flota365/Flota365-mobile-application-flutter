import '../../../domain/entities/assignment_entity.dart';

class AssignmentState {
  final bool loading;
  final bool success;
  final List<AssignmentEntity> assignments;
  final String? error;

  const AssignmentState({
    this.loading = false,
    this.success = false,
    this.assignments = const [],
    this.error,
  });

  AssignmentState copyWith({
    bool? loading,
    bool? success,
    List<AssignmentEntity>? assignments,
    String? error,
  }) {
    return AssignmentState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      assignments: assignments ?? this.assignments,
      error: error,
    );
  }
}
