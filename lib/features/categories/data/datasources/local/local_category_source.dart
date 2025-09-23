import 'dart:convert';
import 'package:f_clean_template/features/categories/data/datasources/local/i_category_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/category.dart';

class LocalCategorySource implements ICategorySource {
  final String _storageKey = 'categories';

  @override
  Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((c) => Category.fromJson(c)).toList();
    }
    return [];
  }

  @override
  Future<void> addCategory(Category category) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();
    categories.add(category);

    final jsonString = json.encode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);

  }

  @override
  Future<void> updateCategory(Category updatedCategory) async {
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
