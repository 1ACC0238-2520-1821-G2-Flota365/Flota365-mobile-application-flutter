import '../../domain/entities/manager_profile_entity.dart';

class ManagerProfileDto {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String role;

  ManagerProfileDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory ManagerProfileDto.fromJson(Map<String, dynamic> json) {
    return ManagerProfileDto(
      id: (json['id'] as num).toInt(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }

  ManagerProfileEntity toEntity() => ManagerProfileEntity(
        id: id,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName,
        email: email,
        role: role,
      );
}
