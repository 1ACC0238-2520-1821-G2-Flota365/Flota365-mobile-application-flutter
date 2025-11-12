class ApiPaths {
  static const String baseUrl =
      'https://underground-tuesday-renworkplace-1e2821cb.koyeb.app';

  // Auth
  static const String authLogin = '/api/Auth/login';
  static const String authRegister = '/api/Auth/register';
  static String authProfileId(String id) => '/api/Auth/profile/$id';

  // Alias (si tu código viejo usaba estos)
  static const String login = authLogin;
  static const String register = authRegister;

  // Driver & Vehicle (para búsquedas)
  static const String drivers = '$baseUrl/api/Driver';
  static const String vehicles = '$baseUrl/api/Vehicle';

  // Assignment (OJO: singular)
  static const String assignment = '$baseUrl/api/Assignment';
  static String assignmentStart(String id) => '$baseUrl/api/Assignment/$id/start';
  static String assignmentComplete(String id) => '$baseUrl/api/Assignment/$id/complete';
}
