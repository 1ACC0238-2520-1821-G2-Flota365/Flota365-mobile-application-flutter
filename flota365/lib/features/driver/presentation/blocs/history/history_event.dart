import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  final String driverId;

  LoadHistory(this.driverId);

  @override
  List<Object?> get props => [driverId];
}
