// lib/features/driver/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/status.dart';
import '../../../../features/driver/presentation/widgets/custom_drawer.dart'; // <-- IMPORTANTE
import '../../../../main.dart' show AppRoutes;

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

  void _goDashboardHome(BuildContext context, {required String driverId}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.driverHome,
      (_) => false,
      arguments: {'driverId': driverId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            _goDashboardHome(context, driverId: state.driverId);
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Flota365 - Conductor'),
              actions: [
                IconButton(
                  tooltip: 'Inicio',
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () => _goDashboardHome(
                    context,
                    driverId: state.driverId,
                  ),
                ),
              ],
            ),

            drawer: CustomDrawer(
                onHome: () => _goDashboardHome(
                  context,
                  driverId: state.driverId,
                ),

                onRoutes: () {
                  Navigator.pushNamed(context, '/routes', arguments: state.driverId);
                },

                onHistory: () {
                  Navigator.pushNamed(context, '/history', arguments: state.driverId);
                },

                onNotifications: () {
                  Navigator.pushNamed(context, '/notifications');
                },

                onSupport: () {
                  Navigator.pushNamed(context, '/support');
                },

                onLogout: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),


                          body: _DashboardBody(state: state),
                        ),
                      );
                    },
                  );
                }
              }

class _DashboardBody extends StatelessWidget {
  final DashboardState state;
  const _DashboardBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == Status.failure) {
      return Center(child: Text(state.error ?? 'Error al cargar datos'));
    }

    final current = state.current;
    final fullName = (state.profile?['fullName'] ?? 'Conductor').toString();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Saludo
            Card(
              child: ListTile(
                title: Text(
                  'Bienvenido, $fullName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Jornada actual
            Card(
              child: ListTile(
                title: const Text(
                  'Jornada actual',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  current == null
                      ? 'Sin assignment activo'
                      : 'Ruta: ${current['route'] ?? current['routeId']?.toString() ?? '-'}\n'
                        'ID: ${current['id']?.toString() ?? '-'}',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botones
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
  }
}
