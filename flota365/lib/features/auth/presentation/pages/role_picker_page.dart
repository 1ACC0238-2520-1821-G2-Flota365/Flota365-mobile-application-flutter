import 'package:flutter/material.dart';

class RolePickerPage extends StatelessWidget {
  const RolePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget roleCard({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: cs.primary.withOpacity(.12),
                  child: Icon(icon, color: cs.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('¿Quién eres?')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            roleCard(
              icon: Icons.local_shipping_rounded,
              title: 'Conductor de vehículo',
              subtitle: 'Regístrate como conductor',
              onTap: () => Navigator.pushNamed(context, '/register/driver'),
            ),
            const SizedBox(height: 12),
            roleCard(
              icon: Icons.manage_accounts_rounded,
              title: 'Gestor de flota',
              subtitle: 'Regístrate como gestor',
              onTap: () => Navigator.pushNamed(context, '/register/manager'),
            ),
          ],
        ),
      ),
    );
  }
}
