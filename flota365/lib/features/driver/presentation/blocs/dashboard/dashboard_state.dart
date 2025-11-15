import 'package:flota365/core/enums/status.dart';


class DashboardState {
  final Status status;
  final String driverId;
  final Map<String, dynamic>? profile;   // para nombre/correo
  final Map<String, dynamic>? current;   // assignment activo (pending/in progress)
  final String? error;

  const DashboardState({
    this.status = Status.idle,
    this.driverId = '',
    this.profile,
    this.current,
    this.error,
  });

  DashboardState copyWith({
    Status? status,
    String? driverId,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? current,
    String? error,
  }) {
    return DashboardState(
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      profile: profile ?? this.profile,
      current: current ?? this.current,
      error: error,
    );
  }
}
