import 'package:dio/dio.dart';

String? _fromBody(dynamic body) {
  if (body is String && body.isNotEmpty) return body;
  if (body is Map<String, dynamic>) {
    for (final k in ['token', 'accessToken', 'access_token', 'jwt', 'id_token']) {
      final v = body[k];
      if (v is String && v.isNotEmpty) return v;
    }
    final nested = body['data'];
    if (nested is Map<String, dynamic>) return _fromBody(nested);
  }
  return null;
}

String? _fromHeaders(Headers h) {
  final list = h['authorization'] ?? h['Authorization'];
  if (list != null && list.isNotEmpty) {
    final v = list.first;
    if (v.toLowerCase().startsWith('bearer ')) return v.substring(7).trim();
  }
  return null;
}

String? extractToken(Response res) => _fromBody(res.data) ?? _fromHeaders(res.headers);
