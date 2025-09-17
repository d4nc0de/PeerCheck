class Category {
  final String id;
  final String name;
  final String method; // "Random" o "Self-assigned"
  final int groupSize;
  final List<Group> groups;

  Category({
    required this.id,
    required this.name,
    required this.method,
    required this.groupSize,
    required this.groups,
  });

  /// Convertir de JSON a Category
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      method: json['method'] as String,
      groupSize: json['groupSize'] as int,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir de Category a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'method': method,
      'groupSize': groupSize,
      'groups': groups.map((g) => g.toJson()).toList(),
    };
  }
}

class Group {
  final String name;
  final List<String> students;

  Group({
    required this.name,
    required this.students,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'] as String,
      students: List<String>.from(json['students'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'students': students,
    };
  }
}
