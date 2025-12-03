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
              onTap: () {},
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


            // ========= MONITOREO =========
            _item(
              icon: Icons.remove_red_eye_rounded,
              label: "Monitoreo",
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, "/manager/monitoring");
              },
            ),

            // ========= REPORTES =========
            _item(
              icon: Icons.description_rounded,
              label: "Reportes",
              color: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, "/manager/reports");
              },
            ),

            // ========= NOTIFICACIONES =========
            _item(
              icon: Icons.notifications_active_rounded,
              label: "Notificaciones",
              color: Colors.teal,
              onTap: () {},
            ),

            // ========= SERVICIO AL CLIENTE =========
            _item(
              icon: Icons.help_outline_rounded,
              label: "Servicio al cliente",
              color: Colors.teal,
              onTap: () {},
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

  // ===========================================================
  // ITEM VISUAL (como tu mockup)
  // ===========================================================
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
