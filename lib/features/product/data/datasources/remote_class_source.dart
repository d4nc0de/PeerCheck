import '../../domain/models/class_item.dart';
import '../../domain/models/user_role.dart';

class RemoteClassSource {
  Future<List<ClassItem>> getClasses(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simula red

    if (role == UserRole.profesor) {
      return [
        ClassItem(name: 'Programación Móvil', nrc: 5566, teacher: 'Augusto Salazar'),
        ClassItem(name: 'Programación Móvil', nrc: 5566, teacher: 'Augusto Salazar'),
      ];
    } else {
      return [
        ClassItem(name: 'Programación Móvil', nrc: 5566, teacher: 'Augusto Salazar'),
        ClassItem(name: 'Programación Móvil', nrc: 5566, teacher: 'Augusto Salazar'),
      ];
    }
  }
}
