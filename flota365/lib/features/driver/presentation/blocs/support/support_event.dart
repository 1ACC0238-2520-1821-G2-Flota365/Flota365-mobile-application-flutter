abstract class SupportEvent {}

class SupportSubjectChanged extends SupportEvent {
  final String subject;
  SupportSubjectChanged(this.subject);
}

class SupportMessageChanged extends SupportEvent {
  final String message;
  SupportMessageChanged(this.message);
}

class SupportSubmitted extends SupportEvent {}
