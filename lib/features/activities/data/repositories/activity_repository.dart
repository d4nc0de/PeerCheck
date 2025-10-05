import 'package:f_clean_template/features/activities/domain/models/activity.dart';
import 'package:f_clean_template/features/activities/domain/repositories/i_activity_repository.dart';
import 'package:f_clean_template/features/activities/data/datasources/i_activity_source.dart';
import 'package:f_clean_template/features/activities/data/datasources/local_activity_source.dart';

/// Repositorio concreto que utiliza la fuente local
class LocalActivityRepository implements IActivityRepository {
  final IActivitySource localSource;

  LocalActivityRepository(this.localSource);

  @override
  Future<List<Activity>> getActivities(String categoryId) {
    return localSource.getActivities(categoryId);
  }

  @override
  Future<void> addActivity(Activity activity) async {
    final activities = await localSource.getActivities(activity.categoryId);
    activities.add(activity);
    await localSource.saveActivities(activity.categoryId, activities);
  }

  @override
  Future<void> updateActivity(Activity updatedActivity) async {
    final activities = await localSource.getActivities(updatedActivity.categoryId);
    final index = activities.indexWhere((a) => a.id == updatedActivity.id);
    if (index != -1) {
      activities[index] = updatedActivity;
      await localSource.saveActivities(updatedActivity.categoryId, activities);
    }
  }

  @override
  Future<void> removeActivity(String categoryId, String activityId) async {
    if (localSource is LocalActivitySource) {
      await (localSource as LocalActivitySource).removeActivity(categoryId, activityId);
    } else {
      final activities = await localSource.getActivities(categoryId);
      activities.removeWhere((a) => a.id == activityId);
      await localSource.saveActivities(categoryId, activities);
    }
  }
}


