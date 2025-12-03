import 'package:flota365/features/manager/presentation/widgets/manager_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/manager_repository.dart';
import '../../data/manager_service.dart';
import '../blocs/vehicles/vehicles_bloc.dart';
import '../blocs/vehicles/vehicles_event.dart';
import '../blocs/vehicles/vehicles_state.dart';
import '../../domain/entities/vehicle_entity.dart';
import 'vehicle_form_page.dart';

class VehiclesPage extends StatelessWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Aquí inyectamos repo + bloc.
      create: (_) => VehiclesBloc(ManagerRepository(ManagerService()))
        ..add(LoadVehicles()),
      child: const _VehiclesView(),
    );
  }
}

class _VehiclesView extends StatelessWidget {
  const _VehiclesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ManagerDrawer(),
      appBar: AppBar(
        title: const Text('Gestión de Vehículos'),
      ),
      body: BlocConsumer<VehiclesBloc, VehiclesState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          } else if (state.actionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Operación realizada con éxito')),
            );
          }
        },
        builder: (context, state) {
          if (state.loading && state.vehicles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.vehicles.isEmpty) {
            return const Center(child: Text('No hay vehículos registrados'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<VehiclesBloc>().add(LoadVehicles());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: state.vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final v = state.vehicles[index];
                return _VehicleTile(vehicle: v);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bloc = context.read<VehiclesBloc>();

          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const VehicleFormPage(),
              ),
            ),
          );

          if (created == true) {
            bloc.add(LoadVehicles());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final VehicleEntity vehicle;
  const _VehicleTile({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VehiclesBloc>();

    return Card(
      child: ListTile(
        title: Text(
          vehicle.licensePlate,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            '${vehicle.brand} ${vehicle.model} · Estado: ${vehicle.status} · Conductor: ${vehicle.driverName.isEmpty ? "Sin asignar" : vehicle.driverName}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: VehicleFormPage(vehicle: vehicle),
                    ),
                  ),
                );

                if (updated == true) {
                  bloc.add(LoadVehicles());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                bloc.add(DeleteVehicleRequested(vehicle.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
