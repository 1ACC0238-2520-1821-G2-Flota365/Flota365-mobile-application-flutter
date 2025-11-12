class DriverInfo {
  final String id;
  final String fullName;
  final String? email;

  DriverInfo({
    required this.id,
    required this.fullName,
    this.email,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? json['nombre'] ?? 'Conductor',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
      };
}
