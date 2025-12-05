import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';
import '../../../domain/entities/maintenance_record_entity.dart';
import '../../widgets/manager_drawer.dart';
import '../../blocs/maintenance/maintenance_records_bloc.dart';
import '../../blocs/maintenance/maintenance_records_event.dart';
import '../../blocs/maintenance/maintenance_records_state.dart';

class MaintenanceRecordsPage extends StatelessWidget {
  const MaintenanceRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaintenanceRecordsBloc(ManagerRepository(ManagerService()))
        ..add(LoadMaintenanceRecords()),
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
      appBar: AppBar(title: const Text("Registros de mantenimiento")),
      backgroundColor: const Color(0xFFF6F8FA),
      body: BlocConsumer<MaintenanceRecordsBloc, MaintenanceRecordsState>(
        listener: (ctx, s) {
          if (s.error != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s.error!)));
          } else if (s.success) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Operación exitosa")));
          }
        },
        builder: (ctx, s) {
          if (s.loading && s.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.records.isEmpty) {
            return const Center(child: Text("No hay registros de mantenimiento"));
          }

          return RefreshIndicator(
            onRefresh: () async => ctx.read<MaintenanceRecordsBloc>().add(LoadMaintenanceRecords()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: s.records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _RecordTile(record: s.records[i]),
            ),
          );
        },
      ),
     floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bloc = context.read<MaintenanceRecordsBloc>();

          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const _MaintenanceRecordDialog(),
            ),
          );

          if (ok == true && context.mounted) {
            bloc.add(LoadMaintenanceRecords());
          }
        },
        child: const Icon(Icons.add),
      ),

    );
  }
}

class _RecordTile extends StatelessWidget {
  final MaintenanceRecordEntity record;
  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    Color chipColor() {
      final s = record.status.toLowerCase();
      if (s.contains('overdue') || s.contains('venc')) return Colors.red;
      if (s.contains('open') || s.contains('pend')) return Colors.orange;
      if (s.contains('close') || s.contains('done') || s.contains('complete')) return Colors.green;
      return Colors.blueGrey;
    }

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
          child: const Icon(Icons.build_rounded, color: Colors.teal),
        ),
        title: Text(
          record.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          "Vehículo ID: ${record.vehicleId}\n${record.description.isEmpty ? "—" : record.description}",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(record.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: chipColor(),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                      tooltip: "Editar",
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () async {
                        final bloc = context.read<MaintenanceRecordsBloc>();

                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: _MaintenanceRecordDialog(record: record),
                          ),
                        );

                        if (ok == true && context.mounted) {
                          bloc.add(LoadMaintenanceRecords());
                        }
                      },
                    ),

                IconButton(
                  tooltip: "Eliminar",
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    context.read<MaintenanceRecordsBloc>().add(DeleteMaintenanceRecordRequested(record.id));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintenanceRecordDialog extends StatefulWidget {
  final MaintenanceRecordEntity? record;
  const _MaintenanceRecordDialog({this.record});

  @override
  State<_MaintenanceRecordDialog> createState() => _MaintenanceRecordDialogState();
}

class _MaintenanceRecordDialogState extends State<_MaintenanceRecordDialog> {
  late final TextEditingController vehicleIdCtrl;
  late final TextEditingController titleCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController statusCtrl;
  late final TextEditingController costCtrl;

  @override
  void initState() {
    super.initState();
    vehicleIdCtrl =
        TextEditingController(text: widget.record?.vehicleId.toString() ?? "");
    titleCtrl = TextEditingController(text: widget.record?.title ?? "");
    descCtrl = TextEditingController(text: widget.record?.description ?? "");
    statusCtrl = TextEditingController(text: widget.record?.status ?? "Open");
    costCtrl = TextEditingController(text: widget.record?.cost?.toString() ?? "");
  }

  @override
  void dispose() {
    vehicleIdCtrl.dispose();
    titleCtrl.dispose();
    descCtrl.dispose();
    statusCtrl.dispose();
    costCtrl.dispose();
    super.dispose();
  }

  // ✅ InputDecoration PRO (texto negro)
  InputDecoration _blackInput(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: const TextStyle(color: Colors.black45),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.teal, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;

    return AlertDialog(
      title: Text(isEdit ? "Editar registro" : "Crear registro"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: vehicleIdCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),   // ✅ texto escrito negro
              cursorColor: Colors.black,                     // ✅ cursor negro
              decoration: _blackInput("Vehicle ID"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: _blackInput("Título"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: descCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: _blackInput("Descripción"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: statusCtrl,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: _blackInput(
                "Status (Open/Closed/Overdue)",
                hint: "Open",
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: _blackInput("Costo (opcional)", hint: "0"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final vehicleId = int.tryParse(vehicleIdCtrl.text.trim());
            if (vehicleId == null || titleCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Vehicle ID y título son requeridos")),
              );
              return;
            }

            final body = <String, dynamic>{
              "vehicleId": vehicleId,
              "title": titleCtrl.text.trim(),
              "description": descCtrl.text.trim(),
              "status": statusCtrl.text.trim(),
              if (costCtrl.text.trim().isNotEmpty)
                "cost": double.tryParse(costCtrl.text.trim()) ?? 0,
            };

            if (isEdit) {
              context.read<MaintenanceRecordsBloc>().add(
                    UpdateMaintenanceRecordRequested(widget.record!.id, body),
                  );
            } else {
              context.read<MaintenanceRecordsBloc>().add(
                    CreateMaintenanceRecordRequested(body),
                  );
            }

            Navigator.pop(context, true);
          },
          child: Text(isEdit ? "Guardar" : "Crear"),
        ),
      ],
    );
  }
}
