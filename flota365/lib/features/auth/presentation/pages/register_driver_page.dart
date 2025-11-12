import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';

class RegisterDriverPage extends StatefulWidget {
  const RegisterDriverPage({super.key});

  @override
  State<RegisterDriverPage> createState() => _RegisterDriverPageState();
}

class _RegisterDriverPageState extends State<RegisterDriverPage> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final birth = TextEditingController();
  final licenseType = TextEditingController();
  final licenseNumber = TextEditingController();
  final experience = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obscure = true;
  bool loading = false;
  bool acceptTerms = false;

  @override
  void dispose() {
    name.dispose(); birth.dispose(); licenseType.dispose();
    licenseNumber.dispose(); experience.dispose(); email.dispose(); pass.dispose();
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
    // TODO: llamar a tu AuthService.registerRaw(payload)
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro enviado (demo)')),
      );
      Navigator.pop(context);
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v)=> v!.isEmpty?'Requerido':null),
                      const SizedBox(height: 10),
                      TextFormField(controller: birth, decoration: const InputDecoration(labelText: 'Fecha de nacimiento (dd/mm/aaaa)')),
                      const SizedBox(height: 10),
                      TextFormField(controller: licenseType, decoration: const InputDecoration(labelText: 'Tipo de licencia')),
                      const SizedBox(height: 10),
                      TextFormField(controller: licenseNumber, decoration: const InputDecoration(labelText: 'N° de licencia')),
                      const SizedBox(height: 10),
                      TextFormField(controller: experience, decoration: const InputDecoration(labelText: 'Experiencia (años)')),
                      const SizedBox(height: 10),
                      TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Correo electrónico'), validator: Validators.email),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: pass,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                        ),
                        obscureText: obscure,
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
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
