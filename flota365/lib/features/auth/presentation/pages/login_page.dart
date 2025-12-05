import 'package:flota365/core/session/app_session.dart';
import 'package:flota365/features/driver/data/driver_repository.dart';
import 'package:flota365/features/driver/data/driver_service.dart';
import 'package:flota365/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/status.dart';
import '../../../../core/utils/validators.dart';

import '../../data/auth_repository.dart';
import '../../data/auth_service.dart';
import '../blocs/login_bloc.dart';
import '../blocs/login_event.dart';
import '../blocs/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AuthRepository(AuthService());

    return BlocProvider(
      create: (_) => LoginBloc(repo),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) async {
                  if (state.status == Status.success && state.user != null) {
                    final u = state.user!;
                    final role = (u.role).toLowerCase();
                    final int driverId = u.id;

                    if (role == 'conductor' || role == 'driver') {
                        final driverRepo = DriverRepository(DriverService());

                        // ✅ Buscar el driver real por email
                        final driver = await driverRepo.findDriverByEmail(u.email);

                        // Si no existe, lo crea (para no romper flujo)
                        final ensured = driver ??
                            await driverRepo.ensureDriverForEmail(
                              email: u.email,
                              fullName: u.fullName,
                            );

                        final int driverId = ensured['id'] is int
                            ? ensured['id']
                            : int.tryParse(ensured['id'].toString()) ?? 0;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/driver/home',
                          (_) => false,
                          arguments: {
                            'driverId': driverId, // ✅ ahora sí es Driver.id
                            'fullName': u.fullName,
                            'email': u.email,
                          },
                        );
                      }
                      else if (role.contains('manager')) {
                          AppSession.userId = u.id; // ✅ guardar ID del usuario logueado

                          // MANAGER
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.managerHome,
                              (_) => false,
                            );
                        }
                  }

                  if (state.status == Status.failure && state.error != null) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(state.error!)),
                      );
                  }
                },
                builder: (context, state) {
                  final bloc = context.read<LoginBloc>();
                  final loading = state.status == Status.loading;

                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        Center(
                          child: Image.asset(
                            'lib/features/auth/assets/logo.png',
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text('Flota365',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(
                          'Inicia sesión para continuar',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration:
                              const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          onChanged: (v) => bloc.add(LoginEmailChanged(v)),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscure ? Icons.visibility : Icons.visibility_off),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          obscureText: _obscure,
                          validator: (v) => Validators.password(v, min: 6),
                          onChanged: (v) => bloc.add(LoginPasswordChanged(v)),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      bloc.add(LoginSubmitted());
                                    }
                                  },
                            child: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Iniciar sesión'),
                          ),
                        ),

                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/role');
                          },
                          child:
                              const Text('¿No tienes cuenta? Regístrate'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
