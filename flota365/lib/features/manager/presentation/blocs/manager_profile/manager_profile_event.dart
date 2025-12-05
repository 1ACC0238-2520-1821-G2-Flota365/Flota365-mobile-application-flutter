abstract class ManagerProfileEvent {}

class LoadManagerProfile extends ManagerProfileEvent {
  final int userId;

  LoadManagerProfile(this.userId);
}

class UpdateManagerProfile extends ManagerProfileEvent {
  final String firstName;
  final String lastName;

  UpdateManagerProfile({required this.firstName, required this.lastName});
}

class ChangeManagerPassword extends ManagerProfileEvent {
  final String currentPassword;
  final String newPassword;

  ChangeManagerPassword({required this.currentPassword, required this.newPassword});
}
