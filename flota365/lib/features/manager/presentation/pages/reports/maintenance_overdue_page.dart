import 'package:flota365/features/manager/presentation/blocs/maintenance_overdue/maintenance_overdue_bloc.dart';
import 'package:flota365/features/manager/presentation/blocs/maintenance_overdue/maintenance_overdue_event.dart';
import 'package:flota365/features/manager/presentation/blocs/maintenance_overdue/maintenance_overdue_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';
import '../../widgets/manager_drawer.dart';


class MaintenanceOverduePage extends StatelessWidget {
  const MaintenanceOverduePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaintenanceOverdueBloc(ManagerRepository(ManagerService()))
        ..add(LoadMaintenanceOverdue()),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ManagerDrawer(),
      appBar: AppBar(title: const Text("Mantenimiento vencido")),
      backgroundColor: const Color(0xFFF6F8FA),
      body: BlocBuilder<MaintenanceOverdueBloc, MaintenanceOverdueState>(
        builder: (ctx, s) {
          if (s.loading) return const Center(child: CircularProgressIndicator());
          if (s.error != null) return Center(child: Text(s.error!));
          if (s.records.isEmpty) return const Center(child: Text("No hay vencidos 🎉"));

          return RefreshIndicator(
            onRefresh: () async => ctx.read<MaintenanceOverdueBloc>().add(LoadMaintenanceOverdue()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: s.records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final r = s.records[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6))],
                    border: Border.all(color: Colors.red.withOpacity(.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text("Vehículo ID: ${r.vehicleId}", style: TextStyle(color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(r.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.red,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
