import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http; // 👈 NUEVO
import 'package:shared_preferences/shared_preferences.dart';

import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/i_authentication_source.dart';

class RemoteAuthenticationSourceService  implements IAuthenticationSource {
  // ====== NUEVO: config de backend y cliente http ======
  final http.Client _client;
  final String _baseUrl;   // p.ej. https://roble-api.openlab.uninorte.edu.co
  final String _dbName;    // p.ej. token_contract_xyz

  // ====== Claves de almacenamiento ======
  static const String _usersKey = "users_data";
  static const String _currentUserKey = "current_user";
  static const String _accessTokenKey = "access_token";
  static const String _refreshTokenKey = "refresh_token";

  List<AuthenticationUser> _users = [];
  AuthenticationUser? _currentUser;

  RemoteAuthenticationSourceService ({
    required http.Client client,
    required String baseUrl,
    required String dbName,
  })  : _client = client,
        _baseUrl = baseUrl,
        _dbName = dbName {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    _users = usersJson
        .map((e) => AuthenticationUser.fromJson(jsonDecode(e)))
        .toList();

    final currentUserJson = prefs.getString(_currentUserKey);
    if (currentUserJson != null) {
      _currentUser = AuthenticationUser.fromJson(jsonDecode(currentUserJson));
    }

    // 🔹 Usuarios por defecto (se mantiene tu comportamiento)
    if (_users.isEmpty) {
      _users = [
        AuthenticationUser(
          id: 'user_a',
          name: 'Andrés Pérez',
          email: 'a@a.com',
          password: '123456',
        ),
        AuthenticationUser(
          id: 'user_b',
          name: 'Beatriz López',
          email: 'b@a.com',
          password: '123456',
        ),
        AuthenticationUser(
          id: 'user_c',
          name: 'Carlos Gómez',
          email: 'c@a.com',
          password: '123456',
        ),
      ];
      await _saveUsers();
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = _users.map((u) => jsonEncode(u.toJson())).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString(
        _currentUserKey,
        jsonEncode(_currentUser!.toJson()),
      );
    } else {
      await prefs.remove(_currentUserKey);
    }
  }

  // ====== NUEVO: helpers de tokens ======
  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // ====== LOGIN: ahora llama al backend con http ======
 @override
  Future<AuthenticationUser> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/$_dbName/login');

    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      String msg = 'Error de autenticación';
      try {
        final parsed = jsonDecode(resp.body);
        if (parsed is Map && parsed['message'] is String) msg = parsed['message'];
      } catch (_) {}
      throw Exception(msg);
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    final userJson = data['user'] as Map<String, dynamic>?;

    if (access == null || refresh == null || userJson == null) {
      throw Exception('Respuesta de login inválida');
    }

    // Guarda tokens
    await _saveTokens(access, refresh);

    // 👇 Tomamos el id real del backend
    final backendId = userJson['id'] as String?;
    final nameFromBackend = (userJson['name'] as String?) ?? _guessNameFromEmail(email);

    // Resuelve/crea usuario local y actualízalo con backendId
    final existsIndex = _users.indexWhere((u) => u.email == email);
    AuthenticationUser user;
    if (existsIndex >= 0) {
      final prev = _users[existsIndex];
      user = AuthenticationUser(
        id: prev.id,                       // conservas id local
        name: nameFromBackend,
        email: email,
        password: password,                // tu modelo lo requiere
        backendId: backendId,              // 👈 guardamos el id real
      );
      _users[existsIndex] = user;
    } else {
      user = AuthenticationUser.create(
        name: nameFromBackend,
        email: email,
        password: password,
        backendId: backendId,              // 👈
      );
      _users.add(user);
    }

    await _saveUsers();
    _currentUser = user;
    await _saveCurrentUser();
    return user;
  }

  // Acceso rápido al usuario logueado (con backendId)
  @override
  AuthenticationUser? getCurrentUser() => _currentUser;

  // 👇 Para otras capas (p.ej. cursos) que necesitan el token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // 👇 Útil cuando solo necesitas el id real del backend en otra capa
  String? getCurrentBackendUserId() => _currentUser?.backendId;


  String _guessNameFromEmail(String email) {
    final raw = email.split('@').first;
    return raw.isEmpty ? 'Usuario' : (raw[0].toUpperCase() + raw.substring(1));
  }

  // ====== El resto queda igual ======

 @override
Future<AuthenticationUser> signup(
  String name,
  String email,
  String password,
) async {
  // final uri = Uri.parse('$_baseUrl/auth/$_dbName/signup');
  final uri = Uri.parse('$_baseUrl/auth/$_dbName/signup-direct');

  final resp = await _client.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'name': name,
    }),
  );

  // Manejo de error de servidor
  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    String msg = 'No fue posible registrar el usuario';
    try {
      final parsed = jsonDecode(resp.body);
      if (parsed is Map && parsed['message'] is String) {
        msg = parsed['message'];
      }
    } catch (_) {}
    throw Exception(msg);
  }

  // Intentar leer tokens (algunos backends retornan tokens en el signup)
  String? access;
  String? refresh;
  try {
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    access = data['accessToken'] as String?;
    refresh = data['refreshToken'] as String?;
  } catch (_) {/* cuerpo vacío o no-JSON también es válido */}

  if (access != null && refresh != null) {
    await _saveTokens(access, refresh);

    // Mantener compatibilidad con tu modelo actual:
    final user = AuthenticationUser.create(
      name: name,
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();
    _currentUser = user;
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    return user;
  }

  // 🔁 Fallback: si el signup no devuelve tokens, hacemos login
  final user = await login(email, password);
  return user;
}


  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    await _saveCurrentUser();
    await _clearTokens(); // 👈 limpia tokens al salir
  }
  /// Limpia tokens/estado y avisa a UI que la sesión caducó.
  /// (No llames al endpoint logout: ya no es válido el access).
  Future<void> handleUnauthorized() async {
    await _clearTokens();
    _currentUser = null;
    await _saveCurrentUser();
    // Redirige al login: usa tu ruta/página real
    // Si tienes rutas nombradas:
    // Get.offAllNamed('/login');
    // Si navegas por widget:
    // Get.offAll(() => const LoginPage());
    Get.offAllNamed('/login'); // <-- ajústalo a tu app
  }


}
