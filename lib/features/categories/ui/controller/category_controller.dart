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
      await loadCategories(courseId);
    } catch (e) {
      print("Error al agregar categoría: $e");
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






