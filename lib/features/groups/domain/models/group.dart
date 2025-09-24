import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

class Group {
  final String id; // id único
  final int number; // número de grupo
  final String categoryId; // referencia a la categoría
  final List<AuthenticationUser> members;

  Group({
    required this.id,
    required this.number,
    required this.categoryId,
    this.members = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      number: json['number'],
      categoryId: json['categoryId'],
      members: (json['members'] as List<dynamic>?)
              ?.map((u) => AuthenticationUser.fromJson(u))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'categoryId': categoryId,
      'members': members.map((u) => u.toJson()).toList(),
    };
  }

  // Método para crear una copia con modificaciones
  Group copyWith({
    String? id,
    int? number,
    String? categoryId,
    List<AuthenticationUser>? members,
  }) {
    return Group(
      id: id ?? this.id,
      number: number ?? this.number,
      categoryId: categoryId ?? this.categoryId,
      members: members ?? this.members,
    );
  }
}