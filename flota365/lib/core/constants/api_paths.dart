class ApiPaths {
  static const String baseUrl =
      'https://underground-tuesday-renworkplace-1e2821cb.koyeb.app';

  // ---------------- AUTH ----------------
  static const String authLogin = '$baseUrl/api/Auth/login';
  static const String authRegister = '$baseUrl/api/Auth/register';

  // ✅ PERFIL
  static String authProfile(String id) => '$baseUrl/api/Auth/profile/$id';

  // Alias (por compatibilidad)
  static const String login = authLogin;
  static const String register = authRegister;

  // ---------------- DRIVER & VEHICLE ----------------
  static const String drivers = '$baseUrl/api/Driver';
  static const String vehicles = '$baseUrl/api/Vehicle';

  // ---------------- ASSIGNMENT ----------------
  static const String assignment = '$baseUrl/api/Assignment';
  static String assignmentStart(String id) =>
      '$baseUrl/api/Assignment/$id/start';
  static String assignmentComplete(String id) =>
      '$baseUrl/api/Assignment/$id/complete';
}
