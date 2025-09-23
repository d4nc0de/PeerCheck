import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

class Group {
  final int number; // número de grupo
  final String id; // id único
  final List<AuthenticationUser> members;

  Group({
    required this.id,
    required this.number,
    this.members = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      number: json['number'],
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
      'members': members.map((u) => u.toJson()).toList(),
    };
  }
}
