import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flota365/features/manager/presentation/blocs/maintenance_services/maintenance_services_bloc.dart';
import 'package:flota365/features/manager/presentation/blocs/maintenance_services/maintenance_services_event.dart';
import 'package:flota365/features/manager/presentation/blocs/maintenance_services/maintenance_services_state.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';
import '../../../domain/entities/vehicle_entity.dart';
import '../../widgets/manager_drawer.dart';

class MaintenanceServicesPage extends StatelessWidget {
  const MaintenanceServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaintenanceServicesBloc(ManagerRepository(ManagerService()))
        ..add(LoadMaintenanceServices()),
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
      appBar: AppBar(title: const Text("Servicios (catálogo)")),
      backgroundColor: const Color(0xFFF6F8FA),
      body: BlocConsumer<MaintenanceServicesBloc, MaintenanceServicesState>(
        listener: (ctx, s) {
          if (s.error != null && s.error!.isNotEmpty) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(s.error!)),
            );
          } else if (s.success) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text("Operación exitosa")),
            );
          }
        },
        builder: (ctx, s) {
          if (s.loading && s.services.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (s.services.isEmpty) {
            return const Center(child: Text("No hay servicios registrados"));
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ctx.read<MaintenanceServicesBloc>().add(LoadMaintenanceServices()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: s.services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final svc = s.services[i];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.local_offer_rounded, color: Colors.teal),
                    ),
                    title: Text(
                      svc.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(svc.description ?? "—"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ctx
                            .read<MaintenanceServicesBloc>()
                            .add(DeleteMaintenanceServiceRequested(svc.id));
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // IMPORTANTÍSIMO: usa el context del Scaffold (que sí tiene el bloc)
          final bloc = context.read<MaintenanceServicesBloc>();

          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: const _CreateMaintenanceServiceDialog(),
            ),
          );

          if (ok == true && context.mounted) {
            bloc.add(LoadMaintenanceServices());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Dialog separado para evitar:
/// - Provider not found
/// - Overflow
/// - Controllers usados después de dispose
class _CreateMaintenanceServiceDialog extends StatefulWidget {
  const _CreateMaintenanceServiceDialog();

  @override
  State<_CreateMaintenanceServiceDialog> createState() =>
      _CreateMaintenanceServiceDialogState();
}

class _CreateMaintenanceServiceDialogState
    extends State<_CreateMaintenanceServiceDialog> {
  final _serviceTypeCtrl = TextEditingController(); // antes: name
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  int? _vehicleId;
  bool _submitting = false;

  late final ManagerRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ManagerRepository(ManagerService());
  }

  @override
  void dispose() {
    _serviceTypeCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  // ✅ "FORMA PRO": forzar estilos del form (evita texto blanco)
  InputDecoration _dec(
    String label, {
    String? hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black54),
      hintStyle: const TextStyle(color: Colors.black38),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.teal, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Future<void> _submit() async {
    final serviceType = _serviceTypeCtrl.text.trim();
    if (_vehicleId == null || _vehicleId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un vehículo")),
      );
      return;
    }
    if (serviceType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe el tipo/nombre del servicio")),
      );
      return;
    }

    final cost = double.tryParse(_costCtrl.text.trim()) ?? 0;

    setState(() => _submitting = true);

    context.read<MaintenanceServicesBloc>().add(
          CreateMaintenanceServiceRequested({
            "vehicleId": _vehicleId,
            "serviceType": serviceType,
            "description": _descCtrl.text.trim(),
            "cost": cost,
            "serviceDate": DateTime.now().toIso8601String(),
            "mileageAtService": 0,
            "serviceProvider": "",
          }),
        );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // ✅ fuerza fondo blanco
      title: const Text(
        "Crear servicio",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: FutureBuilder<List<VehicleEntity>>(
          future: _repo.getVehicles(),
          builder: (context, snap) {
            final vehicles = snap.data ?? const <VehicleEntity>[];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _vehicleId,
                  decoration: _dec(
                    "Vehículo",
                    hint: "Selecciona una placa",
                    prefixIcon: const Icon(Icons.directions_car, color: Colors.teal),
                  ),
                  style: const TextStyle(color: Colors.black87), // ✅ texto seleccionado
                  dropdownColor: Colors.white, // ✅ items visibles
                  items: vehicles
                      .map((v) => DropdownMenuItem<int>(
                            value: v.id,
                            child: Text(
                              "${v.licensePlate}  (ID: ${v.id})",
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _vehicleId = v),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _serviceTypeCtrl,
                  style: const TextStyle(color: Colors.black87), // ✅ texto
                  decoration: _dec(
                    "Tipo / Nombre del servicio",
                    hint: "Ej: Inflar llantas",
                    prefixIcon: const Icon(Icons.build_rounded, color: Colors.teal),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.black87),
                  decoration: _dec(
                    "Descripción",
                    hint: "Detalle del servicio",
                    prefixIcon: const Icon(Icons.description_rounded, color: Colors.teal),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _costCtrl,
                  style: const TextStyle(color: Colors.black87),
                  keyboardType: TextInputType.number,
                  decoration: _dec(
                    "Costo (opcional)",
                    hint: "0",
                    prefixIcon: const Icon(Icons.payments_rounded, color: Colors.teal),
                  ),
                ),

                if (snap.connectionState == ConnectionState.waiting) ...[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(),
                ],
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context, false),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Crear"),
        ),
      ],
    );
  }
}
