abstract class DashboardEvent {}

class DashboardStarted extends DashboardEvent {
  final String driverId;
  DashboardStarted(this.driverId);
}

class DashboardCreateAssignment extends DashboardEvent {} // 👈 Agrega esta clase


// Si luego quieres “Crear jornada” desde la app, puedes añadir:
// class DashboardCreateAssignment extends DashboardEvent {}



class DashboardCheckInPressed extends DashboardEvent {
  final String assignmentId;
  final Map<String, dynamic> payload;
  DashboardCheckInPressed({required this.assignmentId, required this.payload});
}

class DashboardCheckOutPressed extends DashboardEvent {
  final String assignmentId;
  final Map<String, dynamic> payload;
  DashboardCheckOutPressed({required this.assignmentId, required this.payload});
}
