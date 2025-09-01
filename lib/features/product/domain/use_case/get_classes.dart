import '../models/class_item.dart';
import '../models/user_role.dart';
import '../repositories/class_repository.dart';

class ClassUserCase {
  final ClassRepository repository;
  ClassUserCase(this.repository);

  Future<List<ClassItem>> call(UserRole role) => repository.getClasses(role);
  Future<List<ClassItem>> callLocal() => repository.getClassseLocal();
}
