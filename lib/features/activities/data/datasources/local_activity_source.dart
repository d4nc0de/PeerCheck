import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f_clean_template/features/activities/domain/models/activity.dart';
import 'package:f_clean_template/features/activities/data/datasources/i_activity_source.dart';

/// Fuente local para manejar el almacenamiento de actividades
class LocalActivitySource implements IActivitySource {
  @override
  Future<List<Activity>> getActivities(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('activities_$categoryId') ?? [];
    return stored.map((e) => Activity.fromJson(jsonDecode(e))).toList();
  }

  @override
  Future<void> saveActivities(String categoryId, List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = activities.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('activities_$categoryId', encoded);
  }

  /// Elimina una actividad específica de una categoría
  Future<void> removeActivity(String categoryId, String activityId) async {
    final activities = await getActivities(categoryId);
    activities.removeWhere((a) => a.id == activityId);
    await saveActivities(categoryId, activities);
  }
}


