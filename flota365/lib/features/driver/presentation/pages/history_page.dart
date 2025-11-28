import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/history/history_bloc.dart';
import '../blocs/history/history_event.dart';
import '../blocs/history/history_state.dart';
import '../../data/driver_repository.dart';
import '../../data/driver_service.dart';
import '../../domain/entities/assignmentEntity.dart';

class HistoryPage extends StatelessWidget {
  final int driverId;

  const HistoryPage({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryBloc(DriverRepository(DriverService()))
        ..add(LoadHistory(driverId)),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de rutas")),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          switch (state.status) {
            case HistoryStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case HistoryStatus.failure:
              return Center(child: Text("Error: ${state.error}"));
            case HistoryStatus.success:
              if (state.items.isEmpty) {
                return const Center(
                    child: Text("No hay historial disponible."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: state.items.length,
                itemBuilder: (_, i) {
                  final AssignmentEntity item = state.items[i];
                  final assigned = item.assignedAt == null
                      ? '-'
                      : item.assignedAt!
                          .toLocal()
                          .toString()
                          .substring(0, 16);
                  final completed = item.completedAt == null
                      ? '-'
                      : item.completedAt!
                          .toLocal()
                          .toString()
                          .substring(0, 16);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.route_outlined),
                      title: Text(item.route),
                      subtitle: Text(
                        "Inicio: $assigned\nFin:    $completed",
                      ),
                    ),
                  );
                },
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
