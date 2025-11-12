import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';

class RegisterManagerPage extends StatefulWidget {
  const RegisterManagerPage({super.key});

  @override
  State<RegisterManagerPage> createState() => _RegisterManagerPageState();
}

class _RegisterManagerPageState extends State<RegisterManagerPage> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final birth = TextEditingController();
  final companyRuc = TextEditingController();
  final position = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obscure = true;
  bool loading = false;
  bool acceptTerms = false;

  @override
  void dispose() {
    name.dispose(); birth.dispose(); companyRuc.dispose();
    position.dispose(); phone.dispose(); email.dispose(); pass.dispose();
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
    // TODO: llamar al endpoint de registro para gestor
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
                      TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v)=> v!.isEmpty?'Requerido':null),
                      const SizedBox(height: 10),
                      TextFormField(controller: birth, decoration: const InputDecoration(labelText: 'Fecha de nacimiento (dd/mm/aaaa)')),
                      const SizedBox(height: 10),
                      TextFormField(controller: companyRuc, decoration: const InputDecoration(labelText: 'Empresa / RUC')),
                      const SizedBox(height: 10),
                      TextFormField(controller: position, decoration: const InputDecoration(labelText: 'Cargo')),
                      const SizedBox(height: 10),
                      TextFormField(controller: phone, decoration: const InputDecoration(labelText: 'Teléfono')),
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
