import 'package:flota365/features/manager/presentation/blocs/assigment/assignment_bloc.dart';
import 'package:flota365/features/manager/presentation/blocs/assigment/assignment_event.dart';
import 'package:flota365/features/manager/presentation/blocs/assigment/assignment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';
import '../../../domain/entities/assignment_entity.dart';

import 'assignment_form_page.dart';
import 'assignment_detail_page.dart';
import '../../widgets/manager_drawer.dart';

class AssignmentListPage extends StatelessWidget {
  const AssignmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssignmentBloc(ManagerRepository(ManagerService()))
        ..add(LoadAssignments()),
      child: const _AssignmentListView(),
    );
  }
}

/// Filtros disponibles (UI local). No toca backend/BLoC.
enum _AssignmentFilter { all, pending, inProgress, completed }

class _AssignmentListView extends StatefulWidget {
  const _AssignmentListView();

  @override
  State<_AssignmentListView> createState() => _AssignmentListViewState();
}

class _AssignmentListViewState extends State<_AssignmentListView> {
  _AssignmentFilter _filter = _AssignmentFilter.all;

  bool _matchFilter(AssignmentEntity a) {
    final s = a.status.trim().toUpperCase();
    switch (_filter) {
      case _AssignmentFilter.all:
        return true;
      case _AssignmentFilter.pending:
        return s == "PENDING";
      case _AssignmentFilter.inProgress:
        return s == "IN_PROGRESS" || s == "STARTED";
      case _AssignmentFilter.completed:
        return s == "COMPLETED" || s == "DONE";
    }
  }

  String _filterText(_AssignmentFilter f) {
    switch (f) {
      case _AssignmentFilter.all:
        return "Todas";
      case _AssignmentFilter.pending:
        return "Pendiente";
      case _AssignmentFilter.inProgress:
        return "En curso";
      case _AssignmentFilter.completed:
        return "Completado";
    }
  }

  IconData _filterIcon(_AssignmentFilter f) {
    switch (f) {
      case _AssignmentFilter.all:
        return Icons.list_alt_rounded;
      case _AssignmentFilter.pending:
        return Icons.schedule_rounded;
      case _AssignmentFilter.inProgress:
        return Icons.play_circle_fill_rounded;
      case _AssignmentFilter.completed:
        return Icons.check_circle_rounded;
    }
  }

  void _goCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AssignmentBloc>(),
          child: const AssignmentFormPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ManagerDrawer(),
      appBar: AppBar(
        title: const Text("Rutas asignadas"),
        centerTitle: true,
      ),
      body: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.assignments.isEmpty) {
            return _EmptyState(
              title: "No hay rutas registradas",
              subtitle: "Crea una asignación para empezar a operar.",
              onCreate: () => _goCreate(context),
            );
          }

          final filtered = state.assignments.where(_matchFilter).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AssignmentBloc>().add(LoadAssignments());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header pro: filtros + contador
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border:
                                Border.all(color: Colors.black.withOpacity(.06)),
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
                              // Título + contador
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Filtros",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.04),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                          color: Colors.black.withOpacity(.08)),
                                    ),
                                    child: Text(
                                      "Mostrando ${filtered.length} de ${state.assignments.length}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: Colors.black.withOpacity(.75),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Chips tipo segmented control
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _AssignmentFilter.values.map((f) {
                                  final selected = _filter == f;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () => setState(() => _filter = f),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Colors.black
                                            : Colors.black.withOpacity(.04),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: selected
                                              ? Colors.black
                                              : Colors.black.withOpacity(.10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _filterIcon(f),
                                            size: 18,
                                            color: selected
                                                ? Colors.white
                                                : Colors.black.withOpacity(.75),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _filterText(f),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13,
                                              color: selected
                                                  ? Colors.white
                                                  : Colors.black.withOpacity(.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(.12),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: Colors.amber.withOpacity(.30)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_rounded),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "No hay rutas con estado “${_filterText(_filter)}”.",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Lista
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      return _AssignmentTile(assignment: filtered[i]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Nueva ruta"),
        onPressed: () => _goCreate(context),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final AssignmentEntity assignment;

  const _AssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusUi(assignment.status);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AssignmentBloc>(), // REUSA EL MISMO BLOC
              child: AssignmentDetailPage(assignmentId: assignment.id),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(.06),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(.06)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Route + Status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    assignment.route,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _StatusChip(
                  label: statusStyle.label,
                  bg: statusStyle.bg,
                  fg: statusStyle.fg,
                  icon: statusStyle.icon,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Meta
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaPill(
                  icon: Icons.directions_car_filled_rounded,
                  label: "Vehículo",
                  value: "${assignment.vehicleId}",
                ),
                _MetaPill(
                  icon: Icons.person_rounded,
                  label: "Conductor",
                  value: "${assignment.driverId}",
                ),
                _MetaPill(
                  icon: Icons.tag_rounded,
                  label: "ID",
                  value: "${assignment.id}",
                ),
              ],
            ),
          ],
        ),
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
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaPill({
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black.withOpacity(.75)),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(.70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onCreate;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(.12),
                ),
                child: const Icon(Icons.route_rounded, color: Colors.teal),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withOpacity(.65)),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text("Crear ruta"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
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
