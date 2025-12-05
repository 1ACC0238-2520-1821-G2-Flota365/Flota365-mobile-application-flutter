abstract class ReportsEvent {}

class LoadReports extends ReportsEvent {}

class CreateReportRequested extends ReportsEvent {
  final Map<String, dynamic> body;
  CreateReportRequested(this.body);
}
