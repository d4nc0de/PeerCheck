import 'package:get/get.dart';
import '../../domain/models/evaluation.dart';
import '../../domain/usecases/create_evaluation_model.dart';
import '../../domain/usecases/get_student_evaluations.dart';

class EvaluationController extends GetxController {
  final CreateEvaluation createEvaluation;
  final GetStudentEvaluations getStudentEvaluations;

  EvaluationController({
    required this.createEvaluation,
    required this.getStudentEvaluations,
  });

  var evaluations = <Evaluation>[].obs;
  var loading = false.obs;

  Future<void> submitEvaluation(Evaluation evaluation) async {
    loading.value = true;
    try {
      await createEvaluation(evaluation);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadStudentEvaluations(String studentId) async {
    loading.value = true;
    try {
      final res = await getStudentEvaluations(studentId);
      evaluations.assignAll(res);
    } finally {
      loading.value = false;
    }
  }
}
