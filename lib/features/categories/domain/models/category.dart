import 'package:f_clean_template/features/groups/domain/models/group.dart';

/// Modelo que representa una categoría de un curso
class Category {
  final String id;
  final String courseId;
  final String name;
  final String method; // método de agrupamiento (manual o aleatorio)
  final int groupSize; // tamaño de grupo si aplica
  final List<Group> groups;

  Category({
    required this.id,
    required this.courseId,
    required this.name,
    required this.method,
    required this.groupSize,
    this.groups = const [],
  });

  Category copyWith({
    String? id,
    String? courseId,
    String? name,
    String? method,
    int? groupSize,
    List<Group>? groups,
  }) {
    return Category(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      method: method ?? this.method,
      groupSize: groupSize ?? this.groupSize,
      groups: groups ?? this.groups,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'name': name,
        'method': method,
        'groupSize': groupSize,
        'groups': groups.map((g) => g.toJson()).toList(),
      };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      courseId: json['courseId'],
      name: json['name'],
      method: json['method'],
      groupSize: json['groupSize'],
      groups: (json['groups'] as List?)
              ?.map((g) => Group.fromJson(Map<String, dynamic>.from(g)))
              .toList() ??
          [],
    );
  }
}
