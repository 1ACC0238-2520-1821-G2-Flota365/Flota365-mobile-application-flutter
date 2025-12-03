import 'package:equatable/equatable.dart';

abstract class VehiclesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Cargar lista de vehículos
class LoadVehicles extends VehiclesEvent {}

// Crear vehículo nuevo
class CreateVehicleRequested extends VehiclesEvent {
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final int fleetId;
  final String fleetName;

  CreateVehicleRequested({
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.fleetId,
    required this.fleetName,
  });

  @override
  List<Object?> get props =>
      [licensePlate, brand, model, year, mileage, fleetId, fleetName];
}

// Actualizar (ej: mileage, status, driverName)
class UpdateVehicleRequested extends VehiclesEvent {
  final int id;
  final int? mileage;
  final String? status;
  final String? driverName;

  UpdateVehicleRequested({
    required this.id,
    this.mileage,
    this.status,
    this.driverName,
  });

  @override
  List<Object?> get props => [id, mileage, status, driverName];
}

// Eliminar
class DeleteVehicleRequested extends VehiclesEvent {
  final int id;

  DeleteVehicleRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadVehiclesForFleet extends VehiclesEvent {
  final int fleetId;
  LoadVehiclesForFleet(this.fleetId);
}
