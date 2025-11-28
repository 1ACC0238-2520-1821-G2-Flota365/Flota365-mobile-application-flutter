import 'package:flota365/core/enums/status.dart';

class CheckInState {
  final Status status;
  final int assignmentId;

  final DateTime time;
  final String location;
  final double fuel;
  final double cargoKg;
  final Map<String, bool> checklist;
  final String notes;

  final String? error;
  final bool enabled;

  CheckInState({
    this.status = Status.idle,
    this.assignmentId = 0,     // ahora es INT
    DateTime? time,
    this.location = '',
    this.fuel = 0,
    this.cargoKg = 0,
    Map<String, bool>? checklist,
    this.notes = '',
    this.error,
    this.enabled = true,
  })  : time = time ?? DateTime.now(),
        checklist = checklist ??
            const {
              'luces': false,
              'frenos': false,
              'neumaticos': false,
              'otros': false,
            };

  CheckInState copyWith({
    Status? status,
    int? assignmentId,
    DateTime? time,
    String? location,
    double? fuel,
    double? cargoKg,
    Map<String, bool>? checklist,
    String? notes,
    String? error,
    bool? enabled,
  }) {
    return CheckInState(
      status: status ?? this.status,
      assignmentId: assignmentId ?? this.assignmentId,
      time: time ?? this.time,
      location: location ?? this.location,
      fuel: fuel ?? this.fuel,
      cargoKg: cargoKg ?? this.cargoKg,
      checklist: checklist ?? this.checklist,
      notes: notes ?? this.notes,
      error: error,
      enabled: enabled ?? this.enabled,
    );
  }
}
