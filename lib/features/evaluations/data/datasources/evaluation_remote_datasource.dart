import '../models/evaluation_model.dart';

class EvaluationRemoteDataSource {
  Future<void> saveEvaluation(EvaluationModel evaluation) async {
    // Aquí iría un POST a tu backend
    await Future.delayed(Duration(milliseconds: 500));
    print("Evaluación guardada: ${evaluation.toJson()}");
  }

  Future<List<EvaluationModel>> fetchEvaluations(String studentId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      EvaluationModel(
        id: "e1",
        evaluatorId: "s1",
        evaluatedId: studentId,
        puntualidad: 5,
        contribucion: 4,
        compromiso: 5,
        actitud: 4,
      )
    ];
  }
}
