// lib/features/auth/domain/models/authentication_user.dart
import 'package:uuid/uuid.dart';

class AuthenticationUser {
  final String id;            // id local (UUId) -> no lo toco para no romper nada
  final String? backendId;    // 👈 NUEVO: id real del backend (UUID)
  final String name;
  final String email;
  final String password;

  AuthenticationUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.backendId,           // 👈
  });

  factory AuthenticationUser.create({
    required String name,
    required String email,
    required String password,
    String? backendId,        // 👈
  }) {
    return AuthenticationUser(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
      backendId: backendId,   // 👈
    );
  }

  factory AuthenticationUser.fromJson(Map<String, dynamic> json) {
    return AuthenticationUser(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      password: json["password"],
      backendId: json["backendId"], // 👈
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "backendId": backendId, // 👈
      };
}
