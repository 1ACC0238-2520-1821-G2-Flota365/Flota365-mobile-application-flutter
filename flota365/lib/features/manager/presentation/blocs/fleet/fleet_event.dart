import 'package:flota365/features/manager/domain/entities/fleet_entity.dart';

abstract class FleetEvent {}

class LoadFleets extends FleetEvent {}

class CreateFleetRequested extends FleetEvent {
  final FleetEntity fleet;
  CreateFleetRequested(this.fleet);
}

class UpdateFleetRequested extends FleetEvent {
  final FleetEntity fleet;
  UpdateFleetRequested(this.fleet);
}

class DeleteFleetRequested extends FleetEvent {
  final int id;
  DeleteFleetRequested(this.id);
}
