class Validators {
  static String? email(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Ingresa tu email';
    final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$').hasMatch(value);
    if (!ok) return 'Email inválido';
    return null;
  }

  static String? password(String? v, {int min = 6}) {
    final value = v ?? '';
    if (value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < min) return 'Mínimo $min caracteres';
    return null;
  }
}
