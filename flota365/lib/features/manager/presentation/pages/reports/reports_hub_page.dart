import 'package:flota365/features/manager/presentation/widgets/manager_drawer.dart';
import 'package:flutter/material.dart';

class ReportsHubPage extends StatelessWidget {
  const ReportsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card({
      required IconData icon,
      required String title,
      required String subtitle,
      required String route,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.teal, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: const ManagerDrawer(),
      appBar: AppBar(title: const Text("Reportes & Mantenimiento")),
      backgroundColor: const Color(0xFFF6F8FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 4),
          Text("Centro de Reportes", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text("Gestiona mantenimiento e incidencias en un solo lugar.",
              style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 16),

          card(
            icon: Icons.build_rounded,
            title: "Registros de mantenimiento",
            subtitle: "Crear, editar y controlar historial.",
            route: "/manager/maintenance/records",
          ),
          const SizedBox(height: 12),

          card(
            icon: Icons.warning_amber_rounded,
            title: "Mantenimiento vencido",
            subtitle: "Pendientes y atrasos (overdue).",
            route: "/manager/maintenance/overdue",
          ),
          const SizedBox(height: 12),

          card(
            icon: Icons.local_offer_rounded,
            title: "Servicios (catálogo)",
            subtitle: "Gestiona tipos de servicios disponibles.",
            route: "/manager/maintenance/services",
          ),
          const SizedBox(height: 12),

          card(
            icon: Icons.description_rounded,
            title: "Incidentes / Reportes",
            subtitle: "Listado de reportes y creación.",
            route: "/manager/reports/list",
          ),
        ],
      ),
    );
  }
}
