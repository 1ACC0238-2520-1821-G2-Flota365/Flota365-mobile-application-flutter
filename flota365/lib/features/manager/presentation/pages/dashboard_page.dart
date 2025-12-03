import 'package:flota365/features/manager/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:flota365/features/manager/presentation/blocs/dashboard/dashboard_state.dart';
import 'package:flota365/features/manager/data/manager_repository.dart';
import 'package:flota365/features/manager/data/manager_service.dart';
import 'package:flota365/features/manager/presentation/blocs/dashboard/dashboard_event.dart';
import 'package:flota365/features/manager/presentation/widgets/manager_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(ManagerRepository(ManagerService()))
        ..add(LoadDashboard()),
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
      drawer: const ManagerDrawer(),
      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text("Error: ${state.error}"));
          }

          final stats = state.stats;

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<DashboardBloc>().add(LoadDashboard()),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.10),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  // ===== HEADER =====
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.insert_chart_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Resumen general",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Estado de tu flota en tiempo real",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: "Actualizar",
                        onPressed: () =>
                            context.read<DashboardBloc>().add(LoadDashboard()),
                        icon: const Icon(Icons.refresh_rounded),
                      )
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ===== STATS GRID =====
                  if (stats != null)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        _StatCardFancy(
                          title: "Vehículos",
                          value: stats.totalVehicles.toString(),
                          icon: Icons.directions_car_filled_rounded,
                          tone: _Tone.blue,
                        ),
                        _StatCardFancy(
                          title: "Conductores activos",
                          value: stats.activeDrivers.toString(),
                          icon: Icons.people_alt_rounded,
                          tone: _Tone.green,
                        ),
                        _StatCardFancy(
                          title: "En mantenimiento",
                          value: stats.vehiclesInMaintenance.toString(),
                          icon: Icons.build_circle_rounded,
                          tone: _Tone.orange,
                        ),
                        _StatCardFancy(
                          title: "Eficiencia",
                          value: "${stats.fleetEfficiency.toStringAsFixed(1)}%",
                          icon: Icons.speed_rounded,
                          tone: _Tone.purple,
                        ),
                      ],
                    ),

                  const SizedBox(height: 18),

                  // ===== ACTIVE VEHICLES HEADER =====
                  Row(
                    children: [
                      Text(
                        "Vehículos activos",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "${state.activeVehicles.length}",
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (state.activeVehicles.isEmpty)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.dividerColor.withOpacity(0.35),
                        ),
                      ),
                      child: const ListTile(
                        leading: Icon(Icons.info_outline_rounded),
                        title: Text("No hay vehículos activos"),
                      ),
                    )
                  else
                    ...state.activeVehicles.map((v) {
                      final statusTone = _statusToTone(v.statusName);
                      return _VehicleCard(
                        plate: v.licensePlate,
                        model: v.model,
                        fleet: v.fleetName,
                        driver: v.driverName,
                        statusText: v.statusName,
                        tone: statusTone,
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= UI COMPONENTS =================

enum _Tone { blue, green, orange, purple, red, gray }

class _StatCardFancy extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final _Tone tone;

  const _StatCardFancy({
    required this.title,
    required this.value,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = _toneColor(theme, tone);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.withOpacity(0.18),
            theme.colorScheme.surface,
          ],
        ),
        border: Border.all(color: theme.dividerColor.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: c),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "Hoy",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: c,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String plate;
  final String model;
  final String fleet;
  final String driver;
  final String statusText;
  final _Tone tone;

  const _VehicleCard({
    required this.plate,
    required this.model,
    required this.fleet,
    required this.driver,
    required this.statusText,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = _toneColor(theme, tone);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: c.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.directions_car_filled_rounded, color: c),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                plate,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _StatusPill(text: statusText, tone: tone),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$model · $fleet",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 2),
              Text(
                driver,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final _Tone tone;

  const _StatusPill({required this.text, required this.tone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = _toneColor(theme, tone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: c,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ================= helpers =================

_Tone _statusToTone(String s) {
  final v = s.toLowerCase().trim();
  if (v.contains("active")) return _Tone.green;
  if (v.contains("maintenance")) return _Tone.orange;
  if (v.contains("inactive")) return _Tone.gray;
  if (v.contains("alert") || v.contains("danger")) return _Tone.red;
  if (v.contains("completed")) return _Tone.blue;
  return _Tone.purple;
}

Color _toneColor(ThemeData theme, _Tone t) {
  switch (t) {
    case _Tone.blue:
      return const Color(0xFF3B82F6);
    case _Tone.green:
      return const Color(0xFF22C55E);
    case _Tone.orange:
      return const Color(0xFFF59E0B);
    case _Tone.purple:
      return const Color(0xFF8B5CF6);
    case _Tone.red:
      return const Color(0xFFEF4444);
    case _Tone.gray:
      return theme.colorScheme.onSurface.withOpacity(0.55);
  }
}

