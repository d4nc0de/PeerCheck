import 'package:get/get.dart';

class CategoryController extends GetxController {
  // Lista reactiva de categorías
  // Cada categoría es un Map con:
  // { "name": String, "method": String, "groupSize": int, "groups": List }
  var categories = <Map<String, dynamic>>[].obs;

  /// Agregar una nueva categoría
  void addCategory(Map<String, dynamic> category) {
    categories.add(category);
  }

  /// Agregar un grupo dentro de una categoría
  void addGroup(int categoryIndex, Map<String, dynamic> group) {
    categories[categoryIndex]["groups"].add(group);
    categories.refresh(); // obliga a que se actualice la vista
  }

  /// Editar una categoría existente
  void editCategory(int index, Map<String, dynamic> updatedCategory) {
    categories[index] = updatedCategory;
    categories.refresh();
  }

  /// Mover estudiante entre grupos (extra: para lo que pediste al inicio)
  void moveStudent(int categoryIndex, int fromGroup, int toGroup, dynamic student) {
    categories[categoryIndex]["groups"][fromGroup]["students"].remove(student);
    categories[categoryIndex]["groups"][toGroup]["students"].add(student);
    categories.refresh();
  }
}
