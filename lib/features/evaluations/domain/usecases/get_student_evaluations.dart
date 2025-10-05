import '../models/evaluation.dart';
import '../repositories/evaluation_repository.dart';

class GetStudentEvaluations {
  final EvaluationRepository repository;
  GetStudentEvaluations(this.repository);

  Future<List<Evaluation>> call(String studentId) async {
    return await repository.getEvaluationsByStudent(studentId);
  }
}