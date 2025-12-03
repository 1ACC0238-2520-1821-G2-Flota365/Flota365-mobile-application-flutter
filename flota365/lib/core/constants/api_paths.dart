class ApiPaths {
  // BASE URL
  static const String baseUrl =
      'https://flota365-backend-corp-cmawf5ddamh5f7b8.westus3-01.azurewebsites.net';

  // AUTH
  static const String authLogin = '/api/Auth/login';
  static const String authRegister = '/api/Auth/register';
  static const String authProfile = '/api/Auth/profile';
  static String authProfileId(int id) => '/api/Auth/profile/$id';
  static const String authUsers = '/api/Auth/users';
  static String authUsersId(int id) => '/api/Auth/users/$id';
  static const String authHealth = '/api/Auth/health';
  static String authChangePassword(int id) => '/api/Auth/change-password/$id';

  // DRIVERS
  static const String drivers = '/api/Driver';
  static String driverById(int id) => '/api/Driver/$id';
  static const String driverStats = '/api/Driver/stats';

  // VEHICLES
  static const String vehicles = '/api/Vehicle';
  static String vehicleById(int id) => '/api/Vehicle/$id';

  // FLEETS
  static const String fleets = '/api/Fleets';
  static String fleetById(int id) => '/api/Fleets/$id';

  // DASHBOARD
  static const String dashboardStats = '/api/Dashboard/stats';
  static const String dashboardActiveVehicles = '/api/Dashboard/active-vehicles';
  static const String dashboardFleetSummary = '/api/Dashboard/fleet-summary';

  // ASSIGNMENTS (RUTAS)
  static const String assignment = '/api/Assignment';
  static String assignmentById(int id) => '/api/Assignment/$id';
  static String assignmentStart(int id) => '/api/Assignment/$id/start';
  static String assignmentComplete(int id) => '/api/Assignment/$id/complete';

  // MANAGER
  static const String manager = '/api/Manager';
  static String managerById(int id) => '/api/Manager/$id';

  // REPORTS
  static const String reports = '/api/Report';
  static String reportById(int id) => '/api/Report/$id';

  // HEALTH (Opcional)
  static const String health = '/api/Health';
  static const String healthInfo = '/api/Health/info';

  // MAINTENANCE (Opcional)
  static const String maintenanceRecords = '/api/Maintenance/records';
  static String maintenanceRecordById(int id) => '/api/Maintenance/records/$id';
  static String maintenanceRecordByVehicle(int vehicleId) =>
      '/api/Maintenance/records/vehicle/$vehicleId';
  static const String maintenanceOverdue = '/api/Maintenance/records/overdue';

  static const String maintenanceServices = '/api/Maintenance/services';
  static String maintenanceServiceById(int id) =>
      '/api/Maintenance/services/$id';
  static String maintenanceServiceByVehicle(int vehicleId) =>
      '/api/Maintenance/services/vehicle/$vehicleId';
}
