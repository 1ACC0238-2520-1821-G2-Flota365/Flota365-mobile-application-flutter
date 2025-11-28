enum SupportStatus { idle, loading, success, failure }

class SupportState {
  final String subject;
  final String message;
  final SupportStatus status;
  final String? whatsappUrl;
  final String? error;

  const SupportState({
    this.subject = "",
    this.message = "",
    this.status = SupportStatus.idle,
    this.whatsappUrl,
    this.error,
  });

  SupportState copyWith({
    String? subject,
    String? message,
    SupportStatus? status,
    String? whatsappUrl,
    String? error,
  }) {
    return SupportState(
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      whatsappUrl: whatsappUrl,
      error: error,
    );
  }
}
