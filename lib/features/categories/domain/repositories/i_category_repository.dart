import 'package:f_clean_template/features/categories/domain/models/category.dart';

/// Contrato que define las operaciones de persistencia de categorías
abstract class ICategoryRepository {
  /// Obtiene todas las categorías asociadas a un curso
  Future<List<Category>> getCategoriesByCourse(String courseId);

  /// Agrega una nueva categoría
  Future<void> addCategory(Category category);

  /// Actualiza una categoría existente
  Future<void> updateCategory(Category category);

  /// Elimina una categoría por su ID
  Future<void> removeCategory(String categoryId);
}



