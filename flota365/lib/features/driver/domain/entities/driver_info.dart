class DriverInfo {
  final int id;
  final String fullName;
  final String? email;

  DriverInfo({
    required this.id,
    required this.fullName,
    this.email,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      fullName: json['fullName'] ??
          json['name'] ??
          json['nombre'] ??
          'Conductor',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
      };
}
