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
  final birth = TextEditingController(); // NO usado, pero se mantiene por UI
  final companyRuc = TextEditingController(); // NO usado
  final position = TextEditingController(); // NO usado
  final phone = TextEditingController(); // NO usado
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
      final String lastName =
          parts.length > 1 ? parts.sublist(1).join(" ") : parts.first;

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
    // ✅ Fuerza colores visibles aunque el Theme esté raro
    const textStyle = TextStyle(color: Colors.black87);
    const labelStyle = TextStyle(color: Colors.black54);
    const hintStyle = TextStyle(color: Colors.black38);

    InputDecoration decor(String label, {Widget? suffixIcon}) {
      return InputDecoration(
        labelText: label,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta — Gestor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: name,
                        style: textStyle,
                        cursorColor: Colors.teal,
                        decoration: decor('Nombre completo'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: birth,
                        style: textStyle,
                        cursorColor: Colors.teal,
                        decoration: decor('Fecha de nacimiento (opcional)'),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: companyRuc,
                        style: textStyle,
                        cursorColor: Colors.teal,
                        decoration: decor('Empresa / RUC (opcional)'),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: position,
                        style: textStyle,
                        cursorColor: Colors.teal,
                        decoration: decor('Cargo (opcional)'),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: phone,
                        style: textStyle,
                        cursorColor: Colors.teal,
                        decoration: decor('Teléfono (opcional)'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: email,
                        style: textStyle,
                        cursorColor: Colors.teal,
                        decoration: decor('Correo electrónico'),
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: pass,
                        style: textStyle,
                        cursorColor: Colors.teal,
                        obscureText: obscure,
                        decoration: decor(
                          'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility : Icons.visibility_off,
                              color: Colors.teal,
                            ),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                        ),
                        validator: (v) => Validators.password(v, min: 6),
                      ),

                      const SizedBox(height: 10),

                      Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            fillColor: WidgetStateProperty.all(Colors.teal),
                            checkColor: WidgetStateProperty.all(Colors.white),
                          ),
                        ),
                        child: CheckboxListTile(
                          value: acceptTerms,
                          onChanged: (v) => setState(() => acceptTerms = v ?? false),
                          title: const Text(
                            'Acepto los Términos y la Política de Privacidad',
                            style: TextStyle(color: Colors.black87),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
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
