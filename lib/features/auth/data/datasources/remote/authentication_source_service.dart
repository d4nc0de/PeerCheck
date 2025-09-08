import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/i_authentication_source.dart';

class AuthenticationSourceService implements IAuthenticationSource {
  final List<AuthenticationUser> _users = [
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
  AuthenticationUser? _currentUser;

  @override
  Future<AuthenticationUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = _users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => throw Exception("Credenciales inválidas"),
    );

    _currentUser = user;
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

    return newUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  AuthenticationUser? getCurrentUser() {
    return _currentUser;
  }
}
