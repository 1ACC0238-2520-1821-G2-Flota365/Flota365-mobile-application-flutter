class User {
  final String id;        // como String
  final String fullName;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: (j['id'] ?? '').toString(),
        fullName: (j['fullName'] ??
            '${j['firstName'] ?? ''} ${j['lastName'] ?? ''}').trim(),
        email: (j['email'] ?? '').toString(),
        role: (j['role'] ?? '').toString(),
      );
}
