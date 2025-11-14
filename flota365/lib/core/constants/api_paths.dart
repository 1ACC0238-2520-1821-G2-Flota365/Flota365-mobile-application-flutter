class ApiPaths {
  // Base URL del backend
  static const String baseUrl =
      'https://underground-tuesday-renworkplace-1e2821cb.koyeb.app';

  // --- Auth ---
  static const String authLogin = '/api/Auth/login';
  static const String authRegister = '/api/Auth/register';
  static String authProfileId(String id) => '/api/Auth/profile/$id';

  // --- Drivers ---
  static const String drivers = '/api/Driver';

  // --- Vehicles ---
  static const String vehicles = '/api/Vehicle';

  // --- Assignments ---
  static const String assignment = '/api/Assignment';
  static String assignmentById(String id) => '/api/Assignment/$id';
  static String assignmentStart(String id) => '/api/Assignment/$id/start';
  static String assignmentComplete(String id) => '/api/Assignment/$id/complete';
}
