import 'package:flota365/features/manager/presentation/pages/assignments/assignment_detail_page.dart';
import 'package:flota365/features/manager/presentation/pages/assignments/assignment_list_page.dart';
import 'package:flota365/features/manager/presentation/pages/dashboard_page.dart';
import 'package:flota365/features/manager/presentation/pages/manager_profile_page.dart';
import 'package:flota365/features/manager/presentation/pages/reports/maintenance_overdue_page.dart';
import 'package:flota365/features/manager/presentation/pages/reports/maintenance_records_page.dart';
import 'package:flota365/features/manager/presentation/pages/reports/maintenance_services_page.dart';
import 'package:flota365/features/manager/presentation/pages/reports/report_form_page.dart';
import 'package:flota365/features/manager/presentation/pages/reports/reports_hub_page.dart';
import 'package:flota365/features/manager/presentation/pages/reports/reports_list_page.dart';
import 'package:flutter/material.dart';
import 'core/ui/theme.dart';

// AUTH
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/role_picker_page.dart';
import 'features/auth/presentation/pages/register_driver_page.dart';
import 'features/auth/presentation/pages/register_manager_page.dart';

// DRIVER
import 'features/driver/presentation/pages/dashboard_page.dart';
import 'features/driver/presentation/pages/routes_page.dart';
import 'features/driver/presentation/pages/route_detail_page.dart';
import 'features/driver/presentation/pages/history_page.dart';
import 'features/driver/presentation/pages/support_page.dart';

// MANAGER
import 'features/manager/presentation/pages/fleet/fleet_page.dart';
import 'features/manager/presentation/pages/fleet/fleet_detail_page.dart';
import 'features/manager/presentation/pages/vehicles_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  // AUTH
  static const login = '/login';
  static const role = '/role';
  static const regDriver = '/register/driver';
  static const regManager = '/register/manager';

   static const managerProfile = "/manager/profile";


  // DRIVER
  static const driverHome = '/driver/home';

  // MANAGER
  static const managerHome = '/manager/dashboard';   // 
  static const managerDashboard = '/manager/dashboard';
  static const managerFleets = '/manager/fleets'; // FleetPage
  static const managerVehicles = '/manager/vehicles'; 
  static const managerAssignments = '/manager/assignments';

    // REPORTS
  static const managerReports = '/manager/reports';
  static const reportsList = '/manager/reports/list';
  static const reportForm = '/manager/reports/new';

  static const maintenanceRecords = '/manager/reports/maintenance/records';
  static const maintenanceOverdue = '/manager/reports/maintenance/overdue';
  static const maintenanceServices = '/manager/reports/maintenance/services';

    // REPORTS / MAINTENANCE HUB
  static const managerReportsHub = '/manager/reports';

  // MAINTENANCE
  static const managerMaintenanceRecords = '/manager/maintenance/records';
  static const managerMaintenanceOverdue = '/manager/maintenance/overdue';
  static const managerMaintenanceServices = '/manager/maintenance/services';

  // REPORTS
  static const managerReportsList = '/manager/reports/list';
  static const managerReportForm = '/manager/reports/new';


}

void main() {
  runApp(const FlotaApp());
}

class FlotaApp extends StatelessWidget {
  const FlotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flota365',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.login,

      routes: {
        // AUTH
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.role: (_) => const RolePickerPage(),
        AppRoutes.regDriver: (_) => const RegisterDriverPage(),
        AppRoutes.regManager: (_) => const RegisterManagerPage(),

        // MANAGER
        AppRoutes.managerProfile: (_) => const ManagerProfilePage(),
        AppRoutes.managerHome: (_) => const ManagerDashboardPage(),
        AppRoutes.managerDashboard: (_) => const ManagerDashboardPage(),
        AppRoutes.managerFleets: (_) => const FleetPage(),
        AppRoutes.managerVehicles: (_) => const VehiclesPage(),
        "/manager/fleet/detail": (_) => const FleetDetailPage(),
        AppRoutes.managerAssignments: (_) => const AssignmentListPage(),

                // REPORTS
        AppRoutes.managerReports: (_) => const ReportsHubPage(),
        AppRoutes.reportsList: (_) => const ReportsListPage(),
        AppRoutes.reportForm: (_) => const ReportFormPage(),
        AppRoutes.maintenanceRecords: (_) => const MaintenanceRecordsPage(),
        AppRoutes.maintenanceOverdue: (_) => const MaintenanceOverduePage(),
        AppRoutes.maintenanceServices: (_) => const MaintenanceServicesPage(),

        // REPORTS / MAINTENANCE
        AppRoutes.managerReportsHub: (_) => const ReportsHubPage(),
        AppRoutes.managerMaintenanceRecords: (_) => const MaintenanceRecordsPage(),
        AppRoutes.managerMaintenanceOverdue: (_) => const MaintenanceOverduePage(),
        AppRoutes.managerMaintenanceServices: (_) => const MaintenanceServicesPage(),
        AppRoutes.managerReportsList: (_) => const ReportsListPage(),
        AppRoutes.managerReportForm: (_) => const ReportFormPage(),


        



        // DRIVER
        '/routes': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return RoutesPage(driverId: id);
        },
        '/route-detail': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return RouteDetailPage(routeId: id);
        },
        '/history': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return HistoryPage(driverId: id);
        },
        '/support': (_) => const SupportPage(),
      },

      // DRIVER HOME ROUTE
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.driverHome) {
          final args = settings.arguments;

          int driverId = 0;

          if (args is int) {
            driverId = args;
          } else if (args is Map) {
            driverId = args['driverId'] ?? 0;
          }

          return MaterialPageRoute(
            builder: (_) => DriverDashboardPage(driverId: driverId),
          );
        }
        
        return null;
      },

      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }
}

// (Solo queda por si algún día lo usas)
class _Stub extends StatelessWidget {
  final String title;
  const _Stub({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (_) => false,
          ),
          child: const Text('Cerrar sesión'),
        ),
      ),
    );
  }
}
