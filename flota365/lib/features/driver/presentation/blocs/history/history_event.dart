import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  final int driverId;   // AHORA ES INT

  LoadHistory(this.driverId);

  @override
  List<Object?> get props => [driverId];
}
