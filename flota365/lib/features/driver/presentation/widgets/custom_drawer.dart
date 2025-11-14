import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onHome;
  final VoidCallback? onRoutes;
  final VoidCallback? onHistory;
  final VoidCallback? onNotifications;
  final VoidCallback? onSupport;
  final VoidCallback? onLogout;

  const CustomDrawer({
    super.key,
    this.onHome,
    this.onRoutes,
    this.onHistory,
    this.onNotifications,
    this.onSupport,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---- HEADER ----
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Menú de Flota:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Divider(),

            // ---- MENU ITEMS ----
            _drawerItem(
              icon: Icons.home_outlined,
              label: "Inicio",
              onTap: onHome,
            ),
            _drawerItem(
              icon: Icons.map,
              label: "Rutas",
              onTap: onRoutes,
            ),
            _drawerItem(
              icon: Icons.history,
              label: "Historial",
              onTap: onHistory,
            ),
            _drawerItem(
              icon: Icons.notifications_outlined,
              label: "Notificaciones",
              onTap: onNotifications,
            ),
            _drawerItem(
              icon: Icons.support_agent,
              label: "Servicio al cliente",
              onTap: onSupport,
            ),

            const Spacer(),

            // ---- LOGOUT ----
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _drawerItem(
                icon: Icons.logout,
                label: "Cerrar sesión",
                color: Colors.red,
                onTap: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    Color color = Colors.black87,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop; // cerrar drawer antes de navegar
        onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
