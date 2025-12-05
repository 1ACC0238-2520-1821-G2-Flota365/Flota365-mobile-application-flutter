import '../../../domain/entities/manager_profile_entity.dart';

enum ManagerProfileStatus { initial, loading, success, error, updating, passwordChanging }

class ManagerProfileState {
  final ManagerProfileStatus status;
  final ManagerProfileEntity? profile;
  final String? error;

  const ManagerProfileState({
    this.status = ManagerProfileStatus.initial,
    this.profile,
    this.error,
  });

  ManagerProfileState copyWith({
    ManagerProfileStatus? status,
    ManagerProfileEntity? profile,
    String? error,
  }) {
    return ManagerProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}
