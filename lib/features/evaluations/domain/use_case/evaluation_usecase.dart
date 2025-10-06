import '../models/evaluation.dart';
import '../repository/evaluation_repository.dart';

class EvaluationUseCase {
  final EvaluationRepository repository;

  EvaluationUseCase(this.repository);

  Future<void> addEvaluation(Evaluation evaluation) async {
    await repository.saveEvaluation(evaluation.toJson());
  }

  Future<List<Evaluation>> getEvaluationsByActivity(String activityId) async {
    final data = await repository.getEvaluationsByActivity(activityId);
    return data.map((e) => Evaluation.fromJson(e)).toList();
  }

  Future<List<Evaluation>> getEvaluationsByEvaluator(String evaluatorId) async {
    final data = await repository.getEvaluationsByEvaluator(evaluatorId);
    return data.map((e) => Evaluation.fromJson(e)).toList();
  }
}

