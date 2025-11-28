class ApiPaths {
  // Base URL del backend
  static const String baseUrl =
      'https://flota365-backend-corp-cmawf5ddamh5f7b8.westus3-01.azurewebsites.net';

  // --- Auth ---
  static const String authLogin = '/api/Auth/login';
  static const String authRegister = '/api/Auth/register';
  static String authProfileId(int id) => '/api/Auth/profile/$id';

  // --- Drivers ---
  static const String drivers = '/api/Driver';

  // --- Vehicles ---
  static const String vehicles = '/api/Vehicle';

  // --- Assignments ---
  static const String assignment = '/api/Assignment';
  static String assignmentById(int id) => '/api/Assignment/$id';
  static String assignmentStart(int id) => '/api/Assignment/$id/start';
  static String assignmentComplete(int id) => '/api/Assignment/$id/complete';
}
