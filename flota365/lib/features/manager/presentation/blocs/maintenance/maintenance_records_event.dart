abstract class MaintenanceRecordsEvent {}

class LoadMaintenanceRecords extends MaintenanceRecordsEvent {}

class CreateMaintenanceRecordRequested extends MaintenanceRecordsEvent {
  final Map<String, dynamic> body;
  CreateMaintenanceRecordRequested(this.body);
}

class UpdateMaintenanceRecordRequested extends MaintenanceRecordsEvent {
  final int id;
  final Map<String, dynamic> body;
  UpdateMaintenanceRecordRequested(this.id, this.body);
}

class DeleteMaintenanceRecordRequested extends MaintenanceRecordsEvent {
  final int id;
  DeleteMaintenanceRecordRequested(this.id);
}
