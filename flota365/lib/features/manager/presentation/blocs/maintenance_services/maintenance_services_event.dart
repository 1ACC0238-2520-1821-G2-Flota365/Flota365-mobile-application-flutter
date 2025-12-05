abstract class MaintenanceServicesEvent {}

class LoadMaintenanceServices extends MaintenanceServicesEvent {}

class CreateMaintenanceServiceRequested extends MaintenanceServicesEvent {
  final Map<String, dynamic> body;
  CreateMaintenanceServiceRequested(this.body);
}

class DeleteMaintenanceServiceRequested extends MaintenanceServicesEvent {
  final int id;
  DeleteMaintenanceServiceRequested(this.id);
}
