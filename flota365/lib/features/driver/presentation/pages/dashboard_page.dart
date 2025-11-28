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
          (a) => (a.status ?? "").toUpperCase() == "IN_PROGRESS",
        );
      } catch (_) {
        active = null;
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TEXTO BIENVENIDO 
            Text(
              "Bienvenido, $fullName",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            //MAPA (UBICACIÓN SOLO) 
            Card(
              child: SizedBox(
                height: 220,
                child: const _MyLocationMap(),
              ),
            ),

            const SizedBox(height: 16),

            // MI JORNADA (SOLO INFO, SIN BOTONES) 
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mi jornada",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Estado: ${active?.status ?? "Sin assignment activo"}",
                    ),
                    Text(
                      "Hora de inicio: ${active?.assignedAt?.toLocal().toString().substring(0, 19) ?? "-"}",
                    ),
                    Text(
                      "Vehículo: ${active?.vehicleId ?? "-"}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // MIS ASIGNACIONES (TU DISEÑO) 
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
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No tienes asignaciones"),
      );
    }

    final visible =
        _showAll ? widget.assignments : widget.assignments.take(2).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.assignments.length > 2)
                  TextButton(
                    onPressed: () {
                      setState(() => _showAll = !_showAll);
                    },
                    child: Text(_showAll ? "Ver menos" : "Ver más"),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: Column(
                children: visible
                    .map(
                      (a) => _AssignmentTile(
                        assignment: a,
                        isActive: widget.active != null &&
                            widget.active!.id == a.id,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/route-detail",
          arguments: assignment.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.10) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                assignment.route,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
