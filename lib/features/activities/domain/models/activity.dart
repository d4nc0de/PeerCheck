import 'package:uuid/uuid.dart';

/// Modelo que representa una actividad dentro de una categoría.
class Activity {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final DateTime dueDate;
  final double score;

  Activity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.score,
  });

  /// Crear una nueva actividad con ID generado automáticamente
  factory Activity.create({
    required String categoryId,
    required String name,
    required String description,
    required DateTime dueDate,
    required double score,
  }) {
    return Activity(
      id: const Uuid().v4(),
      categoryId: categoryId,
      name: name,
      description: description,
      dueDate: dueDate,
      score: score,
    );
  }

  /// Copiar la actividad con posibles modificaciones
  Activity copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    DateTime? dueDate,
    double? score,
  }) {
    return Activity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryId": categoryId,
        "name": name,
        "description": description,
        "dueDate": dueDate.toIso8601String(),
        "score": score,
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json["id"],
      categoryId: json["categoryId"],
      name: json["name"],
      description: json["description"],
      dueDate: DateTime.parse(json["dueDate"]),
      score: (json["score"] as num).toDouble(),
    );
  }
}

