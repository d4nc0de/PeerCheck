import '../../domain/models/class_item.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/class_repository.dart';
import '../datasources/remote_class_source.dart';

class ClassRepositoryImpl implements ClassRepository {
  final RemoteClassSource dataSource;
  ClassRepositoryImpl(this.dataSource);

  @override
  Future<List<ClassItem>> getClasses(UserRole role) => dataSource.getClasses(role);
  
  @override
  Future<List<ClassItem>> getClassseLocal() {
    // TODO: implement getClassseLocal
    throw UnimplementedError();
  }
}
