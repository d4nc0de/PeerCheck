import 'package:uuid/uuid.dart';

class Evaluation {
  final String id;
  final String evaluatorId; // ID del estudiante que evalúa
  final String evaluatedId; // ID del compañero evaluado
  final String groupId;
  final String activityId;
  final String categoryId;
  final double puntualidad;
  final double contribucion;
  final double compromiso;
  final double actitud;

  Evaluation({
    required this.id,
    required this.evaluatorId,
    required this.evaluatedId,
    required this.groupId,
    required this.activityId,
    required this.categoryId,
    required this.puntualidad,
    required this.contribucion,
    required this.compromiso,
    required this.actitud,
  });

  factory Evaluation.create({
    required String evaluatorId,
    required String evaluatedId,
    required String groupId,
    required String activityId,
    required String categoryId,
    double puntualidad = 3,
    double contribucion = 3,
    double compromiso = 3,
    double actitud = 3,
  }) {
    return Evaluation(
      id: const Uuid().v4(),
      evaluatorId: evaluatorId,
      evaluatedId: evaluatedId,
      groupId: groupId,
      activityId: activityId,
      categoryId: categoryId,
      puntualidad: puntualidad,
      contribucion: contribucion,
      compromiso: compromiso,
      actitud: actitud,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'evaluatorId': evaluatorId,
        'evaluatedId': evaluatedId,
        'groupId': groupId,
        'activityId': activityId,
        'categoryId': categoryId,
        'puntualidad': puntualidad,
        'contribucion': contribucion,
        'compromiso': compromiso,
        'actitud': actitud,
      };

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      evaluatorId: json['evaluatorId'],
      evaluatedId: json['evaluatedId'],
      groupId: json['groupId'],
      activityId: json['activityId'],
      categoryId: json['categoryId'],
      puntualidad: (json['puntualidad'] ?? 3).toDouble(),
      contribucion: (json['contribucion'] ?? 3).toDouble(),
      compromiso: (json['compromiso'] ?? 3).toDouble(),
      actitud: (json['actitud'] ?? 3).toDouble(),
    );
  }
}
