// lib/features/auth/domain/models/authentication_user.dart
import 'package:uuid/uuid.dart';

class AuthenticationUser {
  final String id;            // id local (UUID)
  final String? backendId;    // id real del backend
  final String name;
  final String email;
  final String password;
  final String? token;        // 👈 NUEVO: para manejar el access_token

  AuthenticationUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.backendId,
    this.token,               // 👈
  });

  factory AuthenticationUser.create({
    required String name,
    required String email,
    required String password,
    String? backendId,
    String? token,            // 👈
  }) {
    return AuthenticationUser(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
      backendId: backendId,
      token: token,
    );
  }

  factory AuthenticationUser.fromJson(Map<String, dynamic> json) {
    return AuthenticationUser(
      id: json["id"] ?? const Uuid().v4(),
      name: json["name"] ?? '',
      email: json["email"] ?? '',
      password: json["password"] ?? '',
      backendId: json["backendId"],
      token: json["token"] ?? json["access_token"], // 👈 soporta ambas claves
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "backendId": backendId,
        "token": token, // 👈
      };
}
