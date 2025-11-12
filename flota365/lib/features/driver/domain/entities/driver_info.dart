class DriverInfo {
  final String id;
  final String fullName;
  final String email;

  const DriverInfo({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> j) => DriverInfo(
        id: (j['id'] ?? '').toString(),
        fullName: (j['fullName'] ??
                '${j['firstName'] ?? ''} ${j['lastName'] ?? ''}')
            .trim(),
        email: (j['email'] ?? '').toString(),
      );
}
