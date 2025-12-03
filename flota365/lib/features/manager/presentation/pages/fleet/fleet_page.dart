import 'package:flota365/features/manager/presentation/widgets/manager_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/manager_repository.dart';
import '../../../data/manager_service.dart';
import '../../blocs/fleet/fleet_bloc.dart';
import '../../blocs/fleet/fleet_event.dart';
import '../../blocs/fleet/fleet_state.dart';
import '../../../domain/entities/fleet_entity.dart';
import 'fleet_form_page.dart';

class FleetPage extends StatelessWidget {
  const FleetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FleetBloc(ManagerRepository(ManagerService()))
        ..add(LoadFleets()),
      child: const _FleetView(),
    );
  }
}

class _FleetView extends StatelessWidget {
  const _FleetView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ManagerDrawer(),
      appBar: AppBar(
        title: const Text('Gestión de Flotas'),
        centerTitle: true,
      ),
      body: BlocConsumer<FleetBloc, FleetState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          } else if (state.actionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Operación exitosa')),
            );
          }
        },
        builder: (context, state) {
          if (state.loading && state.fleets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<FleetBloc>().add(LoadFleets()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _FleetsHeader(
                    total: state.fleets.length,
                    loading: state.loading,
                  ),
                ),
                if (state.fleets.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      title: 'Sin flotas todavía',
                      subtitle: 'Crea tu primera flota para empezar a agregar vehículos.',
                      icon: Icons.directions_car_filled_rounded,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 120),
                    sliver: SliverList.separated(
                      itemCount: state.fleets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _FleetTile(fleet: state.fleets[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva flota'),
        onPressed: () async {
          final bloc = context.read<FleetBloc>();

          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const FleetFormPage(),
              ),
            ),
          );

          if (created == true) {
            bloc.add(LoadFleets());
          }
        },
      ),
    );
  }
}

class _FleetsHeader extends StatelessWidget {
  final int total;
  final bool loading;

  const _FleetsHeader({required this.total, required this.loading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(.14),
              theme.colorScheme.secondary.withOpacity(.10),
            ],
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(.15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.layers_rounded, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tus flotas',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loading ? 'Actualizando…' : '$total ${total == 1 ? "flota" : "flotas"} registradas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(.75),
                      ),
                    ),
                  ],
                ),
              ),
              _Pill(
                icon: loading ? Icons.sync_rounded : Icons.check_circle_rounded,
                text: loading ? 'Sync' : 'OK',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FleetTile extends StatelessWidget {
  final FleetEntity fleet;
  const _FleetTile({required this.fleet});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FleetBloc>();
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.pushNamed(
            context,
            "/manager/fleet/detail",
            arguments: fleet,
          );
        },
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
                _FleetAvatar(name: fleet.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fleet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fleet.description.isEmpty ? 'Sin descripción' : fleet.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(.70),
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
                              value: bloc,
                              child: FleetFormPage(fleet: fleet),
                            ),
                          ),
                        );

                        if (updated == true) {
                          bloc.add(LoadFleets());
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
                      onPressed: () => bloc.add(DeleteFleetRequested(fleet.id)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FleetAvatar extends StatelessWidget {
  final String name;
  const _FleetAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final letter = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'F';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(.85),
            theme.colorScheme.secondary.withOpacity(.85),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
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
              color: theme.textTheme.bodyMedium?.color?.withOpacity(.85),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.primary.withOpacity(.10),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
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
