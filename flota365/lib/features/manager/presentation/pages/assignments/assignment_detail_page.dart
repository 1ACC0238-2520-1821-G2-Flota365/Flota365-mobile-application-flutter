import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flota365/features/driver/domain/entities/driver_info.dart';
import 'package:flota365/features/manager/presentation/widgets/manager_drawer.dart';

import 'package:flota365/features/manager/presentation/blocs/assigment/assignment_bloc.dart';
import 'package:flota365/features/manager/presentation/blocs/assigment/assignment_state.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';

import '../../../domain/entities/vehicle_entity.dart';

class AssignmentDetailPage extends StatefulWidget {
  final int assignmentId;

  const AssignmentDetailPage({
    super.key,
    required this.assignmentId,
  });

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  VehicleEntity? vehicle;
  DriverInfo? driver;

  bool loadingVehicle = true;
  bool loadingDriver = true;

  @override
  void initState() {
    super.initState();
    _loadVehicle();
    _loadDriver();
  }

  Future<void> _loadVehicle() async {
    final repo = ManagerRepository(ManagerService());

    final assignments = context.read<AssignmentBloc>().state.assignments;
    final assignment = assignments.firstWhere((a) => a.id == widget.assignmentId);

    try {
      final vehicles = await repo.getVehicles();
      final found = vehicles.firstWhere(
        (v) => v.id == assignment.vehicleId,
        orElse: () => _vehicleNotFound(assignment.vehicleId),
      );

      if (!mounted) return;
      setState(() {
        vehicle = found;
        loadingVehicle = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        vehicle = _vehicleNotFound(assignment.vehicleId);
        loadingVehicle = false;
      });
    }
  }

  Future<void> _loadDriver() async {
    final repo = ManagerRepository(ManagerService());

    final assignments = context.read<AssignmentBloc>().state.assignments;
    final assignment = assignments.firstWhere((a) => a.id == widget.assignmentId);

    try {
      final info = await repo.getDriverInfo(assignment.driverId);

      if (!mounted) return;
      setState(() {
        driver = info;
        loadingDriver = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        driver = DriverInfo(id: assignment.driverId, fullName: "No encontrado");
        loadingDriver = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ManagerDrawer(),
      appBar: AppBar(
        title: const Text("Detalle de Ruta"),
        centerTitle: true,
      ),
      body: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, state) {
          final assignment = state.assignments.firstWhere(
            (a) => a.id == widget.assignmentId,
          );

          final statusStyle = _statusUi(assignment.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.withOpacity(.12),
                        ),
                        child: const Icon(Icons.route_rounded, color: Colors.teal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ruta",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              assignment.route,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _StatusChip(
                                  label: statusStyle.label,
                                  bg: statusStyle.bg,
                                  fg: statusStyle.fg,
                                  icon: statusStyle.icon,
                                ),
                                _MiniChip(
                                  icon: Icons.tag_rounded,
                                  text: "ID: ${assignment.id}",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Vehicle card
                _SectionTitle(title: "Vehículo"),
                const SizedBox(height: 8),
                loadingVehicle
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ))
                    : _InfoCard(
                        icon: Icons.directions_car_filled_rounded,
                        title: "Placa: ${vehicle?.licensePlate ?? '-'}",
                        subtitle:
                            "${vehicle?.brand ?? ''} ${vehicle?.model ?? ''}".trim().isEmpty
                                ? "ID: ${assignment.vehicleId}"
                                : "${vehicle!.brand} ${vehicle!.model} (ID: ${assignment.vehicleId})",
                      ),

                const SizedBox(height: 14),

                // Driver card
                _SectionTitle(title: "Conductor"),
                const SizedBox(height: 8),
                loadingDriver
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ))
                    : _InfoCard(
                        icon: Icons.person_rounded,
                        title: driver?.fullName?.isNotEmpty == true
                            ? driver!.fullName
                            : "-",
                        subtitle:
                            "ID: ${assignment.driverId}"
                            "${(driver?.email != null && driver!.email!.isNotEmpty) ? " · ${driver!.email}" : ""}",
                      ),

                const SizedBox(height: 14),

                // Timeline
                _SectionTitle(title: "Tiempos"),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    border: Border.all(color: Colors.black.withOpacity(.06)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                        color: Colors.black.withOpacity(.05),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _TimelineRow(
                        label: "Inicio",
                        value: assignment.startedAt?.toString() ?? "—",
                        icon: Icons.play_circle_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      _TimelineRow(
                        label: "Fin",
                        value: assignment.completedAt?.toString() ?? "—",
                        icon: Icons.flag_circle_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  VehicleEntity _vehicleNotFound(int id) => VehicleEntity(
        id: id,
        licensePlate: "No encontrado",
        brand: "",
        model: "",
        year: 0,
        mileage: 0,
        status: "",
        statusDate: null,
        driverName: "",
        lastServiceDate: null,
        nextServiceDate: null,
        createdAt: null,
        updatedAt: null,
        fleetId: 0,
        fleetName: "",
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: .2,
        color: Color(0xFF374151),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.05),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.black.withOpacity(.04),
          ),
          child: Icon(icon, color: Colors.black.withOpacity(.75)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.black.withOpacity(.7)),
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TimelineRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black.withOpacity(.70)),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(.65),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(.04),
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black.withOpacity(.70)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(.25)),
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
              fontSize: 12.5,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}

_StatusStyle _statusUi(String raw) {
  final s = raw.trim().toUpperCase();
  if (s == "PENDING") {
    return const _StatusStyle(
      label: "PENDIENTE",
      bg: Color(0xFFFFF6E5),
      fg: Color(0xFFB26A00),
      icon: Icons.schedule_rounded,
    );
  }
  if (s == "IN_PROGRESS" || s == "STARTED") {
    return const _StatusStyle(
      label: "EN CURSO",
      bg: Color(0xFFEAF2FF),
      fg: Color(0xFF1E5BB8),
      icon: Icons.play_circle_fill_rounded,
    );
  }
  if (s == "COMPLETED" || s == "DONE") {
    return const _StatusStyle(
      label: "COMPLETADO",
      bg: Color(0xFFEAF9F1),
      fg: Color(0xFF16794D),
      icon: Icons.check_circle_rounded,
    );
  }
  return const _StatusStyle(
    label: "ESTADO",
    bg: Color(0xFFF2F2F2),
    fg: Color(0xFF444444),
    icon: Icons.info_rounded,
  );
}

class _StatusStyle {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _StatusStyle({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });
}
