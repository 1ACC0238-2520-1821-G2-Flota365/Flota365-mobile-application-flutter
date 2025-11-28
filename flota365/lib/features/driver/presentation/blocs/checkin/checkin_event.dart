abstract class CheckInEvent {}

class CheckInInit extends CheckInEvent {
  final int assignmentId;   // AHORA ES INT
  CheckInInit(this.assignmentId);
}

class CheckInTimeChanged extends CheckInEvent {
  final DateTime time;
  CheckInTimeChanged(this.time);
}

class CheckInLocationChanged extends CheckInEvent {
  final String location;
  CheckInLocationChanged(this.location);
}

class CheckInFuelChanged extends CheckInEvent {
  final double fuel;
  CheckInFuelChanged(this.fuel);
}

class CheckInCargoChanged extends CheckInEvent {
  final double cargoKg;
  CheckInCargoChanged(this.cargoKg);
}

class CheckInChecklistToggled extends CheckInEvent {
  final String key;
  final bool value;
  CheckInChecklistToggled(this.key, this.value);
}

class CheckInNotesChanged extends CheckInEvent {
  final String notes;
  CheckInNotesChanged(this.notes);
}

class CheckInSubmitted extends CheckInEvent {}
