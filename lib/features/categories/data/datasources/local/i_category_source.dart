import 'package:f_clean_template/features/categories/domain/models/category.dart';

/// Fuente abstracta que define cómo se accede a las categorías en almacenamiento local.
/// Implementaciones concretas (por ejemplo, LocalCategorySource) manejarán la persistencia
/// usando memoria, archivos locales o SharedPreferences.
abstract class ICategorySource {
  /// Obtiene todas las categorías asociadas a un curso.
  Future<List<Category>> getCategoriesByCourse(String courseId);

  /// Agrega una nueva categoría.
  Future<void> addCategory(Category category);

  /// Actualiza una categoría existente.
  Future<void> updateCategory(Category category);

  /// Elimina una categoría específica por su ID.
  Future<void> removeCategory(String categoryId);
}



