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

  String licenseNumber = '';
  String phone = '';
  int experienceYears = 0;
  String? licenseExpiryDate;

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

      // 1) Crear usuario
      final user = await authRepo.register(
        firstName: first,
        lastName: last,
        email: email.text.trim(),
        password: pass.text.trim(),
        role: 'Driver',
      );

      final driver = await driverRepo.createDriverFull(
      firstName: first,
      lastName: last,
      email: email.text.trim(),
      licenseNumber: licenseNumber,
      licenseExpiryDate: licenseExpiryDate!, 
      phone: phone,
      experienceYears: experienceYears,
    );

      print("DATA DRIVER =>");
      print({
        "code": "DRV-${DateTime.now().millisecondsSinceEpoch}",
        "firstName": first,
        "lastName": last,
        "licenseNumber": licenseNumber,
        "licenseExpireDate": licenseExpiryDate,
        "phone": phone,
        "email": email.text.trim(),
        "experienceYears": experienceYears,
      });



      if (driver == null) {
        throw Exception("No se pudo crear driver");
      }

      final int driverId = driver['id'] as int;

      // 3) Login automático
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
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta — Conductor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: name,
                        decoration:
                            const InputDecoration(labelText: 'Nombre completo'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: email,
                        decoration: const InputDecoration(
                            labelText: 'Correo electrónico'),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: pass,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(
                                obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => obscure = !obscure),
                          ),
                        ),
                        obscureText: obscure,
                        validator: (v) => Validators.password(v, min: 6),
                      ),
                      const SizedBox(height: 10),
                      // Número de licencia
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Número de licencia'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        onChanged: (v) => licenseNumber = v,
                      ),
                      const SizedBox(height: 10),

                      // Teléfono
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        onChanged: (v) => phone = v,
                      ),
                      const SizedBox(height: 10),

                      // Años de experiencia
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Años de experiencia'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        onChanged: (v) => experienceYears = int.tryParse(v) ?? 0,
                      ),
                      const SizedBox(height: 10),

                      // Fecha de expiración de licencia
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => licenseExpiryDate = picked.toIso8601String());
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de expiración de la licencia',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            licenseExpiryDate != null
                                ? licenseExpiryDate!.split('T').first
                                : 'Selecciona una fecha',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),


                      CheckboxListTile(
                        value: acceptTerms,
                        onChanged: (v) =>
                            setState(() => acceptTerms = v ?? false),
                        title: const Text(
                            'Acepto los Términos y la Política de Privacidad'),
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
