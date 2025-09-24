import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/i_authentication_source.dart';

class LocalAuthenticationSourceService implements IAuthenticationSource {
  static const String _usersKey = "users_data";
  static const String _currentUserKey = "current_user";

  List<AuthenticationUser> _users = [];
  AuthenticationUser? _currentUser;

  LocalAuthenticationSourceService() {
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

    // 🔹 Si es primera vez, cargar usuarios por defecto
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
  Future<List<AuthenticationUser>> getAllUsers() async {
  // Asegura que los usuarios estén cargados desde SharedPreferences
  if (_users.isEmpty) {
    await _loadFromPrefs();
  }
  return List<AuthenticationUser>.from(_users);
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

  @override
  Future<AuthenticationUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = _users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => throw Exception("Credenciales inválidas"),
    );

    _currentUser = user;
    await _saveCurrentUser();
    return user;
  }

  @override
  Future<AuthenticationUser> signup(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final exists = _users.any((u) => u.email == email);
    if (exists) {
      throw Exception("El correo ya está registrado");
    }

    final newUser = AuthenticationUser.create(
      name: name,
      email: email,
      password: password,
    );

    _users.add(newUser);
    _currentUser = newUser;

    await _saveUsers();
    await _saveCurrentUser();

    return newUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    await _saveCurrentUser();
  }

  @override
  AuthenticationUser? getCurrentUser() {
    return _currentUser;
  }
}
