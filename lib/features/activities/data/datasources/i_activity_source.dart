import 'package:f_clean_template/features/activities/domain/models/activity.dart';

/// Fuente abstracta para el manejo de actividades
abstract class IActivitySource {
  Future<List<Activity>> getActivities(String categoryId);
  Future<void> saveActivities(String categoryId, List<Activity> activities);
}

