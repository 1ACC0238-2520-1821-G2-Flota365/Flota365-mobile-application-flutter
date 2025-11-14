class User {
  final String id;       
  final String fullName;
  final String email;
  final String role;

  const User({this.id, this.fullName, this.email, this.role});

  factory User.fromJson(Map<String, dynamic> j) {
    final first = (j['firstName'] ?? '').toString();
    final last  = (j['lastName'] ?? '').toString();

    final fn = (j['fullName'] ?? '$first $last').toString().trim();

    return User(
      id: (j['id'] ?? '').toString(),
      fullName: fn.isEmpty ? null : fn,
      email: (j['email'] ?? '').toString(),
      role: (j['role'] ?? '').toString(),
    );
  }
}
