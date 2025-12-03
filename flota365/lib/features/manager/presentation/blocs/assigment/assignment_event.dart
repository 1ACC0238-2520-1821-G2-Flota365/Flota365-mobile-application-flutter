abstract class AssignmentEvent {}

class LoadAssignments extends AssignmentEvent {}

class RefreshAssignments extends AssignmentEvent {}

class CreateAssignmentRequested extends AssignmentEvent {
  final int vehicleId;
  final int driverId;
  final String route;

  CreateAssignmentRequested({
    required this.vehicleId,
    required this.driverId,
    required this.route,
  });
}

