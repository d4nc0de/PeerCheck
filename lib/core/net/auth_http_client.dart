import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:f_clean_template/features/auth/data/datasources/remote/Remote_authentication_source_service.dart';

/// Cliente que agrega el access token a cada request y,
/// si recibe 401, ejecuta onUnauthorized().
class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;
  final RemoteAuthenticationSourceService _auth;
  final Future<void> Function() _onUnauthorized;

  AuthHttpClient({
    required http.Client inner,
    required RemoteAuthenticationSourceService auth,
    required Future<void> Function() onUnauthorized,
  })  : _inner = inner,
        _auth = auth,
        _onUnauthorized = onUnauthorized;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Adjunta token
    final access = await _auth.getAccessToken();
    if (access != null && access.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $access';
    }
    request.headers.putIfAbsent('Content-Type', () => 'application/json');

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      // Sesión expirada o inválida: limpiamos y redirigimos a login
      await _onUnauthorized();
    }

    return response;
  }
}
