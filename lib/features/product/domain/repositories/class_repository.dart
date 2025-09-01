import '../models/class_item.dart';
import '../models/user_role.dart';

abstract class ClassRepository {
  Future<List<ClassItem>> getClasses(UserRole role);
  Future<List<ClassItem>> getClassseLocal();
}
