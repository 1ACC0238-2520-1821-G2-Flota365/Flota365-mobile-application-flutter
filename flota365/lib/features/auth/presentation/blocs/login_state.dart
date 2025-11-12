import '../../../../core/enums/status.dart';
import '../../../../features/auth/domain/user.dart';

class LoginState {
  final String email;
  final String password;
  final Status status;
  final String? error;
  final User? user;

  const LoginState({
    this.email = '',
    this.password = '',
    this.status = Status.idle,
    this.error,
    this.user,
  });

  LoginState copyWith({
    String? email,
    String? password,
    Status? status,
    String? error,
    User? user,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      error: error,
      user: user ?? this.user,
    );
  }
}
