import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../data/driver_repository.dart';
import '../../data/driver_service.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_event.dart';
import '../blocs/dashboard/dashboard_state.dart';
import 'checkin_page.dart';
import 'checkout_page.dart';

class DriverDashboardPage extends StatelessWidget {
  final String driverId;
  const DriverDashboardPage({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(DriverRepository(DriverService()))
        ..add(DashboardStarted(driverId)),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flota365 - Conductor')),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(child: Text('Menú')),
            ListTile(leading: Icon(Icons.route), title: Text('Rutas')),
            ListTile(leading: Icon(Icons.history), title: Text('Historial')),
          ],
        ),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == Status.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == Status.failure) {
            return Center(child: Text(state.error ?? 'Error al cargar datos'));
          }

          final current = state.current;
          final profile = state.profile;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- Tarjeta de bienvenida ----
                Card(
                  child: ListTile(
                    title: Text(
                      'Bienvenido, ${profile?['fullName'] ?? 'Conductor'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Email: ${profile?['email'] ?? '-'}\nID: ${state.driverId}',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---- Información de la jornada ----
                Card(
                  child: ListTile(
                    title: Text('Bienvenido, ${state.profile?['fullName'] ?? state.driverId}'),
                    subtitle: Text(
                      current == null
                          ? 'Sin assignment activo'
                          : 'Ruta: ${current['route'] ?? current['routeId']?.toString() ?? '-'}\nID: ${current['id']?.toString() ?? '-'}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Botones principales ----
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: current == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckInPage(
                                      assignmentId: current['id']?.toString() ?? '',
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Check-In'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: current == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckOutPage(
                                      assignmentId: current['id']?.toString() ?? '',
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Check-Out'),
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 16),

                // ---- Mensaje y botón para crear jornada ----
                if (current == null)
                  Column(
                    children: [
                      const Text(
                        'No se encontró un assignment activo para este conductor.\n'
                        'Puedes crear una nueva jornada a continuación:',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<DashboardBloc>()
                            .add(DashboardCreateAssignment()),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Crear jornada'),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
