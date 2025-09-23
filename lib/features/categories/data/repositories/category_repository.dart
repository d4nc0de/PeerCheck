import 'dart:convert';
import 'package:f_clean_template/features/categories/data/datasources/local/i_category_source.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart' as domain;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/i_category_source.dart';


class LocalCategoryRepository implements ICategoryRepository {
  final String _storageKey = 'categories';

  LocalCategoryRepository(ICategorySource find);

  @override
  Future<List<domain.Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((c) => domain.Category.fromJson(c)).toList();
    }

    print("📂 Leyendo categorías desde storage:");
    print(jsonString);
    return [];
  }

  @override
  Future<void> addCategory(domain.Category category) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();
    categories.add(category);

    final jsonString = json.encode(categories.map((c) => c.toJson()).toList());
    print("📦 Guardando categorías en storage:");
    print(jsonString); // 👈 aquí ves si incluye id, name, courseId, etc.
    await prefs.setString(_storageKey, jsonString);
  }

  @override
  Future<void> updateCategory(domain.Category updatedCategory) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();

    final index = categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      categories[index] = updatedCategory;
      final jsonString =
          json.encode(categories.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    }
  }

  @override
  Future<void> removeCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();
    categories.removeWhere((c) => c.id == categoryId);

    final jsonString = json.encode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
