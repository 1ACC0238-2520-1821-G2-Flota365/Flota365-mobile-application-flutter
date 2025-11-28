abstract class RouteDetailEvent {}

class RouteDetailRequested extends RouteDetailEvent {
  final int routeId; // assignmentId real
  RouteDetailRequested(this.routeId);
}
