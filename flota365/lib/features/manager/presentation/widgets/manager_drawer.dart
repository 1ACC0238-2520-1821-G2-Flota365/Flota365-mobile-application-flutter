import 'package:flota365/core/session/app_session.dart';
import 'package:flota365/main.dart';
import 'package:flutter/material.dart';

class ManagerDrawer extends StatelessWidget {
  const ManagerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // ========= USUARIO =========
            _item(
               icon: Icons.person,
                label: "Usuario",
                color: Colors.teal,
                onTap: () {
                  Navigator.pop(context); // ✅ cierra el drawer
                  final id = AppSession.userId;

                  if (id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No hay userId en sesión. Revisa el login.")),
                    );
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    "/manager/profile",
                    arguments: {'userId': id}, // ✅ esto lo lee tu ManagerProfilePage
                  );
                },
              ),

            const SizedBox(height: 10),

            // ========= DASHBOARD =========
            _item(
              icon: Icons.dashboard_rounded,
              label: "Dashboard",
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, "/manager/dashboard");
              },
            ),

            // ========= GESTIÓN DE FLOTA =========
            _item(
              icon: Icons.directions_car_filled_rounded,
              label: "Gestión de Flota",
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, "/manager/fleets");
              },
            ),

            // ========= RUTAS (ASSIGNMENTS) =========
            _item(
              icon: Icons.route,
              label: "Rutas / Asignaciones",
              color: Colors.teal,
              onTap: () => Navigator.pushNamed(context, "/manager/assignments"),
            ),

            // ========= REPORTES =========
            _item(
              icon: Icons.description_rounded,
              label: "Reportes",
              color: Colors.teal,
             onTap: () => Navigator.pushNamed(context, AppRoutes.managerReportsHub),

            ),

            const Spacer(),

            // ========= CERRAR SESIÓN =========
            _item(
              icon: Icons.logout_rounded,
              label: "Cerrar sesión",
              color: Colors.red,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (_) => false,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required Function() onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: color),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
