import 'package:get/get.dart';
import 'dart:math';

class CategoryController extends GetxController {
  // Lista reactiva de categorías
  // Cada categoría es un Map con:
  // { "name": String, "method": String, "groupSize": int, "groups": List<Map<String,dynamic>> }
  var categories = <Map<String, dynamic>>[].obs;

  /// Agregar una nueva categoría
  void addCategory(Map<String, dynamic> category) {
    categories.add(category);
  }

  /// Editar una categoría existente
  void editCategory(int index, Map<String, dynamic> updatedCategory) {
    categories[index] = updatedCategory;
    categories.refresh();
  }

  /// Mover estudiante entre grupos
  void moveStudent(
    int categoryIndex,
    int fromGroup,
    int toGroup,
    String student,
  ) {
    final groups = categories[categoryIndex]["groups"] as List<Map<String, dynamic>>;
    (groups[fromGroup]["students"] as List<String>).remove(student);
    (groups[toGroup]["students"] as List<String>).add(student);
    categories.refresh();
  }

  void addGroup(int categoryIndex, Map<String, dynamic> group) {
    final groups = categories[categoryIndex]["groups"] as List<Map<String, dynamic>>;
    groups.add(group);
    categories.refresh(); // Notifica a la UI
  }

  /// Obtener todas las categorías
  List<Map<String, dynamic>> getAllCategories() {
    return categories.toList();
  }

  /// Obtener todos los grupos de una categoría
  List<Map<String, dynamic>> getGroupsOfCategory(int categoryIndex) {
    final groups = categories[categoryIndex]["groups"] as List<Map<String, dynamic>>;
    return groups;
  }

  /// Generar grupos automáticamente según el número de estudiantes
  /// [students] = lista de emails o IDs de estudiantes
  /// [groupSize] = tamaño deseado por grupo
  /// [method] = "Random" o "Self-assigned"
  List<Map<String, dynamic>> generateGroups({
    required List<String> students,
    required int groupSize,
    String method = "Random",
  }) {
    final List<Map<String, dynamic>> groups = [];

    final numGroups = (students.length / groupSize).ceil();

    // Crear grupos vacíos
    for (int i = 0; i < numGroups; i++) {
      groups.add({
        "name": "Grupo ${i + 1}",
        "students": <String>[],
      });
    }

    if (method == "Random") {
      final shuffled = [...students]..shuffle();
      for (int i = 0; i < shuffled.length; i++) {
        (groups[i % numGroups]["students"] as List<String>).add(shuffled[i]);
      }
    }
    // Si es Self-assigned, dejamos los grupos vacíos

    return groups;
  }

  /// Crear una categoría y generar sus grupos automáticamente
  void createCategoryWithGroups({
    required String name,
    required String method,
    required int groupSize,
    required List<String> students,
  }) {
    final newCategory = {
      "name": name,
      "method": method,
      "groupSize": groupSize,
      "groups": generateGroups(
        students: students,
        groupSize: groupSize,
        method: method,
      ),
    };

    addCategory(newCategory);
  }
}
