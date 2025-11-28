import 'package:equatable/equatable.dart';

abstract class RoutesEvent extends Equatable {
  const RoutesEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las rutas asignadas a un conductor.
class RoutesLoadRequested extends RoutesEvent {
  final int driverId;
  const RoutesLoadRequested(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

/// Crear una nueva ruta/jornada automática para el conductor.
class RoutesCreateRequested extends RoutesEvent {
  final int driverId;
  const RoutesCreateRequested(this.driverId);

  @override
  List<Object?> get props => [driverId];
}
