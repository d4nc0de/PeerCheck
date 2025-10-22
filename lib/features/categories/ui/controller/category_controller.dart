import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';
import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/categories/domain/use_case/category_usecase.dart';

class CategoryController extends GetxController {
  final CategoryUseCase useCase;

  CategoryController(this.useCase);

  var categories = <Category>[].obs;
  var isLoading = false.obs;

  Future<void> loadCategories(String courseId) async {
    try {
      isLoading.value = true;
      final list = await useCase.getCategoriesByCourse(courseId);
      categories.assignAll(list);
    } catch (e) {
      print("Error al cargar categorías: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory({
    required String courseId,
    required String name,
    required String method,
    required int groupSize,
  }) async {
    try {
      await useCase.addCategory(
        courseId: courseId,
        name: name,
        method: method,
        groupSize: groupSize,
      );

      // Recargar para tener el _id real (remoto)
      await loadCategories(courseId);

      // Encontrar la recién creada por (courseId + name).
      // Si puedes devolver el _id desde el useCase, mejor, pero así evitamos romper capas.
      final created = categories.lastWhere(
        (c) => c.courseId == courseId && c.name == name,
        orElse: () => categories.firstWhere(
          (c) => c.courseId == courseId,
          orElse: () => throw Exception('No se pudo localizar la categoría creada'),
        ),
      );

      // Max estudiantes del curso
      final courseCtrl = Get.find<CourseController>();
      final maxStudents =
          courseCtrl.getMaxStudentsForCourseId(courseId) ?? groupSize;

      // Crear grupos según método
      final groupCtrl = Get.find<GroupController>();
      await groupCtrl.seedGroupsForCategory(
        courseId: courseId,
        categoryId: created.id,
        maxStudentsOfCourse: maxStudents,
        groupSize: groupSize,
        method: method,
      );

      // recargar de nuevo por si la UI de grupos depende de la categoría
      await loadCategories(courseId);
    } catch (e) {
      print("Error al agregar categoría: $e");
      rethrow;
    }
  }

  Future<void> updateCategory(String courseId, Category updated) async {
    try {
      await useCase.updateCategory(updated);
      await loadCategories(courseId);
    } catch (e) {
      print("Error al actualizar categoría: $e");
    }
  }

  Future<void> removeCategory(String courseId, String categoryId) async {
    try {
      await useCase.removeCategory(categoryId);
      await loadCategories(courseId);
    } catch (e) {
      print("Error al eliminar categoría: $e");
    }
  }
}






