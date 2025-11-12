class RouteSummary {
  final String id;
  final String code;     // ej. "RT-045"
  final String status;   // "pendiente" | "en curso" | "completada"

  const RouteSummary({
    required this.id,
    required this.code,
    required this.status,
  });

  factory RouteSummary.fromJson(Map<String, dynamic> j) => RouteSummary(
        id: (j['id'] ?? j['routeId'] ?? '').toString(),
        code: (j['code'] ?? j['name'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
      );
}
