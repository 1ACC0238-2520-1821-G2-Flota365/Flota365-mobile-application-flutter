import 'package:flutter_bloc/flutter_bloc.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc() : super(const SupportState()) {

    on<SupportSubjectChanged>((e, emit) {
      emit(state.copyWith(subject: e.subject));
    });

    on<SupportMessageChanged>((e, emit) {
      emit(state.copyWith(message: e.message));
    });

    on<SupportSubmitted>((e, emit) async {
      if (state.subject.isEmpty || state.message.isEmpty) {
        emit(state.copyWith(
          status: SupportStatus.failure,
          error: "Completa todos los campos",
        ));
        return;
      }

      emit(state.copyWith(status: SupportStatus.loading));

      // ⭐ Número REAL del administrador (CUALQUIER PAÍS)
      const adminPhone = "56963185099"; // <-- CAMBIAR POR EL REAL

      final message = Uri.encodeComponent(
        "📌*Asunto:* ${state.subject}\n"
        "📄*Mensaje:*\n${state.message}"
      );

      final url = "https://wa.me/$adminPhone?text=$message";

      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(
        status: SupportStatus.success,
        whatsappUrl: url,
      ));
    });
  }
}
