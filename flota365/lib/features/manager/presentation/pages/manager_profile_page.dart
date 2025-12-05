import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/manager_repository.dart';
import '../../data/manager_service.dart';
import '../blocs/manager_profile/manager_profile_bloc.dart';
import '../blocs/manager_profile/manager_profile_event.dart';
import '../blocs/manager_profile/manager_profile_state.dart';
import '../widgets/manager_drawer.dart';

class ManagerProfilePage extends StatelessWidget {
  const ManagerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ lee userId de arguments: puede venir como int o como Map {'userId': int}
    final args = ModalRoute.of(context)?.settings.arguments;
    final int? userId = args is int ? args : (args is Map ? args['userId'] as int? : null);

    return BlocProvider(
      create: (_) {
        final bloc = ManagerProfileBloc(
          ManagerRepository(ManagerService()),
        );

        // ✅ si llegó userId, cargamos
        if (userId != null) {
          bloc.add(LoadManagerProfile(userId)); // <-- POSICIONAL
        }

        return bloc;
      },
      child: _ManagerProfileView(userId: userId),
    );
  }
}

class _ManagerProfileView extends StatelessWidget {
  const _ManagerProfileView({required this.userId});

  final int? userId;

  static const _textBlack = TextStyle(color: Colors.black87);
  static const _hintBlack54 = TextStyle(color: Colors.black54);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ManagerDrawer(),
      appBar: AppBar(
        title: const Text('Usuario', style: _textBlack),
        iconTheme: const IconThemeData(color: Colors.black87),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<ManagerProfileBloc, ManagerProfileState>(
          listener: (context, state) {
            if (state.status == ManagerProfileStatus.error && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            // ✅ si NO llegó userId, no podemos llamar al endpoint /profile/{id}
            if (userId == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, size: 34, color: Colors.black54),
                      const SizedBox(height: 10),
                      const Text(
                        'No llegó el userId a esta pantalla.\n'
                        'Pasa "arguments: {userId: u.id}" cuando navegas al perfil.',
                        style: TextStyle(color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.status == ManagerProfileStatus.loading ||
                state.status == ManagerProfileStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = state.profile;
            if (profile == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => context.read<ManagerProfileBloc>().add(LoadManagerProfile(userId!)),
                  child: const Text('Reintentar'),
                ),
              );
            }

            final busy = state.status == ManagerProfileStatus.updating ||
                state.status == ManagerProfileStatus.passwordChanging;

            final displayName = profile.fullName.isNotEmpty
                ? profile.fullName
                : '${profile.firstName} ${profile.lastName}'.trim();

            return AbsorbPointer(
              absorbing: busy,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InfoCard(
                    title: displayName,
                    subtitle: profile.email,
                    trailing: _RoleChip(role: profile.role),
                  ),
                  const SizedBox(height: 16),

                  const _SectionTitle(title: 'Cuenta'),
                  const SizedBox(height: 8),

                  _ActionTile(
                    icon: Icons.edit,
                    title: 'Editar nombre y apellido',
                    onTap: () => _showEditNameDialog(
                      context,
                      firstInitial: profile.firstName,
                      lastInitial: profile.lastName,
                    ),
                  ),
                  const Divider(height: 0),

                  _ActionTile(
                    icon: Icons.lock_outline,
                    title: 'Cambiar contraseña',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  const Divider(height: 0),

                  _ActionTile(
                    icon: Icons.refresh,
                    title: 'Actualizar datos',
                    onTap: () => context.read<ManagerProfileBloc>().add(LoadManagerProfile(userId!)),
                  ),

                  if (busy) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Tip: si el backend devuelve text/plain en el PUT, igual se refresca el perfil automáticamente.',
                    style: _hintBlack54,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context, {
    required String firstInitial,
    required String lastInitial,
  }) async {
    final firstCtrl = TextEditingController(text: firstInitial);
    final lastCtrl = TextEditingController(text: lastInitial);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Editar perfil', style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstCtrl,
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lastCtrl,
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Apellido',
                labelStyle: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      context.read<ManagerProfileBloc>().add(
            UpdateManagerProfile(
              firstName: firstCtrl.text.trim(),
              lastName: lastCtrl.text.trim(),
            ),
          );
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Cambiar contraseña', style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                labelStyle: TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                labelStyle: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      context.read<ManagerProfileBloc>().add(
            ChangeManagerPassword(
              currentPassword: currentCtrl.text,
              newPassword: newCtrl.text,
            ),
          );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(role, style: const TextStyle(color: Colors.black87)),
      backgroundColor: Colors.grey.shade200,
      side: BorderSide(color: Colors.grey.shade300),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0F2F1),
          child: Icon(Icons.person, color: Colors.teal),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: trailing,
      ),
    );
  }
}
