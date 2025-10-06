import 'package:get/get.dart';
import '../../domain/models/evaluation.dart';
import '../../domain/use_case/evaluation_usecase.dart';

class EvaluationController extends GetxController {
  final EvaluationUseCase useCase;

  EvaluationController(this.useCase);

  var evaluations = <Evaluation>[].obs;

  Future<void> loadEvaluationsByActivity(String activityId) async {
    evaluations.value = await useCase.getEvaluationsByActivity(activityId);
  }

  Future<void> addEvaluation(Evaluation evaluation) async {
    await useCase.addEvaluation(evaluation);
    await loadEvaluationsByActivity(evaluation.activityId);
  }
}
