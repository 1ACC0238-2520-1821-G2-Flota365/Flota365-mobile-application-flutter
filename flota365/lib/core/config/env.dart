class Env {

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://underground-tuesday-renworkplace-1e2821cb.koyeb.app',
  );

  static const isProd = bool.fromEnvironment('IS_PROD', defaultValue: false);
}
