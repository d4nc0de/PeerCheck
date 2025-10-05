import 'package:f_clean_template/features/activities/domain/models/activity.dart';

/// Repositorio abstracto para las actividades
abstract class IActivityRepository {
  Future<List<Activity>> getActivities(String categoryId);
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity updatedActivity);
  Future<void> removeActivity(String categoryId, String activityId);
}
