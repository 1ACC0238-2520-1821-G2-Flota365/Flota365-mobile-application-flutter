import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';
import '../../widgets/manager_drawer.dart';
import '../../blocs/reports/reports_bloc.dart';
import '../../blocs/reports/reports_event.dart';
import '../../blocs/reports/reports_state.dart';

class ReportsListPage extends StatelessWidget {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsBloc(ManagerRepository(ManagerService()))
        ..add(LoadReports()),
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
      appBar: AppBar(
        title: const Text("Incidentes / Reportes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, "/manager/reports/create"),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (ctx, s) {
          if (s.loading) return const Center(child: CircularProgressIndicator());
          if (s.error != null) return Center(child: Text(s.error!));
          if (s.reports.isEmpty) return const Center(child: Text("No hay reportes registrados"));

          return RefreshIndicator(
            onRefresh: () async => ctx.read<ReportsBloc>().add(LoadReports()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: s.reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final r = s.reports[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.description_rounded, color: Colors.teal),
                    ),
                    title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      r.description.isEmpty ? "—" : r.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Chip(
                      label: Text(r.status),
                      backgroundColor: Colors.grey.shade200,
                    ),
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
