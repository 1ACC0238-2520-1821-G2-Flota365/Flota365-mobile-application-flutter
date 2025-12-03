import 'package:flota365/features/manager/presentation/pages/assignments/assignment_detail_page.dart';
import 'package:flota365/features/manager/presentation/pages/assignments/assignment_list_page.dart';
import 'package:flota365/features/manager/presentation/pages/dashboard_page.dart';
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

  // DRIVER
  static const driverHome = '/driver/home';

  // MANAGER
  static const managerHome = '/manager/dashboard';   // 
  static const managerDashboard = '/manager/dashboard';
  static const managerFleets = '/manager/fleets'; // FleetPage
  static const managerVehicles = '/manager/vehicles'; 
  static const managerAssignments = '/manager/assignments';
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
        AppRoutes.managerHome: (_) => const ManagerDashboardPage(),
        AppRoutes.managerDashboard: (_) => const ManagerDashboardPage(),
        AppRoutes.managerFleets: (_) => const FleetPage(),
        AppRoutes.managerVehicles: (_) => const VehiclesPage(),
        "/manager/fleet/detail": (_) => const FleetDetailPage(),
        AppRoutes.managerAssignments: (_) => const AssignmentListPage(),
        



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
