import 'package:flota365/core/enums/status.dart';

class CheckOutState {
  final Status status;
  final int assignmentId;

  final DateTime time;
  final String location;
  final double fuel;
  final Map<String, bool> issues;
  final String notes;

  final String? error;
  final bool enabled;

  CheckOutState({
    this.status = Status.idle,
    this.assignmentId = 0,
    DateTime? time,
    this.location = '',
    this.fuel = 0,
    Map<String, bool>? issues,
    this.notes = '',
    this.error,
    this.enabled = true,
  })  : time = time ?? DateTime.now(),
        issues = issues ??
            const {
              'golpes': false,
              'fugas': false,
              'ruidos': false,
              'otros': false,
            };

  CheckOutState copyWith({
    Status? status,
    int? assignmentId,
    DateTime? time,
    String? location,
    double? fuel,
    Map<String, bool>? issues,
    String? notes,
    String? error,
    bool? enabled,
  }) {
    return CheckOutState(
      status: status ?? this.status,
      assignmentId: assignmentId ?? this.assignmentId,
      time: time ?? this.time,
      location: location ?? this.location,
      fuel: fuel ?? this.fuel,
      issues: issues ?? this.issues,
      notes: notes ?? this.notes,
      error: error,
      enabled: enabled ?? this.enabled,
    );
  }
}
