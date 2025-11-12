abstract class CheckOutEvent {}

class CheckOutInit extends CheckOutEvent {
  final String assignmentId;
  CheckOutInit(this.assignmentId);
}

class CheckOutTimeChanged extends CheckOutEvent {
  final DateTime time;
  CheckOutTimeChanged(this.time);
}

class CheckOutLocationChanged extends CheckOutEvent {
  final String location;
  CheckOutLocationChanged(this.location);
}

class CheckOutFuelChanged extends CheckOutEvent {
  final double fuel;
  CheckOutFuelChanged(this.fuel);
}

class CheckOutNotesChanged extends CheckOutEvent {
  final String notes;
  CheckOutNotesChanged(this.notes);
}

class CheckOutIssuesToggled extends CheckOutEvent {
  /// “golpes”, “fugas”, “ruidos”, etc. (ajústalo a tu UI)
  final String key;
  final bool value;
  CheckOutIssuesToggled(this.key, this.value);
}

class CheckOutSubmitted extends CheckOutEvent {}
