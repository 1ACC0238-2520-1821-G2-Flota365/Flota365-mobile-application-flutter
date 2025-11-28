import 'package:equatable/equatable.dart';
import '../../../domain/entities/assignmentEntity.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<AssignmentEntity> items;
  final String? error;

  const HistoryState({
    required this.status,
    required this.items,
    this.error,
  });

  factory HistoryState.initial() =>
      const HistoryState(status: HistoryStatus.initial, items: []);

  HistoryState copyWith({
    HistoryStatus? status,
    List<AssignmentEntity>? items,
    String? error,
  }) {
    return HistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, error];
}
