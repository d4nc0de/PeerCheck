import 'package:f_clean_template/features/categories/data/datasources/local/i_category_source.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/categories/domain/repositories/i_category_repository.dart';

/// Implementación local del repositorio de categorías.
/// Se comunica con la fuente local (SharedPreferences, Hive, etc.)
class LocalCategoryRepository implements ICategoryRepository {
  final ICategorySource localSource;

  LocalCategoryRepository(this.localSource);

  /// Obtiene todas las categorías de un curso específico
  @override
  Future<List<Category>> getCategoriesByCourse(String courseId) async {
    return await localSource.getCategoriesByCourse(courseId);
  }

  /// Agrega una nueva categoría
  @override
  Future<void> addCategory(Category category) async {
    return await localSource.addCategory(category);
  }

  /// Actualiza una categoría existente
  @override
  Future<void> updateCategory(Category category) async {
    return await localSource.updateCategory(category);
  }

  /// Elimina una categoría por ID
  @override
  Future<void> removeCategory(String categoryId) async {
    return await localSource.removeCategory(categoryId);
  }
}



