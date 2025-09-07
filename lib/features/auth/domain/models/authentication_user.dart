import 'package:uuid/uuid.dart';

class AuthenticationUser {
  final String id;
  final String name;
  final String email;
  final String
  password; // ⚠️ solo para mock, en real nunca guardes la password en claro

  AuthenticationUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  factory AuthenticationUser.create({
    required String name,
    required String email,
    required String password,
  }) {
    return AuthenticationUser(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
    );
  }
}
