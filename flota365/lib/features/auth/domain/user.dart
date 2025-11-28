class User {
  final int id;
  final String fullName;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> j) {
    final first = (j['firstName'] ?? '').toString();
    final last = (j['lastName'] ?? '').toString();
    final fullname = (j['fullName'] ?? '$first $last').toString().trim();

    return User(
      id: j['id'] is int ? j['id'] : int.tryParse(j['id'].toString()) ?? 0,
      fullName: fullname,
      email: j['email']?.toString() ?? '',
      role: j['role']?.toString() ?? '',
    );
  }
}
