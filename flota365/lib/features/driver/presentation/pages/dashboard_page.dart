import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/enums/status.dart';
import '../../../../features/driver/presentation/widgets/custom_drawer.dart';
import '../../../../main.dart' show AppRoutes;

import '../../data/driver_repository.dart';
import '../../data/driver_service.dart';
import '../../domain/entities/assignmentEntity.dart';
import '../../domain/entities/driver_info.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/dashboard/dashboard_state.dart';
import '../blocs/dashboard/dashboard_event.dart';

class DriverDashboardPage extends StatelessWidget {
  final int driverId;

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

  void _goDashboardHome(BuildContext context, int driverId) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.driverHome,
      (_) => false,
      arguments: driverId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            _goDashboardHome(context, state.driverId);
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Flota365 - Conductor"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () => _goDashboardHome(context, state.driverId),
                ),
              ],
            ),
            drawer: CustomDrawer(
              onHome: () => _goDashboardHome(context, state.driverId),
              onRoutes: () {
                Navigator.pushNamed(
                  context,
                  '/routes',
                  arguments: state.driverId,
                );
              },
              onHistory: () {
                Navigator.pushNamed(
                  context,
                  '/history',
                  arguments: state.driverId,
                );
              },
              onSupport: () {
                Navigator.pushNamed(context, '/support');
              },
              onLogout: () {
                Navigator.pushReplacementNamed(context, "/login");
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

    final DriverInfo? profile = state.profile;
    final fullName = profile?.fullName ?? "Conductor";
    final assignments = state.assignments;

    // Obtener el assignment activo (IN_PROGRESS)
    AssignmentEntity? active;
    if (assignments.isNotEmpty) {
      try {
        active = assignments.firstWhere(
          (a) {
            final s = (a.status ?? "").toUpperCase();
            return s == "IN_PROGRESS" || s == "PENDING" || s == "ACTIVE";
          },
        );
      } catch (_) {
        active = null;
      }
    }

    final activeStatus = (active?.status ?? "Sin assignment activo").toString();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (pro)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(.06)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(.06),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(.10),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bienvenido, $fullName",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Revisa tu ubicación y tus asignaciones.",
                          style: TextStyle(
                            color: Colors.black.withOpacity(.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusPill(status: activeStatus),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Mapa (pro)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(.06)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(.06),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 240,
                  child: const _MyLocationMap(),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Mi jornada (pro)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(.06)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(.06),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mi jornada",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MetaRow(
                    icon: Icons.info_outline_rounded,
                    label: "Estado",
                    value: active?.status ?? "Sin assignment activo",
                  ),
                  const SizedBox(height: 8),
                  _MetaRow(
                    icon: Icons.schedule_rounded,
                    label: "Hora de inicio",
                    value: active?.assignedAt?.toLocal().toString().substring(0, 19) ?? "-",
                  ),
                  const SizedBox(height: 8),
                  _MetaRow(
                    icon: Icons.directions_car_filled_rounded,
                    label: "Vehículo",
                    value: "${active?.vehicleId ?? "-"}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Mis asignaciones (tu sección, pero con mejor card)
            _AssignmentsListCard(
              assignments: assignments,
              active: active,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toUpperCase();
    Color bg = const Color(0xFFF2F2F2);
    Color fg = const Color(0xFF444444);
    IconData icon = Icons.info_rounded;
    String label = status;

    if (s == "PENDING") {
      bg = const Color(0xFFFFF6E5);
      fg = const Color(0xFFB26A00);
      icon = Icons.schedule_rounded;
      label = "PENDIENTE";
    } else if (s == "IN_PROGRESS" || s == "ACTIVE" || s == "STARTED") {
      bg = const Color(0xFFEAF2FF);
      fg = const Color(0xFF1E5BB8);
      icon = Icons.play_circle_fill_rounded;
      label = "EN CURSO";
    } else if (s == "COMPLETED" || s == "DONE") {
      bg = const Color(0xFFEAF9F1);
      fg = const Color(0xFF16794D);
      icon = Icons.check_circle_rounded;
      label = "COMPLETADO";
    } else if (s.contains("SIN ASSIGNMENT")) {
      bg = const Color(0xFFF2F2F2);
      fg = const Color(0xFF444444);
      icon = Icons.remove_circle_outline_rounded;
      label = "SIN RUTA";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black.withOpacity(.75)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(.70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationMap extends StatefulWidget {
  const _MyLocationMap();

  @override
  State<_MyLocationMap> createState() => _MyLocationMapState();
}

class _MyLocationMapState extends State<_MyLocationMap> {
  GoogleMapController? _controller;
  LatLng? _myPos;

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
  }

  Future<void> _loadMyLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _myPos = LatLng(pos.latitude, pos.longitude);
    });

    if (_controller != null && _myPos != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(_myPos!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _myPos ?? const LatLng(-12.0464, -77.0428),
        zoom: 14,
      ),
      onMapCreated: (c) {
        _controller = c;
        if (_myPos != null) {
          _controller!.animateCamera(
            CameraUpdate.newLatLngZoom(_myPos!, 15),
          );
        }
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
    );
  }
}

class _AssignmentsListCard extends StatefulWidget {
  final List<AssignmentEntity> assignments;
  final AssignmentEntity? active;

  const _AssignmentsListCard({
    required this.assignments,
    required this.active,
  });

  @override
  State<_AssignmentsListCard> createState() => _AssignmentsListCardState();
}

class _AssignmentsListCardState extends State<_AssignmentsListCard>
    with SingleTickerProviderStateMixin {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    if (widget.assignments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(.06),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withOpacity(.12),
              ),
              child: const Icon(Icons.route_rounded, color: Colors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "No tienes asignaciones",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.black.withOpacity(.85),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final visible =
        _showAll ? widget.assignments : widget.assignments.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Mis asignaciones",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              if (widget.assignments.length > 2)
                TextButton(
                  onPressed: () {
                    setState(() => _showAll = !_showAll);
                  },
                  child: Text(
                    _showAll ? "Ver menos" : "Ver más",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: Column(
              children: visible
                  .map(
                    (a) => _AssignmentTile(
                      assignment: a,
                      isActive:
                          widget.active != null && widget.active!.id == a.id,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final AssignmentEntity assignment;
  final bool isActive;

  const _AssignmentTile({
    required this.assignment,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? Colors.blue.withOpacity(0.10) : Colors.black.withOpacity(.03);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(
          context,
          "/route-detail",
          arguments: assignment.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(.06)),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.blue.withOpacity(.15) : Colors.black.withOpacity(.06),
              ),
              child: Icon(
                Icons.route_rounded,
                color: isActive ? Colors.blue.shade700 : Colors.black.withOpacity(.75),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                assignment.route,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black.withOpacity(.55)),
          ],
        ),
      ),
    );
  }
}
