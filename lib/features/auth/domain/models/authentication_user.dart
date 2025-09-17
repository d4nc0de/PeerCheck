import 'package:uuid/uuid.dart';

class AuthenticationUser {
  final String id;
  final String name;
  final String email;
  final String password;

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

  // ➕ Serialización
  factory AuthenticationUser.fromJson(Map<String, dynamic> json) {
    return AuthenticationUser(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      password: json["password"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "password": password,
  };
}
