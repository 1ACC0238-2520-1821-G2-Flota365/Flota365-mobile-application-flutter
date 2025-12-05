import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/manager_repository.dart';
import 'manager_profile_event.dart';
import 'manager_profile_state.dart';

class ManagerProfileBloc extends Bloc<ManagerProfileEvent, ManagerProfileState> {
  final ManagerRepository repo;

  ManagerProfileBloc(this.repo) : super(const ManagerProfileState()) {
    on<LoadManagerProfile>(_onLoad);
    on<UpdateManagerProfile>(_onUpdateProfile);
    on<ChangeManagerPassword>(_onChangePassword);
  }

  Future<void> _onLoad(
    LoadManagerProfile event,
    Emitter<ManagerProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ManagerProfileStatus.loading, error: null));

      final profile = await repo.getUserProfile(event.userId);

      emit(state.copyWith(
        status: ManagerProfileStatus.success,
        profile: profile,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: ManagerProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateManagerProfile event,
    Emitter<ManagerProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ManagerProfileStatus.updating, error: null));

      final currentProfile = state.profile!;
      final updated = await repo.updateMyProfile(
        id: currentProfile.id,
        firstName: event.firstName,
        lastName: event.lastName,
      );

      emit(state.copyWith(
        status: ManagerProfileStatus.success,
        profile: updated,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: ManagerProfileStatus.error, error: e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangeManagerPassword event,
    Emitter<ManagerProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ManagerProfileStatus.passwordChanging, error: null));

      await repo.changeMyPassword(
        id: state.profile!.id,
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      emit(state.copyWith(status: ManagerProfileStatus.success, error: null));
    } catch (e) {
      emit(state.copyWith(status: ManagerProfileStatus.error, error: e.toString()));
    }
  }
}
