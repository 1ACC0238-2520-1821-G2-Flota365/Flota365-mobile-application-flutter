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

      // ignore: avoid_print
      print("DATA DRIVER =>");
      // ignore: avoid_print
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
    // 🎨 Tema local SOLO para esta pantalla: texto negro, inputs pro.
    final base = Theme.of(context);
    final theme = base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black54),
        helperStyle: const TextStyle(color: Colors.black54),
        errorStyle: const TextStyle(color: Colors.red),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF111827), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
        ),
      ),
      checkboxTheme: base.checkboxTheme.copyWith(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return Colors.white;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF111827), width: 1.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      datePickerTheme: base.datePickerTheme.copyWith(
        backgroundColor: Colors.white,
        headerForegroundColor: Colors.black,
        dayForegroundColor: WidgetStateProperty.all(Colors.black),
        yearForegroundColor: WidgetStateProperty.all(Colors.black),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear cuenta — Conductor')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Datos del conductor',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Completa la información para crear tu cuenta.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: name,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            hintText: 'Ej: Juan Pérez',
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: email,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            hintText: 'correo@ejemplo.com',
                          ),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: pass,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            hintText: 'Mínimo 6 caracteres',
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black87,
                              ),
                              onPressed: () => setState(() => obscure = !obscure),
                            ),
                          ),
                          obscureText: obscure,
                          validator: (v) => Validators.password(v, min: 6),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Número de licencia',
                            hintText: 'Ej: ABC12345',
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          onChanged: (v) => licenseNumber = v,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            hintText: 'Ej: +51 999 999 999',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          onChanged: (v) => phone = v,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Años de experiencia',
                            hintText: 'Ej: 3',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          onChanged: (v) => experienceYears = int.tryParse(v) ?? 0,
                        ),
                        const SizedBox(height: 12),

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
                            ),
                            child: Text(
                              licenseExpiryDate != null
                                  ? licenseExpiryDate!.split('T').first
                                  : 'Selecciona una fecha',
                              style: TextStyle(
                                color: licenseExpiryDate != null
                                    ? Colors.black
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        CheckboxListTile(
                          value: acceptTerms,
                          onChanged: (v) => setState(() => acceptTerms = v ?? false),
                          title: const Text(
                            'Acepto los Términos y la Política de Privacidad',
                            style: TextStyle(color: Colors.black87),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),

                        const SizedBox(height: 10),

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
      ),
    );
  }
}
