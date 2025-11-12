import 'package:flutter/material.dart';
import 'core/ui/theme.dart';

// Auth
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/role_picker_page.dart';
import 'features/auth/presentation/pages/register_driver_page.dart';
import 'features/auth/presentation/pages/register_manager_page.dart';

// Driver
import 'features/driver/presentation/pages/dashboard_page.dart';

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
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/role': (_) => const RolePickerPage(),
        '/register/driver': (_) => const RegisterDriverPage(),
        '/register/manager': (_) => const RegisterManagerPage(),
        '/manager/home': (_) => const _Stub(title: 'Home Gestor'),
      },

      // 🚀 Ruta dinámica con seguridad en argumentos
      onGenerateRoute: (settings) {
        if (settings.name == '/driver/home') {
          final args = settings.arguments;
          String driverId = '';
          String? fullName;
          String? email;

          if (args is Map) {
            driverId = args['driverId']?.toString() ?? '';
            fullName = args['fullName']?.toString();
            email    = args['email']?.toString();
          } else if (args is String) {
            driverId = args;
          }

          debugPrint('🟢 /driver/home args => id=$driverId, fullName=$fullName, email=$email, type=${args.runtimeType}');

          return MaterialPageRoute(
            builder: (_) => DriverDashboardPage(driverId: driverId),
          );
        }
        return null;
      },



    );
  }
}

// 🌐 Pantalla temporal para el gestor
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
                '/login',
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
