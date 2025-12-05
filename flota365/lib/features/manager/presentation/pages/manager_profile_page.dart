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
    final int? userId =
        args is int ? args : (args is Map ? args['userId'] as int? : null);

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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: BlocConsumer<ManagerProfileBloc, ManagerProfileState>(
          listener: (context, state) {
            if (state.status == ManagerProfileStatus.error &&
                state.error != null) {
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
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withOpacity(.12),
                          ),
                          child: const Icon(Icons.info_outline,
                              size: 28, color: Colors.orange),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No llegó el userId a esta pantalla.\n'
                          'Pasa "arguments: {userId: u.id}" cuando navegas al perfil.',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Volver'),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.withOpacity(.12),
                          ),
                          child: const Icon(Icons.refresh_rounded,
                              size: 28, color: Colors.teal),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudo cargar el perfil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Intenta nuevamente.',
                          style: TextStyle(
                            color: Colors.black.withOpacity(.65),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => context
                                .read<ManagerProfileBloc>()
                                .add(LoadManagerProfile(userId!)),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Reintentar',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _HeaderCard(
                    name: displayName,
                    email: profile.email,
                    roleChip: _RoleChip(role: profile.role),
                  ),
                  const SizedBox(height: 14),

                  // Sección acciones (pro)
                  const _SectionTitle(title: 'Cuenta'),
                  const SizedBox(height: 8),

                  _Panel(
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.edit,
                          title: 'Editar nombre y apellido',
                          subtitle: 'Actualiza tus datos personales',
                          onTap: () => _showEditNameDialog(
                            context,
                            firstInitial: profile.firstName,
                            lastInitial: profile.lastName,
                          ),
                        ),
                        const _SoftDivider(),
                        _ActionTile(
                          icon: Icons.lock_outline,
                          title: 'Cambiar contraseña',
                          subtitle: 'Recomendado cada cierto tiempo',
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                        const _SoftDivider(),
                        _ActionTile(
                          icon: Icons.refresh,
                          title: 'Actualizar datos',
                          subtitle: 'Vuelve a consultar el perfil',
                          onTap: () => context
                              .read<ManagerProfileBloc>()
                              .add(LoadManagerProfile(userId!)),
                        ),
                      ],
                    ),
                  ),

                  if (busy) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.black.withOpacity(.06)),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                              color: Colors.black.withOpacity(.06),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Procesando...',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(.06)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      ],
                    ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar perfil',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900)),
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
            const SizedBox(height: 10),
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
            child: const Text('Cancelar',
                style:
                    TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Guardar',
                style: TextStyle(fontWeight: FontWeight.w800)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cambiar contraseña',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900)),
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
            const SizedBox(height: 10),
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
            child: const Text('Cancelar',
                style:
                    TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cambiar',
                style: TextStyle(fontWeight: FontWeight.w800)),
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

/* ----------------------- UI PRO COMPONENTS ----------------------- */

class _HeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final Widget roleChip;

  const _HeaderCard({
    required this.name,
    required this.email,
    required this.roleChip,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);

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
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal.withOpacity(.12),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.teal,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withOpacity(.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          roleChip,
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final list = parts.toList();
    if (list.isEmpty) return 'U';
    if (list.length == 1) return list.first.characters.first.toUpperCase();
    return (list.first.characters.first + list.last.characters.first)
        .toUpperCase();
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 0, thickness: 1, color: Colors.black.withOpacity(.06));
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
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.circle, color: Colors.transparent), // placeholder
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.black.withOpacity(.60),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      // pintamos el icon real encima del leading sin cambiar funcionalidad
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      minLeadingWidth: 0,
      horizontalTitleGap: 12,
      dense: false,
      // hack simple para no meter Stack y no romper nada:
      // usamos el leading como Container y sobre-escribimos con IconTheme via Builder
      // (pero más simple: convertimos el leading a Stack usando widget ya existente)
      // -> lo dejamos directo:
      // (Flutter permite leading cualquier widget; lo cambiamos a Stack sin afectar lógica)
      leadingAndTrailingTextStyle: const TextStyle(color: Colors.black87),
    )._withLeadingIcon(icon);
  }
}

extension on ListTile {
  Widget _withLeadingIcon(IconData icon) {
    return Builder(
      builder: (context) {
        return ListTile(
          onTap: onTap,
          leading: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.teal.withOpacity(.18)),
            ),
            child: Icon(icon, color: Colors.teal, size: 20),
          ),
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          contentPadding: contentPadding,
          minLeadingWidth: minLeadingWidth,
          horizontalTitleGap: horizontalTitleGap,
          dense: dense,
        );
      },
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final r = role.trim().isEmpty ? 'Manager' : role.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded,
              size: 16, color: Colors.black.withOpacity(.70)),
          const SizedBox(width: 6),
          Text(
            r,
            style: const TextStyle(
              color: Colors.black87,
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
