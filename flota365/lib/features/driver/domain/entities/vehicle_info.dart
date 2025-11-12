class VehicleInfo {
  final String plate;
  final String model;
  final String? year;

  const VehicleInfo({
    required this.plate,
    required this.model,
    this.year,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> j) => VehicleInfo(
        plate: (j['plate'] ?? j['placa'] ?? '').toString(),
        model: (j['model'] ?? j['modelo'] ?? '').toString(),
        year: j['year']?.toString(),
      );
}
