import '../../domain/models/evaluation.dart';

class EvaluationModel extends Evaluation {
  EvaluationModel({
    required String id,
    required String evaluatorId,
    required String evaluatedId,
    required int puntualidad,
    required int contribucion,
    required int compromiso,
    required int actitud,
  }) : super(
          id: id,
          evaluatorId: evaluatorId,
          evaluatedId: evaluatedId,
          puntualidad: puntualidad,
          contribucion: contribucion,
          compromiso: compromiso,
          actitud: actitud,
        );

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: json['id'],
      evaluatorId: json['evaluatorId'],
      evaluatedId: json['evaluatedId'],
      puntualidad: json['puntualidad'],
      contribucion: json['contribucion'],
      compromiso: json['compromiso'],
      actitud: json['actitud'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'evaluatorId': evaluatorId,
      'evaluatedId': evaluatedId,
      'puntualidad': puntualidad,
      'contribucion': contribucion,
      'compromiso': compromiso,
      'actitud': actitud,
    };
  }
}