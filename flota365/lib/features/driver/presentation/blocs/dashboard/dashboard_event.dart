abstract class DashboardEvent {}

class DashboardStarted extends DashboardEvent {
  final int driverId;
  DashboardStarted(this.driverId);
}

class DashboardCreateAssignment extends DashboardEvent {}
