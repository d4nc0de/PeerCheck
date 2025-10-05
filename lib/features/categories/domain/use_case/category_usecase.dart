import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/categories/domain/repositories/i_category_repository.dart';
import 'package:uuid/uuid.dart';

class CategoryUseCase {
  final ICategoryRepository repository;

  CategoryUseCase(this.repository);

  /// 🔹 Obtener categorías de un curso
  Future<List<Category>> getCategoriesByCourse(String courseId) async {
    return await repository.getCategoriesByCourse(courseId);
  }

  /// 🔹 Agregar una nueva categoría
  Future<void> addCategory({
    required String courseId,
    required String name,
    required String method,
    required int groupSize,
  }) async {
    final newCategory = Category(
      id: const Uuid().v4(),
      courseId: courseId,
      name: name,
      method: method,
      groupSize: groupSize,
    );

    await repository.addCategory(newCategory);
  }

  /// 🔹 Actualizar una categoría existente
  Future<void> updateCategory(Category category) async {
    await repository.updateCategory(category);
  }

  /// 🔹 Eliminar una categoría por ID
  Future<void> removeCategory(String categoryId) async {
    await repository.removeCategory(categoryId);
  }
}



