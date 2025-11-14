// lib/main.dart
import 'package:flota365/features/driver/presentation/pages/route_detail_page.dart';
import 'package:flota365/features/driver/presentation/pages/routes_page.dart';
import 'package:flutter/material.dart';
import 'core/ui/theme.dart';

// Auth
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/role_picker_page.dart';
import 'features/auth/presentation/pages/register_driver_page.dart';
import 'features/auth/presentation/pages/register_manager_page.dart';

// Driver
import 'features/driver/presentation/pages/dashboard_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const login = '/login';
  static const role = '/role';
  static const regDriver = '/register/driver';
  static const regManager = '/register/manager';
  static const managerHome = '/manager/home';
  static const driverHome = '/driver/home';
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
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.role: (_) => const RolePickerPage(),
        AppRoutes.regDriver: (_) => const RegisterDriverPage(),
        AppRoutes.regManager: (_) => const RegisterManagerPage(),
        AppRoutes.managerHome: (_) => const _Stub(title: 'Home Gestor'),

        // 🔵 LISTA DE RUTAS (MOCK)
        '/routes': (context) {
          final driverId = ModalRoute.of(context)!.settings.arguments as String;
          return RoutesPage(driverId: driverId);
        },

        // 🔵 DETALLE DE RUTA (MOCK)
        '/route-detail': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return RouteDetailPage(routeId: id); // 🔥 CORREGIDO
        },
      },

      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.driverHome) {
          final args = settings.arguments;
          String driverId = '';

          if (args is String) {
            driverId = args;
          } else if (args is Map) {
            driverId = args['driverId']?.toString() ?? '';
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

class _Stub extends StatelessWidget {
  final String title;
  const _Stub({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
