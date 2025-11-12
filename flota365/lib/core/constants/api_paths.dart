class ApiPaths {
  static const String baseUrl =
      'https://underground-tuesday-renworkplace-1e2821cb.koyeb.app';

  // --- Auth ---
  static const String authLogin = '/api/Auth/login';
  static const String authRegister = '/api/Auth/register';
  static String authProfileId(String id) => '/api/Auth/profile/$id';

  // --- Driver & Vehicle ---
  static const String drivers  = '$baseUrl/api/Driver';
  static const String vehicles = '$baseUrl/api/Vehicle';

  // --- Assignment ---
  static const String assignment = '$baseUrl/api/Assignment';
  static String assignmentStart(String id)    => '$baseUrl/api/Assignment/$id/start';
  static String assignmentComplete(String id) => '$baseUrl/api/Assignment/$id/complete';
}
