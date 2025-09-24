import '../../../groups/domain/models/group.dart';
import 'activity.dart';
import 'evaluation.dart';

class Category {
  final String id;
  final String name;
  final int groupingMethod; // 1 = autoasignación, 2 = aleatorio
  final String courseId; 
  final List<Group> groups;
  final List<Activity> activities;
  final List<Evaluation> evaluations;

  Category({
    required this.id,
    required this.name,
    required this.groupingMethod,
    required this.courseId, 
    this.groups = const [],
    this.activities = const [],
    this.evaluations = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Validación de campos requeridos
    final String? id = json['id']?.toString();
    final String? name = json['name']?.toString();
    final String? courseId = json['courseId']?.toString();
    
    if (id == null || id.isEmpty) {
      throw ArgumentError('Category: campo "id" es requerido y no puede ser null o vacío');
    }
    
    if (name == null || name.isEmpty) {
      throw ArgumentError('Category: campo "name" es requerido y no puede ser null o vacío');
    }
    
    if (courseId == null || courseId.isEmpty) {
      throw ArgumentError('Category: campo "courseId" es requerido y no puede ser null o vacío');
    }

    return Category(
      id: id,
      name: name,
      groupingMethod: json['groupingMethod'] ?? 1,
      courseId: courseId,
      groups: (json['groups'] as List<dynamic>?)
              ?.map((g) => Group.fromJson(g))
              .toList() ??
          [],
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => Activity.fromJson(a))
              .toList() ??
          [],
      evaluations: (json['evaluations'] as List<dynamic>?)
              ?.map((e) => Evaluation.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'groupingMethod': groupingMethod,
      'courseId': courseId, 
      'groups': groups.map((g) => g.toJson()).toList(),
      'activities': activities.map((a) => a.toJson()).toList(),
      'evaluations': evaluations.map((e) => e.toJson()).toList(),
    };
  }
}