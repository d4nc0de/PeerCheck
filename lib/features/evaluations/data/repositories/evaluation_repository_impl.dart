import '../../domain/entities/evaluation.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../datasources/evaluation_remote_datasource.dart';
import '../models/evaluation_model.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationRemoteDataSource remote;
  EvaluationRepositoryImpl(this.remote);

  @override
  Future<void> createEvaluation(Evaluation evaluation) async {
    final model = EvaluationModel(
      id: evaluation.id,
      evaluatorId: evaluation.evaluatorId,
      evaluatedId: evaluation.evaluatedId,
      puntualidad: evaluation.puntualidad,
      contribucion: evaluation.contribucion,
      compromiso: evaluation.compromiso,
      actitud: evaluation.actitud,
    );
    return await remote.saveEvaluation(model);
  }

  @override
  Future<List<Evaluation>> getEvaluationsByStudent(String studentId) async {
    return await remote.fetchEvaluations(studentId);
  }
}
