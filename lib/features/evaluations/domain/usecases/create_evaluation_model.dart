import '../models/evaluation.dart';
import '../repositories/evaluation_repository.dart';

class CreateEvaluation {
  final EvaluationRepository repository;
  CreateEvaluation(this.repository);

  Future<void> call(Evaluation evaluation) async {
    return await repository.createEvaluation(evaluation);
  }
}