import '../entities/evaluation.dart';

abstract class EvaluationRepository {
  Future<void> createEvaluation(Evaluation evaluation);
  Future<List<Evaluation>> getEvaluationsByStudent(String studentId);
}