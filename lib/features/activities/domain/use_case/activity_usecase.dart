import 'package:f_clean_template/features/activities/domain/models/activity.dart';
import 'package:f_clean_template/features/activities/domain/repositories/i_activity_repository.dart';

/// Casos de uso para la gestión de actividades
class ActivityUseCase {
  final IActivityRepository repository;

  ActivityUseCase(this.repository);

  Future<List<Activity>> getActivities(String categoryId) {
    return repository.getActivities(categoryId);
  }

  Future<void> addActivity(Activity activity) {
    return repository.addActivity(activity);
  }

  Future<void> updateActivity(Activity updatedActivity) {
    return repository.updateActivity(updatedActivity);
  }

  Future<void> removeActivity(String categoryId, String activityId) {
    return repository.removeActivity(categoryId, activityId);
  }
}

