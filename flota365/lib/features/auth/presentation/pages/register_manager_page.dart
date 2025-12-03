import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../data/auth_repository.dart';
import '../../data/auth_service.dart';
import '../../domain/user.dart';

class RegisterManagerPage extends StatefulWidget {
  const RegisterManagerPage({super.key});

  @override
  State<RegisterManagerPage> createState() => _RegisterManagerPageState();
}

class _RegisterManagerPageState extends State<RegisterManagerPage> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final birth = TextEditingController();       // NO usado, pero se mantiene por UI
  final companyRuc = TextEditingController();  // NO usado
  final position = TextEditingController();    // NO usado
  final phone = TextEditingController();       // NO usado
  final email = TextEditingController();
  final pass = TextEditingController();

  bool obscure = true;
  bool loading = false;
  bool acceptTerms = false;

  @override
  void dispose() {
    name.dispose();
    birth.dispose();
    companyRuc.dispose();
    position.dispose();
    phone.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa el formulario y acepta los términos')),
      );
      return;
    }

    setState(() => loading = true);

    final repo = AuthRepository(AuthService());

    try {
      final String fullName = name.text.trim();
      List<String> parts = fullName.split(" ");

      final String firstName = parts.first;
      final String lastName = parts.length > 1 ? parts.sublist(1).join(" ") : parts.first;

      final User user = await repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email.text.trim(),
        password: pass.text.trim(),
        role: "Manager",
      );

      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gestor registrado con éxito')),
      );

      // Navegación final
      Navigator.pushReplacementNamed(context, '/login');

    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta — Gestor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Nombre completo'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: birth,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento (opcional)',
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: companyRuc,
                        decoration: const InputDecoration(
                          labelText: 'Empresa / RUC (opcional)',
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: position,
                        decoration: const InputDecoration(labelText: 'Cargo (opcional)'),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: phone,
                        decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: email,
                        decoration: const InputDecoration(labelText: 'Correo electrónico'),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: pass,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                        ),
                        validator: (v) => Validators.password(v, min: 6),
                      ),

                      const SizedBox(height: 10),

                      CheckboxListTile(
                        value: acceptTerms,
                        onChanged: (v) => setState(() => acceptTerms = v ?? false),
                        title: const Text('Acepto los Términos y la Política de Privacidad'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Crear cuenta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
