import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../data/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _repo;

  LoginBloc(this._repo) : super(const LoginState()) {
    on<LoginEmailChanged>((e, emit) {
      emit(state.copyWith(email: e.email));
    });

    on<LoginPasswordChanged>((e, emit) {
      emit(state.copyWith(password: e.password));
    });

    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    if (state.email.isEmpty || state.password.length < 6) {
      emit(state.copyWith(
        status: Status.failure,
        error: 'Datos inválidos.',
      ));
      return;
    }

    emit(state.copyWith(status: Status.loading, error: null));

    try {
      // ⬇️ AuthRepository.login ahora devuelve SOLO User
      final user = await _repo.login(state.email, state.password);

      emit(state.copyWith(
        status: Status.success,
        user: user,
      ));
    } on DioException catch (e) {
      final msg = e.response?.data is String
          ? e.response!.data
          : (e.response?.data?['message'] ?? 'Credenciales inválidas');

      emit(state.copyWith(
        status: Status.failure,
        error: msg.toString(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        error: e.toString(),
      ));
    }
  }
}
