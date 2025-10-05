import 'package:get/get.dart';
import 'package:f_clean_template/features/activities/domain/models/activity.dart';
import 'package:f_clean_template/features/activities/domain/use_case/activity_usecase.dart';

/// Controlador GetX para manejar el estado de las actividades
class ActivityController extends GetxController {
  final ActivityUseCase useCase;

  var activities = <Activity>[].obs;

  ActivityController(this.useCase);

  Future<void> loadActivities(String categoryId) async {
    activities.value = await useCase.getActivities(categoryId);
  }

  Future<void> addActivity(Activity activity) async {
    await useCase.addActivity(activity);
    await loadActivities(activity.categoryId);
  }

  Future<void> updateActivity(Activity updatedActivity) async {
    await useCase.updateActivity(updatedActivity);
    await loadActivities(updatedActivity.categoryId);
  }

  Future<void> removeActivity(String categoryId, String activityId) async {
    await useCase.removeActivity(categoryId, activityId);
    await loadActivities(categoryId);
  }
}

