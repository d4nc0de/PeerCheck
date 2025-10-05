import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f_clean_template/features/categories/data/datasources/local/i_category_source.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';

/// Implementación local del almacenamiento de categorías.
/// Usa SharedPreferences para persistir la información entre sesiones.
class LocalCategorySource implements ICategorySource {
  final String _storageKeyPrefix = 'categories_'; // Prefijo por curso

  /// Retorna la clave completa en SharedPreferences para un curso específico.
  String _keyForCourse(String courseId) => '$_storageKeyPrefix$courseId';

  @override
  Future<List<Category>> getCategoriesByCourse(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyForCourse(courseId));

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((item) => Category.fromJson(item)).toList();
    } catch (e) {
      print("⚠️ Error al leer categorías del curso $courseId: $e");
      return [];
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategoriesByCourse(category.courseId);

    // Evita duplicados por ID
    if (categories.any((c) => c.id == category.id)) {
      print("⚠️ Categoría ya existente con ID ${category.id}");
      return;
    }

    categories.add(category);
    final jsonString = json.encode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_keyForCourse(category.courseId), jsonString);

    print("✅ Categoría '${category.name}' guardada para curso ${category.courseId}");
  }

  @override
  Future<void> updateCategory(Category updatedCategory) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategoriesByCourse(updatedCategory.courseId);

    final index = categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      categories[index] = updatedCategory;
      final jsonString = json.encode(categories.map((c) => c.toJson()).toList());
      await prefs.setString(_keyForCourse(updatedCategory.courseId), jsonString);
      print("🔄 Categoría '${updatedCategory.name}' actualizada.");
    } else {
      print("⚠️ No se encontró la categoría ${updatedCategory.id} para actualizar.");
    }
  }

  @override
  Future<void> removeCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();

    // Buscar en todos los cursos registrados
    final keys = prefs.getKeys().where((k) => k.startsWith(_storageKeyPrefix));

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString == null) continue;

      final List<dynamic> decoded = json.decode(jsonString);
      final categories = decoded.map((c) => Category.fromJson(c)).toList();
      final updated = categories.where((c) => c.id != categoryId).toList();

      if (updated.length != categories.length) {
        await prefs.setString(
          key,
          json.encode(updated.map((c) => c.toJson()).toList()),
        );
        print("🗑️ Categoría eliminada del almacenamiento (key=$key).");
      }
    }
  }
}



