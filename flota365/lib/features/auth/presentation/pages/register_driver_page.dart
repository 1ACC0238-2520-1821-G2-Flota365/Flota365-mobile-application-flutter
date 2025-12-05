import 'package:flutter/material.dart';
import 'package:flota365/core/utils/validators.dart';

import '../../../auth/data/auth_repository.dart';
import '../../../auth/data/auth_service.dart';
import '../../../driver/data/driver_repository.dart';
import '../../../driver/data/driver_service.dart';

class RegisterDriverPage extends StatefulWidget {
  const RegisterDriverPage({super.key});

  @override
  State<RegisterDriverPage> createState() => _RegisterDriverPageState();
}

class _RegisterDriverPageState extends State<RegisterDriverPage> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();

  bool obscure = true;
  bool loading = false;
  bool acceptTerms = false;

  final authRepo = AuthRepository(AuthService());
  final driverRepo = DriverRepository(DriverService());

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa el formulario y acepta los términos'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final fullName = name.text.trim();
      final parts = fullName.split(' ');
      final first = parts.isNotEmpty ? parts.first : 'Conductor';
      final last = parts.length > 1 ? parts.sublist(1).join(' ').trim() : '';

      final user = await authRepo.register(
        firstName: first,
        lastName: last,
        email: email.text.trim(),
        password: pass.text.trim(),
        role: 'driver',
      );

      final driver = await driverRepo.ensureDriverForEmail(
        email: email.text.trim(),
        fullName: fullName,
      );

      if (driver == null) {
        throw Exception("No se pudo crear driver");
      }

      final int driverId = driver['id'] as int;

      final logged = await authRepo.login(
        email.text.trim(),
        pass.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/driver/home',
        (_) => false,
        arguments: {
          'driverId': driverId,
          'fullName': fullName,
          'email': email.text.trim(),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fuerza colores visibles aunque el theme esté raro
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
      appBar: AppBar(title: const Text('Crear cuenta — Conductor')),
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
                        style: textStyle,          // ✅ texto escrito
                        cursorColor: Colors.teal,  // ✅ cursor visible
                        decoration: decor('Nombre completo'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
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
                        obscureText: obscure,
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
                            style: TextStyle(color: Colors.black87), // ✅ visible
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
