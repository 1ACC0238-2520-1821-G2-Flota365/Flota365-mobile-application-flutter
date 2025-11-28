class Env {
  // Permite cambiar la base por --dart-define
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://flota365-backend-corp-cmawf5ddamh5f7b8.westus3-01.azurewebsites.net',
  );
  static const ORS_API_KEY = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjlmNDI0OWE3OTVlZTQwMjdhODg3MzdmYzA0MmIzMjIxIiwiaCI6Im11cm11cjY0In0=';
  static const isProd = bool.fromEnvironment('IS_PROD', defaultValue: false);
}
