import 'package:flota365/features/manager/presentation/pages/vehicle_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';
import '../../../domain/entities/fleet_entity.dart';
import '../../widgets/manager_drawer.dart';

import '../../blocs/vehicles/vehicles_bloc.dart';
import '../../blocs/vehicles/vehicles_event.dart';
import '../../blocs/vehicles/vehicles_state.dart';

class FleetDetailPage extends StatelessWidget {
  const FleetDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FleetEntity fleet =
        ModalRoute.of(context)!.settings.arguments as FleetEntity;

    return BlocProvider(
      create: (_) => VehiclesBloc(ManagerRepository(ManagerService()))
        ..add(LoadVehiclesForFleet(fleet.id)),
      child: _FleetDetailView(fleet: fleet),
    );
  }
}

class _FleetDetailView extends StatelessWidget {
  final FleetEntity fleet;

  const _FleetDetailView({required this.fleet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const ManagerDrawer(),
      appBar: AppBar(
        title: Text(fleet.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ===== HEADER PRO =====
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(.14),
                    theme.colorScheme.secondary.withOpacity(.10),
                  ],
                ),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: theme.colorScheme.primary.withOpacity(.18),
                      ),
                      child: Icon(Icons.apartment_rounded, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fleet.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fleet.description.isEmpty ? "Sin descripción" : fleet.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(.75),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ChipStat(
                                icon: Icons.directions_car_filled_rounded,
                                label: '${fleet.vehicleCount} ${fleet.vehicleCount == 1 ? "vehículo" : "vehículos"}',
                              ),
                              _ChipStat(
                                icon: Icons.verified_rounded,
                                label: fleet.isActive ? 'Activa' : 'Inactiva',
                                color: fleet.isActive ? Colors.green : Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== LISTA =====
          Expanded(
            child: BlocBuilder<VehiclesBloc, VehiclesState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.vehicles.isEmpty) {
                  return const _EmptyState(
                    title: "Sin vehículos",
                    subtitle: "Agrega el primer vehículo a esta flota.",
                    icon: Icons.directions_car_rounded,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<VehiclesBloc>().add(LoadVehiclesForFleet(fleet.id));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 120),
                    itemCount: state.vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final v = state.vehicles[i];

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {}, // (si luego quieres abrir detalle del vehículo)
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: theme.colorScheme.surface,
                              border: Border.all(color: theme.dividerColor.withOpacity(.12)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                  color: Colors.black.withOpacity(.05),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: theme.colorScheme.primary.withOpacity(.12),
                                    ),
                                    child: Icon(
                                      Icons.directions_car_filled_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.licensePlate,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${v.brand} ${v.model}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.textTheme.bodyMedium?.color?.withOpacity(.70),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    children: [
                                      IconButton(
                                        tooltip: 'Editar',
                                        icon: const Icon(Icons.edit_rounded),
                                        onPressed: () async {
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider.value(
                                                value: context.read<VehiclesBloc>(),
                                                child: VehicleFormPage(
                                                  vehicle: v,
                                                  fleetId: fleet.id,
                                                  fleetName: fleet.name,
                                                ),
                                              ),
                                            ),
                                          );

                                          if (updated == true) {
                                            context.read<VehiclesBloc>().add(
                                                  LoadVehiclesForFleet(fleet.id),
                                                );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        tooltip: 'Eliminar',
                                        icon: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
                                        onPressed: () {
                                          context.read<VehiclesBloc>().add(
                                                DeleteVehicleRequested(v.id),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Agregar vehículo'),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<VehiclesBloc>(),
                child: VehicleFormPage(
                  fleetId: fleet.id,
                  fleetName: fleet.name,
                ),
              ),
            ),
          );

          if (created == true) {
            context.read<VehiclesBloc>().add(LoadVehiclesForFleet(fleet.id));
          }
        },
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _ChipStat({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor.withOpacity(.12)),
            color: theme.colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: theme.colorScheme.primary.withOpacity(.12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
