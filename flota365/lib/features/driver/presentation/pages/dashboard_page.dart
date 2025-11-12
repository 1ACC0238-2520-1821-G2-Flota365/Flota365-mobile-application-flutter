// lib/features/driver/presentation/pages/dashboard_page.dart
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
    final theme = Theme.of(context);

    return Scaffold(
      // usa colores del theme
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Flota365 - Conductor'),
      ),
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
          final fullName =
              (state.profile?['fullName'] ?? 'Conductor').toString().trim();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Bienvenida: SOLO el nombre (sin email/ID) ───────────────
                  Card(
                    child: ListTile(
                      title: Text(
                        'Bienvenido, $fullName',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 👇 importante: NADA de subtitle aquí
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Jornada actual (mínimo texto) ───────────────────────────
                  Card(
                    child: ListTile(
                      title: Text(
                        'Jornada actual',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        current == null
                            ? 'Sin assignment activo'
                            : 'Ruta: ${current['route'] ?? current['routeId']?.toString() ?? '-'}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Botones principales ────────────────────────────────────
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
                                        assignmentId:
                                            current['id']?.toString() ?? '',
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
                                        assignmentId:
                                            current['id']?.toString() ?? '',
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

                  // ── Crear jornada cuando no hay activa ─────────────────────
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
            ),
          );
        },
      ),
    );
  }
}
