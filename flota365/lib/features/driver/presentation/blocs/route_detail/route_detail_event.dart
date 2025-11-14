import 'package:equatable/equatable.dart';

abstract class RouteDetailEvent extends Equatable {
  const RouteDetailEvent();

  @override
  List<Object?> get props => [];
}

class RouteDetailRequested extends RouteDetailEvent {
  final String routeId;
  const RouteDetailRequested(this.routeId);

  @override
  List<Object?> get props => [routeId];
}

class RouteProgressUpdated extends RouteDetailEvent {
  final int progress;
  const RouteProgressUpdated(this.progress);

  @override
  List<Object?> get props => [progress];
}

class RouteStopToggled extends RouteDetailEvent {
  final int index;
  const RouteStopToggled(this.index);

  @override
  List<Object?> get props => [index];
}
